#!bin/bash

#flushes preset rules
echo "---flushing---"
iptables -t mangle -F
iptables -t mangle -X
iptables -F
iptables -X


# allows all services breifely while configuring
echo "default input"
iptables -t mangle -P INPUT ACCEPT

iptables -t mangle -P OUTPUT ACCEPT


#local
echo "---allow loopback---"
iptables -t mangle -A INPUT -i lo -j ACCEPT
iptables -t mangle -A OUTPUT -o lo -j ACCEPT


#add redirect rules for ports 465 and 587 (to let postfix run on different ports)
echo "---postfix---"
iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 25
iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 25



#reset the default policies to stop all incoming and forward requests
iptables -t mangle -P INPUT DROP
iptables -t mangle -P FORWARD DROP



#reject any other traffic after all rules
iptables -t mangle -A INPUT -j reject
iptables -t mangle -A INPUT -j reject