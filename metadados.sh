#!/bin/bash

RED='\033[31;1m'
GREEN='\033[32;1m'
BLUE='\033[34;1m'
YELLOW='\033[33;1m'
END='\033[m'

VERSION='1.0'

ARG1=$1
ARG2=$2

trap __Ctrl_c__ INT

__Ctrl_c__() {
    __ClearFolder__
    echo -e "${RED}\n\nAção abortada!\n\n${END}"
    exit 1
}

__Banner__() {
    echo
    echo -e "${YELLOW}#################################################################################${END}"
    echo -e "${YELLOW}#                                                                               #${END}"
    echo -e "${YELLOW}#                             METADADOS                                         #${END}"
    echo -e "${YELLOW}#                             By: Vszn                                          #${END}"
    echo -e "${YELLOW}#                             Version: $VERSION                                      #${END}"
    echo -e "${YELLOW}#                                                                               #${END}"
    echo -e "${YELLOW}#################################################################################${END}"
    echo
    echo -e "Usage   : ${GREEN}$0${END} [URL] [Extension]"
    echo -e "Example : ${GREEN}$0${END} www.site.com pdf"
    echo -e "Extensions : ${BLUE}pdf,doc,docx,xls,xlsx,ppt,pttx${END}"
    echo
}


__Verification__() {
    if ! [[ -e /usr/bin/lynx ]]; then
        printf "\nFaltando programa lynx para funcionar.\n"
        exit 1
    elif ! [[ -e /usr/bin/exiftool ]]; then
        echo -e "\nFaltando programa exiftool para funcionar.\n"
        exit 1
    fi

    if [[ "$ARG1" == "" ]]; then
        __Banner__
        exit 1
    fi
}

__ClearFolder__() {
    rm -rf /tmp/metadados &>/dev/null
}

__FindFiles__(){
    __ClearFolder__
    mkdir /tmp/metadados && cd /tmp/metadados

    lynx --dump "https://google.com/search?&q=site:$ARG1+ext:pdf" | grep ".$ARG2" | cut -d "=" -f2 | egrep -v "site|google" | sed 's/...$//' > Files
}

__DownloadFiles__() {
    for url in $(cat Files); do
        wget -q -c --show-progress $url
        printf "${GREEN}[+] Download Completo\n${END}"
    done
}

__Metadado__() {
    exiftool *.$ARG2 | sed 's/image files read/Arquivos encontrados./'
}


__Main__() {
__Verification__

__FindFiles__
__DownloadFiles__
__Metadado__
__ClearFolder__
}


__Main__
