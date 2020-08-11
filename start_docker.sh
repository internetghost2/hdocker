#!/bin/bash 

function ctrl_c(){
    tput cnorm
    rm machines.table 2>/dev/null
    echo -e "\n\n[!] Exiting..."
    exit 1
}

function helpPannel(){
    echo "[?] Usage: $0 -n [name_machine] -l"
}

## S4vitar Code
function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}


##
function list_machines(){
    machines=$(sudo docker ps -a | awk 'NF>1{print $NF","$2}' | tail -n+2)
    echo -e "ID,Name,Image" > machines.table
    echo -e "Containers names: \n"
    counter=1
    for containers in $machines; do
        echo -e "[$counter],$containers" >> machines.table
        ((counter=$counter + 1))
    done
    for list in $(cat machines.table); do
        printTable "," $list        
    done 
    tput cnorm; echo -n "[*]  Select container: "; read container_number; tput civis
    
    local -r container=$(($container_number + 1))
    
    local -r container_selected=$(cat machines.table | awk '{print $2}' FS="," | head -n $container | tail -n 1) 
   
    rm machines.table
    start_machine $container_selected

}

function start_machine(){
   
    local -r machine=$1
    if [[ $(sudo docker ps -a | awk 'NF>1{print $NF}' | grep "^$machine$") ]]; then
        echo -e "[*] Starting container $machine ..."
        sudo docker start $machine
        sudo docker exec -it $machine zsh
    else
        echo -e "The $machine container doesn't exist..."
        tput cnorm; echo -n "Do you want list containers? [Y/n]: " ; read question; tput civis
        if [[ $question == 'Y' ]] || [[ $question=='y' ]]; then
            list_machines
        else
            tput cnorm; rm machines.table 2>/dev/null
            echo -e "\n\n[!] Exiting..."
            exit 0
        fi
    fi

   }

function main(){
     if [[ $(pgrep docker) ]]; then
        echo -e "[*] Opennig docker service ..."
        sudo systemctl start docker
    fi

 }

tput civis;main

declare -i parameter_counter=0; while getopts "ln:" arg; do
      case $arg in
          l) list_machines;;
          n) name=$OPTARG; let parameter_counter+=1;
              start_machine $name;;
          *) helpPannel;;
      esac
done


