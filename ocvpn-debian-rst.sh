#!/bin/bash
### pre-alpha version for openconnect client installer in Debian + drop RST packet injected by ISP
### bash ocvpn-debian.sh ADDRESS USERNAME PASSWORD IPADDRESS
### bash ocvpn-debian.sh 219.2.2.2:443 user1 pass1 219.2.2.2
### bash ocvpn-debian.sh https://vp.example.com user1 pass1 219.2.2.2

###### Main

ADDRESS=""
USERNAME=""
PASSWORD=""
IPADDRESS=""

ADDRESS=$1
USERNAME=$2
PASSWORD=$3

if [[ $IPADDRESS == "" ]] ; then
  echo "run:\n bash ocvpn-debian.sh server-address username password ip-address"
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

iptables -D INPUT -p tcp -s $IPADDRESS --tcp-flags RST RST -j DROP

apt install iptables-persistent -y
###input ok 
###input ok

sleep 5

iptables-save > /etc/iptables/rules.v4

systemctl status ocvpn

iptables -n -v -L INPUT
