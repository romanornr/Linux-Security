#!/bin/sh
# forked version of SecureIPtables.sh with modifications
# You need to Chmod this script before you run it.                 
# sudo chmod 777 SecureIPtables.sh                                 
# sudo chmod +x SecureIPtables.sh 
# Run with sudo to get full benefits                             
# 80, 25, 53, 443 and 22 open by Default, Can  be changed below.   

# ubuntu pernament rules
#sudo apt-get install iptables-persistent
#sudo netfilter-persistent save
#sudo netfilter-persistent reload

WEB=80
MAIL=25
DNS=53
SSL=443
SSH=22

#TCPBurstNew: of Packets a new connection can send in 1 request  

TCPBurstNew=400
TCPBurstEst=100

#TCPBurstEst:  of Packets an existing connection can send in 1 request.

# Extra Ports to be Bi-Directionally Opened (TCP) 
ExtraOne="yes"
ExtraOneP=8080

ExtraTwo="yes"
ExtraTwoP=6379

ExtraThree="false"
ExtraThreeP=0

echo "This script is planning on configuring IPTables on your behalf"
sleep 0.2
echo "The following ports are being configured"
sleep 0.2
echo "Your SSH Port will be: $SSH"
sleep 0.2
echo "Your DNS Port will be: $DNS"
sleep 0.2
echo "Your SSL Port will be: $SSL"
sleep 0.2
echo "Your MAIL Services SMTP Port will be: $MAIL"
sleep 0.2
echo "Your WEB SERVER port will be: $WEB"
sleep 0.2
echo "If these are not correct, Please press Ctrl + C NOW and edit with a Text Editor"


if [ "$ExtraOne" = "yes" ]
then
   echo "Opening Extra Port One: $ExtraOneP"
else
    echo "Not Using Extra Port One.."
fi
sleep 1
if [ "$ExtraTwo" = "yes" ]
then
   echo "Opening Extra Port Two: $ExtraTwoP"
else
    echo "Not Using Extra Port Two.."
fi
sleep 1
if [ "$ExtraThree" = "yes" ]
then
   echo "Opening Extra Port Three: $ExtraThreeP"
else
    echo "Not Using Extra Port Three.."
fi
echo "The installer will continue in 5"
sleep 1
echo "The installer will continue in 4"
sleep 1
echo "The installer will continue in 3"
sleep 1
echo "The installer will continue in 2"
sleep 1
echo "The installer will continue in 1"
sleep 1
echo "The script will now run to completion"
sleep 1

echo "Lets start by Flushing your old Rules."
sleep 1
sudo iptables -F
echo "Done!"
sleep 1

echo "We need to create the Default rule and Accept LoopBack Input."
sleep 1

sudo iptables -A INPUT -i lo -p all -j ACCEPT

echo "Done!"
sleep 1

echo "Enabling the 3 Way Hand Shake and limiting TCP Requests."
echo "IF YOU ARE USING CLOUD FLARE AND EXPERIENCE ISSUES INCREASE TCPBurst"
sleep 2

sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport $WEB -m state --state NEW -m limit --limit 50/minute --limit-burst $TCPBurstNew -j ACCEPT
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -m limit --limit 50/second --limit-burst $TCPBurstEst -j ACCEPT

echo "Done!"
sleep 1
echo "Adding Protection from LAND Attacks, If these IPs look required, please stop the script and alter it."

