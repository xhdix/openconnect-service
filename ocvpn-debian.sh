#!/bin/bash
### pre-alpha version for openconnect client installer in Debian
### bash ocvpn-debian.sh ADDRESS USERNAME PASSWORD
### bash ocvpn-debian.sh 219.2.2.2:443 user1 pass1
### bash ocvpn-debian.sh https://vp.example.com user1 pass1

###### Main

ADDRESS=""
USERNAME=""
PASSWORD=""

ADDRESS=$1
USERNAME=$2
PASSWORD=$3

if [[ $PASSWORD == "" ]] ; then
  echo "run:\n bash serverA.sh server-address username password"
  exit
fi

apt update
apt dist-upgrade -y
apt install openconnect -y


cat > /etc/systemd/system/ocvpn.service << "EOF"
[Unit]
Description=Connect to my VPN
After=network.target

[Service]
Type=simple
ExecStart=/bin/sh -c 'echo password | openconnect -u username --passwd-on-stdin address'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sed -i "s~password~$PASSWORD~" /etc/systemd/system/ocvpn.service
sed -i "s~username~$USERNAME~" /etc/systemd/system/ocvpn.service
sed -i "s~address~$ADDRESS~" /etc/systemd/system/ocvpn.service

systemctl daemon-reload
systemctl enable ocvpn
systemctl start ocvpn

systemctl status ocvpn
