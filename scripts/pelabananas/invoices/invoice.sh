#! /bin/bash
set -e

CYAN="\033[0;36m"
YELLOW="\033[0;33m"
YELLOW_BOLD="\033[1;33m"
NOCOLOR="\033[0m"

RECOLTE_WORKING_DIR='/Users/dvitto/projects/recolte'
PDF_GENERATOR_WORKING_DIR='/Users/dvitto/projects/pdf-invoice-generator'
YEAR=$(date +"%Y")
INVOICES_FOLDER="/Users/dvitto/ownCloud/documents/StackBuilders/invoices/${YEAR}"

# run recolte (harvest + email send to SB)
echo -e "${CYAN}Running ${YELLOW_BOLD}recolte${CYAN} ...${NOCOLOR}"
cd $RECOLTE_WORKING_DIR
. venv/bin/activate
python main.py

# run recolte with dry run to get values for pdf invoice
echo -e "${CYAN}Running ${YELLOW_BOLD}recolte ${YELLOW}(dry run)${CYAN} ...${NOCOLOR}"
myarr=($(python main.py --dry-run | awk -F: 'NR>1{ print $2 }'))

from=$(echo ${myarr[0]})
to=$(echo ${myarr[2]})
time_period=$(echo "$from / $to")
rate=$(echo ${myarr[4]})
total_hours=$(echo ${myarr[3]})

# calculate next Invoice ID
last_number=$(ls $INVOICES_FOLDER | tail -1 | awk -F '[-]' '{print $(NF-0)}')
new_number=$(expr $last_number + 1)
new_filled_number=$(echo $new_number | awk '{printf "%04d\n", $0;}')
invoice_id="STACKB-${new_filled_number}"

# run pdf generator with values from dry-run
echo -e "${CYAN}Running ${YELLOW_BOLD}pdf-invoice-generator${CYAN} ...${NOCOLOR}"
cd $PDF_GENERATOR_WORKING_DIR
. venv/bin/activate
python generate.py -t $total_hours -r $rate -id $invoice_id -n "$time_period"

# create a new folder under invoices folder
echo -e "${CYAN}Creating new folder in owncloud ...${NOCOLOR}"
new_invoice_folder="${INVOICES_FOLDER}/$invoice_id"
mkdir $new_invoice_folder

# move generated harvest report and pdf invoice to owncloud folder
cd "${RECOLTE_WORKING_DIR}/reports"
last_generated_harvest_report=$(ls -tc | awk '{print$0}' | head -1)
cp $last_generated_harvest_report $new_invoice_folder
echo -e "${CYAN}Copied ${YELLOW}${last_generated_harvest_report}${NOCOLOR} into ${YELLOW}owncloud${NOCOLOR} ${CYAN}...${NOCOLOR}"


cd "${PDF_GENERATOR_WORKING_DIR}/invoices"
last_generated_pdf_invoice=$(ls -tc | awk '{print$0}' | head -1)
cp $last_generated_pdf_invoice $new_invoice_folder
echo -e "${CYAN}Copied ${YELLOW}${last_generated_pdf_invoice}${NOCOLOR} into ${YELLOW}owncloud${NOCOLOR} ${CYAN}...${NOCOLOR}"

