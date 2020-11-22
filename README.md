# openconnect-service
Install openconnect client and run as service

`bash ocvpn-debian.sh server-address username password`


## Kill-switch
Login as root and then:
```bash
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -d 192.168.128.0/24 -j ACCEPT # == "ipv4-network" in ocserv.conf
iptables -A OUTPUT -d 192.168.0.0/16 -j DROP
iptables -A OUTPUT -d 0.0.0.0/8 -j DROP
iptables -A OUTPUT -d 192.0.2.0/24 -j DROP
iptables -A OUTPUT -d 192.42.172.0/24 -j DROP
iptables -A OUTPUT -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -d 111.111.111.111/32 -p tcp -m multiport --dports 53,443 -j ACCEPT # == SERVER_IP
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -d 111.111.111.111/32 -p udp -m multiport --dports 53,443 -j ACCEPT # == SERVER_IP
iptables -A OUTPUT -o tun+ -j ACCEPT 
iptables -A OUTPUT -o vpn+ -j ACCEPT # network-manager's VPN

```
Save iptables:
```
services iptables save
```

Then use `--resolve=` to connect. Like:
```
echo "mypassword" | openconnect --resolve=my.example.com:111.111.111.111 -vu myusername --passwd-on-stdin https://my.example.com/

```

## save iptables

```bash
/sbin/service iptables save
```

```bash
iptables-save > /etc/iptables/rules.v4
```
