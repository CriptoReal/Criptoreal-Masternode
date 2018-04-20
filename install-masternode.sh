#!/bin/bash
################################################################################
# Original Author:   Criptoreal DEV
#
# Web:     Criptoreal.org
#
# Program:
#   Install and run a Criptoreal Masternode
#
#   1) Updates VPS software
#   2) Creates and activates a 2GB Swap file
#   3) Sets up Firewall
#   4) Installs CRS daemon
#   5) Goves you the information you need to
#       start the masternode on your wallet.
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
output "Welcome to Criptoreal Automatic Masternode Setup"
output "Hold on, this may take a minute..."

    clear
    output ""
    output "Updating system and installing required packages."
    output ""

    # update package and upgrade Ubuntu
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get autoclean -y
    sudo apt-get -y autoremove
    clear


    output ""
    output "Creating Swap, this can take a acouple of minutes."
    output "Do not panic"
    sudo touch /var/swap.img
    sudo chmod 600 /var/swap.img
    sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
    mkswap /var/swap.img
    sudo swapon /var/swap.img
    sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
    clear


	# install UFW if it doesn't exist
    output "Setting up Firewall"
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
    sudo ufw logging on
    sudo ufw --force enable
    fi
   clear

    output "Installing Criptoreal Software."
    output ""
    sudo wget https://github.com/CriptoReal/Criptoreal/releases/download/v1.1.0/criptorealcore-1.1.0-linux64.tar.gz
    sudo tar -xvzf criptorealcore-1.1.0-linux64.tar.gz
    sudo rm criptorealcore-1.1.0-linux64.tar.gz
    sudo rm criptoreal-qt
    sudo rm criptoreal-tx
    sudo chmod +x criptoreal-cli criptoreald
    sudo mv criptoreal-cli criptoreald /usr/local/bin/
    clear

    #Making Criptoreal data Folder and Conf
    sudo mkdir  /root/.criptoreal

    # Get VPS IP Address
    VPSIP=$(curl ipinfo.io/ip)
    # create rpc user and password
    rpcuser=$(openssl rand -base64 24)
    # create rpc password
    rpcpassword=$(openssl rand -base64 48)

    echo -e "rpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\nmaxconnections=100\ndaemon=1\nrpcallowip=127.0.0.1\nexternalip=$VPSIP:5511" > /root/.criptoreal/criptoreal.conf

	 output "Starting Criptoreal Daemon"
	 output ""
	 sudo criptoreald
   sleep 10

   # create a masternode Key
   MNKEY=$(criptoreal-cli masternode genkey)

   sudo criptoreal-cli stop
   sleep 5

   echo -e "masternode=1\nmasternodeprivkey=$MNKEY" >> /root/.criptoreal/criptoreal.conf

   sudo criptoreald --daemon
   sleep 5
   clear

   output "Here is the information you need for masternode.conf"
	 output ""
   output "Masternode IP: $VPSIP:5511"
   output "Masternode Privkey: $MNKEY"
   output ""
	 output "All set!"
   output "You can now start this Masternode from your wallet ;-)"
   output "If you need help, contact us on discord: https://discord.gg/SUHcbyv"
