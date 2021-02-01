#!/bin/bash
echo "Stopping ts3 server..."
systemctl stop ts3

# move into /opt for sanity
cd /opt

echo "Backing up into /opt/teamspeak3-server-back/"
cp -r /opt/teamspeak3-server/ /opt/teamspeak3-server-back/

echo "Forcing the removal of the pid file..."
rm /opt/teamspeak3-server/ts3server.pid

echo "Downloading latest server"
wget $(curl -s 'https://www.teamspeak.com/en/downloads/#server' | grep -o 'https://files.teamspeak-services.com/releases/server/.*/teamspeak3-server_linux_amd64-.*.tar.bz2' | head -n1) -O /opt/teamspeak-server-latest.tar.bz2

echo "Unpacking..."
tar -xjf ./teamspeak-server-latest.tar.bz2

echo "Removing tar..."
rm teamspeak-server-latest.tar.bz2

echo "Copying new files into current server folder..."
cp -r /opt/teamspeak3-server_linux_amd64/* /opt/teamspeak3-server/
chown -R teamspeak3-user:teamspeak3-user teamspeak3-server

echo "Removing latest server downloaded folder: /opt/teamspeak3-server_linux_amd64/"
rm -rf /opt/teamspeak3-server_linux_amd64/

echo "Restarting server..."
systemctl start ts3
systemctl status ts3 | head -n 30

echo "Please delete the back up folder /opt/teamspeak3-server-backup/ after checking everything is fine!"
