#!/bin/sh

#admins = ''

#flushes preset rules
echo "---flushing---"
iptables -t mangle -F
iptables -t mangle -X
iptables -F
iptables -X

# allows all services breifely while configuring
iptables -t mangle -P INPUT DROP
iptables -t mangle -P FORWARD DROP
iptables -t mangle -P OUTPUT ACCEPT


#local
echo "---allow loopback---"
iptables -t mangle -A INPUT -i lo -j ACCEPT
iptables -t mangle -A OUTPUT -o lo -j ACCEPT

#open port 80 HTTP 
iptables -t mangle -A INPUT -p tcp --dport 80 -j ACCEPT


#SSH

#open port 22 SSH
iptables -t mangle -A INPUT -p tcp --dport 22 -j ACCEPT
#start logging ssh when session is started
#grep to sort through /var/log/kern.log
iptables -I INPUT -p tcp --dport 22 -j LOG --log-level 0 --log-prefix "SSH_IN___"
# allows 4 ssh attempts by IP every 3 mins
iptables -t mangle -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --set --name DEFAULT --rsource
iptables -t mangle -A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -m recent --update --seconds 180 --hitcount 4 --name DEFAULT --rsource -j DROP
iptables -t mangle -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

# DoS attack protection
iptables -t mangle -A INPUT -p tcp --dport 80 -m limit --limit 20/minute --limit-burst 50 -j ACCEPT

# add redirect rules for ports 465 and 587 (to let postfix run on different ports)
iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 25
iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 25



#reset the default policies to stop all incoming and forward requests
iptables -t mangle -P INPUT DROP
iptables -t mangle -P FORWARD DROP



#reject any other traffic after all rules
iptables -t mangle -A INPUT -j reject
iptables -t mangle -A INPUT -j reject