echo "10.0.0.0/8 DROP"
sleep 1
sudo iptables -A INPUT -s 10.0.0.0/8 -j DROP
echo "169.254.0.0/16 DROP"
sleep 1
sudo iptables -A INPUT -s 169.254.0.0/16 -j DROP
echo "172.16.0.0/12 DROP"
sleep 1
sudo iptables -A INPUT -s 172.16.0.0/12 -j DROP
echo "127.0.0.0/8 DROP"
sleep 1
sudo iptables -A INPUT -s 127.0.0.0/8 -j DROP
echo "192.168.0.0/24 DROP"
sleep 1
sudo iptables -A INPUT -s 192.168.0.0/24 -j DROP
echo "224.0.0.0/4 SOURCE DROP"
sleep 1
sudo iptables -A INPUT -s 224.0.0.0/4 -j DROP
echo "224.0.0.0/4 DEST DROP"
sleep 1
sudo iptables -A INPUT -d 224.0.0.0/4 -j DROP
echo "224.0.0.0/5 SOURCE DROP"
sleep 1
sudo iptables -A INPUT -s 240.0.0.0/5 -j DROP
echo "224.0.0.0/5 DEST DROP"
sleep 1
sudo iptables -A INPUT -d 240.0.0.0/5 -j DROP
echo "0.0.0.0/8 SOURCE DROP"
sleep 1
sudo iptables -A INPUT -s 0.0.0.0/8 -j DROP
echo "0.0.0.0/8 DEST DROP"
sleep 1
sudo iptables -A INPUT -d 0.0.0.0/8 -j DROP
echo "239.255.255.0/24 DROP SUBNETS"
sleep 1
sudo iptables -A INPUT -d 239.255.255.0/24 -j DROP
echo "255.255.255.255 DROP SUBNETS"
sleep 1
sudo iptables -A INPUT -d 255.255.255.255 -j DROP

echo "Done!"
sleep 1

echo "Lets stop ICMP SMURF Attacks at the Door."

sudo iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
sudo iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
sudo iptables -A INPUT -p icmp -m icmp --icmp-type 0 -m limit --limit 1/second -j ACCEPT

sleep 1
echo "Done!"

echo "Next were going to drop all INVALID packets."

sudo iptables -A INPUT -m state --state INVALID -j DROP
sudo iptables -A FORWARD -m state --state INVALID -j DROP
sudo iptables -A OUTPUT -m state --state INVALID -j DROP

sleep 1
echo "Done!"
echo "Next we drop VALID but INCOMPLETE packets. (Idk why this is even possible)"

sudo iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
sudo iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
sudo iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP 
sudo iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP 
sudo iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP 
sudo iptables -A INPUT -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP

sleep 1
echo "Done!"
echo "Now we're going to enable RST Flood Protection"

sudo iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

sleep 1
echo "Done!"
echo "Protection from Port Scans."
echo "Attacking IP will be locked for 24 hours (3600 x 24 = 86400 Seconds)"
sleep 1

sudo iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
sudo iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP

echo "Adjusting..."
echo "Banned IP addresses are removed from the list every 24 Hours."

sudo iptables -A INPUT -m recent --name portscan --remove
sudo iptables -A FORWARD -m recent --name portscan --remove

sleep 1
echo "Done!"
echo "Creating rules to add scanners to the PortScanner list and log the attempt. Remember to set up QUOTA"

sudo iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
sudo iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

sudo iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
sudo iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

sleep 1
echo "Done!"
echo "Lets block all incoming PINGS, Although they should be blocked already"

sudo iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j REJECT

sleep 1
echo "Done!"
echo "Allowing the following ports through from the outside"

echo "SMTP Port $MAIL"
sudo iptables -A INPUT -p tcp -m tcp --dport $MAIL -j ACCEPT

sleep 0.1
echo "Done!"

echo "Web Port $WEB"
sudo iptables -A INPUT -p tcp -m tcp --dport $WEB -j ACCEPT

sleep 0.1
echo "Done!"

echo "DNS Port $DNS"
sudo iptables -A INPUT -p udp -m udp --dport $DNS -j ACCEPT

sleep 1
echo "Done!"

echo "SSL Port $SSL"
sudo iptables -A INPUT -p tcp -m tcp --dport $SSL -j ACCEPT

sleep 1
echo "Done!"

echo "SSH Port $SSH"
sudo iptables -A INPUT -p tcp -m tcp --dport $SSH -j ACCEPT

sleep 1
echo "Done!"

if [ "$ExtraOne" = "yes" ]
then
   echo "Extra Port One Opened: $ExtraOneP"
   iptables -A INPUT -p tcp -m tcp --dport $ExtraOneP -j ACCEPT
else
    echo "INPUT RULES: Not Using Extra Port One!"
