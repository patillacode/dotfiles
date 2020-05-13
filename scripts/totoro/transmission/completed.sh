#!/bin/bash

# port, username, password
SERVER="9091" # --auth transmission:transmission"

# use transmission-remote to get torrent list from transmission-remote list
# use sed to delete first / last line of output, and remove leading spaces
# use cut to get first field from each line
TORRENTLIST=`transmission-remote $SERVER --list | sed -e '1d;$d;s/^ *//' | cut --only-delimited --delimiter=" " --fields=1`

# for each torrent in the list
for TORRENTID in $TORRENTLIST
do
    # check if torrent download is completed
    DL_COMPLETED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "Percent Done: 100%"`

    # check torrents current state is
    STATE_STOPPED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "State: Seeding\|Stopped\|Finished\|Idle"`

    # if the torrent is "Stopped", "Finished", or "Idle after downloading 100%"
    if [[ "$DL_COMPLETED" &&  "$STATE_STOPPED" ]]; then
        # remove the torrent from Transmission
        echo "Removing$(transmission-remote -t $TORRENTID --info | awk 'NR==3' | cut -f2- -d ":") (#$TORRENTID) ..."
        transmission-remote $SERVER --torrent $TORRENTID --remove
    # else
    #    echo "Torrent$(transmission-remote -t $TORRENTID --info | awk 'NR==3' | cut -f2- -d ":") (#$TORRENTID) is not completed. Ignoring."
    fi
done
