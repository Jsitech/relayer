#!/bin/bash

f_banner(){

echo
echo "

██████╗ ███████╗██╗      █████╗ ██╗   ██╗███████╗██████╗
██╔══██╗██╔════╝██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗
██████╔╝█████╗  ██║     ███████║ ╚████╔╝ █████╗  ██████╔╝
██╔══██╗██╔══╝  ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗
██║  ██║███████╗███████╗██║  ██║   ██║   ███████╗██║  ██║
╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝

SMB Relay Script
By Jason Soto "
echo
echo

}

echo "Checking dependencies for Relayer"

command -v responder >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo ""
  echo "Responder already installed"
else
  echo ""
  echo "Responder not installed, Installing"
  apt-get install responder
fi


command -v nmap >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo ""
  echo "Nmap already installed"
else
  echo ""
  echo "Nmap not installed, Installing"
  apt-get install nmap
fi


command -v smbrelayx.py >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo ""
  echo "smbrelayx already installed"
else
  echo ""
  echo "smbrelayx not installed, Cloning impacket and Setting up"
  git clone https://github.com/coresecurity/impacket
  pip install -r impacket/requirements.txt
  cd impacket/
  python setup.py install
  cd ..
fi


command -v msfconsole >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo ""
  echo "msfconsole already installed"
else
  echo ""
  echo "msfconsole not installed, Installing Metasploit-Framework"
  apt-get install metasploit-framework
fi


if [ -d unicorn/ ]; then
  echo ""
  echo "Unicorn is present"
else
  echo ""
  echo "Unicorn is not present, Cloning Unicorn"
  git clone https://github.com/trustedsec/unicorn
fi

echo ""
echo "Relayer is ready to Run"