fi
sleep 0.2
if [ "$ExtraTwo" = "yes" ]
then
   echo "Extra Port Two Opened: $ExtraTwoP"
   iptables -A INPUT -p tcp -m tcp --dport $ExtraTwoP -j ACCEPT
else
    echo "INPUT RULES: Not Using Extra Port Two!"
fi
sleep 0.2
if [ "$ExtraThree" = "yes" ]
then
   echo "Extra Port Three Opened: $ExtraThreeP"
   iptables -A INPUT -p tcp -m tcp --dport $ExtraThreeP -j ACCEPT
else
    echo "INPUT RULES: Not Using Extra Port Three!"
fi

sleep 1
echo "Done Opening Ports For Web Access!"

echo "Lastly we block ALL OTHER INPUT TRAFFIC."
#sudo iptables -A INPUT -j REJECT

sleep 1
echo "Done!"

################# Below are OUTPUT iptables rules #############################################
echo "NOW LETS SET UP OUTPUTS"

echo "Default Rule for OUTPUT and our LoopBack Again. We wont be limiting outgoing traffic."
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

sleep 1
echo "Done!"

echo "Allowing the following ports Access OUT from the INSIDE"

echo "SMTP Port $MAIL"
iptables -A OUTPUT -p tcp -m tcp --dport $MAIL -j ACCEPT

sleep 2
echo "Done!"

echo "DNS Port $DNS"
iptables -A OUTPUT -p udp -m udp --dport $DNS -j ACCEPT

sleep 2
echo "Done!"

echo "Web Port $WEB"
iptables -A OUTPUT -p tcp -m tcp --dport $WEB -j ACCEPT

sleep 2
echo "Done!"

echo "HTTPS Port $SSL"
iptables -A OUTPUT -p tcp -m tcp --dport $SSL -j ACCEPT

sleep 2
echo "Done!"

echo "SSH Port $SSH"
iptables -A OUTPUT -p tcp -m tcp --dport $SSH -j ACCEPT

sleep 2

if [ "$ExtraOne" = "yes" ]
then
   echo "Extra Port One Opened: $ExtraOneP"
   iptables -A OUTPUT -p tcp -m tcp --dport $ExtraOneP -j ACCEPT
else
    echo "OUTPUT RULES: Not Using Extra Port One!"
fi

if [ "$ExtraTwo" = "yes" ]
then
   echo "OUTPUT RULES: Extra Port Two Opened: $ExtraTwoP"
   iptables -A OUTPUT -p tcp -m tcp --dport $ExtraTwoP -j ACCEPT
else
    echo "Not Using Extra Port Two!"
fi

if [ "$ExtraThree" = "yes" ]
then
   echo "OUTPUT RULES: Extra Port Three Opened: $ExtraThreeP"
   iptables -A OUTPUT -p tcp -m tcp --dport $ExtraThreeP -j ACCEPT
else
    echo "Not Using Extra Port Three!"
fi

sleep 2
echo "Done!"

echo "Allowing Outgoing PING Type ICMP Requests, So we don't break things."

iptables -A OUTPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

sleep 2
echo "Done!"

echo "Rejecting all other Output traffic"

#iptables -A OUTPUT -j REJECT

sleep 1
echo "Done!"

echo "Rejecting all Forwarding traffic"

iptables -A FORWARD -j REJECT

# whitelist CloudFlare IP
echo "whitelisting cloudflare IP's"
iptables -I INPUT -p tcp -m multiport --dports http,https -s "103.21.244.0/22" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "103.22.200.0/22" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "103.31.4.0/22" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "104.16.0.0/12" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "108.162.192.0/18" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "131.0.72.0/22" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "141.101.64.0/18" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "162.158.0.0/15" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "172.64.0.0/13" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "173.245.48.0/20" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "188.114.96.0/20" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "190.93.240.0/20" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "197.234.240.0/22" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "198.41.128.0/17" -j ACCEPT
sleep 2
iptables -I INPUT -p tcp -m multiport --dports http,https -s "199.27.128.0/21" -j ACCEPT
sleep 1
sleep 1
echo "Done!"
sleep 3
exit
