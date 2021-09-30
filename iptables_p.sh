#!bin/bash


# allows all services breifely while configuring
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#local
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#flushes preset rules
iptables -F



#add redirect rules for ports 465 and 587 (to let postfix run on different ports)
iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 25
iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 25



#reset the default policies to stop all incoming and forward requests
iptables -P INPUT DROP
iptables -P FORWARD DROP



#reject any other traffic after all rules
iptables -A INPUT -j reject
iptables -A INPUT -j reject