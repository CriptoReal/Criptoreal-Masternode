#!/bin/bash
################################################################################
# Original Author:   Criptoreal DEV
#
# Web:     Criptoreal.org
#
# Program:
#   Install and run a Criptoreal Masternode
#
#
################################################################################
output() {
    printf "\E[0;33;40m"
    echo $1
    printf "\E[0m"
}

displayErr() {
    echo
    echo $1;
    echo
    exit 1;
}
clear
output "Make sure you double check before hitting enter! Only one shot at these!"
output ""
    read -e -p "Enter The Masternode Key from masternode genkey : " MNKEY
    read -e -p "Enter This Server IP Address : " VPSIP

    clear
    output ""
    output "Updating system and installing required packages."
    output ""

    # update package and upgrade Ubuntu
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove
    clear

	# uinstall UFW if it doesn't exist
    output "Installing Firewall"
     output ""
    if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
    sudo aptitude -y install fail2ban
    fi
    if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
    sudo apt-get install ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw limit ssh
    sudo ufw allow 5511/tcp
    sudo ufw --force enable
    fi
   clear

    output "Installing Criptoreal."
    output ""
   sudo wget https://github.com/CriptoReal/Criptoreal/releases/download/v1.1.0/criptorealcore-1.1.0-linux64.tar.gz
    sudo tar -xvzf criptorealcore-1.1.0-linux64.tar.gz
    sudo rm criptorealcore-1.1.0-linux64.tar.gz
    sudo rm criptoreal-qt
    sudo rm criptoreal-tx
    sudo chmod +x criptoreal-cli criptoreald
    sudo mv criptoreal-cli criptoreald /usr/local/bin/
    #Making Criptoreal data Folder and Conf
    sudo mkdir  /root/.criptoreal

    # create rpc user and password
    rpcuser=$(openssl rand -base64 24)
    # create rpc password
    rpcpassword=$(openssl rand -base64 48)


    echo "rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcallowip=127.0.0.1
server=1
listen=1
daemon=1
maxconnections=100
masternode=1
masternodeprivkey=$MNKEY
externalip=$VPSIP:5511 " >> /root/.criptoreal/criptoreal.conf


	 output "Starting Criptoreal Daemon"
	 output ""
	 sudo criptoreald
	 clear
	 output "Done! Now you can start this Masternode from your wallet :)"
	 output ""


