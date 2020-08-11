#!/bin/bash

##Variables 
#name = nombre de la maquina 
#ty = tipo de maquina (Hackthebox - TryHackMe - ...)
#dockername = nombre de la docker ( dafault = marchortelano/pentestkali ) 
#IP machine = default - 


function helpPanel(){
	echo "[?] Usage : $0 -n [machine_name] -i [ip]"
}
	

function EscojerTipoHacking(){
	echo -e "Escoje un número: "
	echo -e "1 - HackTheBox"
	echo -e "2 - TryHackMe"
	echo -e "3 - BugBounty "
    echo -e "4 - Others"
	echo -e "Introduce numero: " ; read num
}

function main(){
    
    
    if [[ $1 -eq 2 ]];then
        EscojerTipoHacking
        if [[ $num -eq 1 ]];then
            # HTB
            mkdir -p /mnt/docker/kali/HTB/$name/work && sudo docker run -ti --name $name --cap-add=NET_ADMIN --device /dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0 -v /mnt/docker/kali/HTB/$name/work:/work marchortelano/pentestkali bash -c "cp ~/.zshrc ~/.zshrc.temp; cat ~/.zshrc.temp | sed 's/USER_NAME/$name/g;s/DOMAIN_NAME/HackTheBox/g;s/MACHINE_IP/$ip/g' > ~/.zshrc; zsh"; sudo cp /home/jack/Hacking/VPN/HTB/jackdel21.ovpn /mnt/docker/kali/HTB/$name/work/

        elif [[ $num -eq 2  ]];then
            # TryHackMe
            sudo docker run -ti --rm --cap-add=NET_ADMIN --device /dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0 -v /mnt/docker/kali/THM/work:/work marchortelano/pentestkali bash -c "cp ~/.zshrc ~/.zshrc.temp; cat ~/.zshrc.temp | sed 's/USER_NAME/$name/g;s/DOMAIN_NAME/TryHackMe/g;s/MACHINE_IP/$ip/g' > ~/.zshrc; zsh"
        elif [[ $num -eq 3 ]]; then
            # BugBounty
            sudo docker run -ti --name $ty_$name -v /mnt/docker/BugBounty/Bounties/$name/docker:/work marchortelano/bugbounty
        elif [[ $num -eq 4 ]]; then
            sudo docker run -ti --rm --cap-add=NET_ADMIN --device /dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=0 marchortelano/pentestkali bash -c "cp ~/.zshrc ~/.zshrc.temp; cat ~/.zshrc.temp | sed 's/USER_NAME/$name/g;s/DOMAIN_NAME/HackTheBox/g;s/MACHINE_IP/$ip/g' > ~/.zshrc; zsh"
        else 
            echo -e "\n[*] Error, opcion incorrecta..."
            return 1
        fi
    else
        helpPanel
    fi
}

declare -i parameter_counter=0; while getopts ":n:i:d:" arg; do
        case $arg in
        	n) name=$OPTARG; let parameter_counter+=1;;
        	i) ip=$OPTARG; let parameter_counter+=1;;
        	*) helpPanel;;
        esac
done

main parameter_counter $name $ip
