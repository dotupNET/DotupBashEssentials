#!/bin/bash

STYLE_RESET='\033[0m'
STYLE_BOLD='\033[1m'
STYLE_BLACK='\033[30m'
STYLE_RED='\033[31m'	
STYLE_GREEN='\033[32m'
STYLE_YELLOW='\033[33m'
STYLE_BLUE='\033[34m'	
STYLE_MAGENTA='\033[35m'
STYLE_CYAN='\033[36m'
STYLE_WHITE='\033[37m'

recho() {
  echo -e "${STYLE_RED}${@}${STYLE_RESET}"
}

gecho() {
  echo -e "${STYLE_GREEN}${@}${STYLE_RESET}"
}

yecho() {
  echo -e "${STYLE_YELLOW}${@}${STYLE_RESET}"
}

# TryAddLine "My nice entry = oha" "/etc/apache2/" (sudo)
TryAddLine() {
  if [ "$3" = "sudo" ]; then
    sudo grep -qsF "$1" "$2" || echo "$1" | sudo tee -a "$2"
  else
    grep -qsF -- "$1" "$2" || echo "$1" >> "$2"
  fi
}

JoinWith() {
  local IFS="$1";
  shift;
  echo "$*";
}

SystemUpgrade() {
  sudo apt-get update -y && sudo apt-get upgrade -y
  CheckState;
}

AptInstall() {
	sudo apt-get -y install "$@"
}

# SetIniValue Sektion Key NewValue File
SetIniValue() {
#  sed -i "/^\[$1\]$/,/^\[/ s/^$2=/s/=.*/=$3/" $4
#  sed -i "(?<=\[Sky\])([^\[]*Color\s*=)(.+?)$"
#  sed -i.bak '/^\[test]/,/^\[/{s/^foo[[:space:]]*=.*/foo = foobarbaz/}' test1.ini
  if SudoRequired $4; then
    sudo sed -i "/^\[$1]/,/^\[/{s/^$2[[:space:]]*=.*/$2 = $3/}" $4
  else
    sed -i "/^\[$1]/,/^\[/{s/^$2[[:space:]]*=.*/$2 = $3/}" $4
  fi

#  sed -i "/^$2=/s/=.*/=$3/" $4
}

# SetValue Key NewValue File
SetValue () {
  var="$1"
  value="$2"
  if SudoRequired $3; then
    sudo sed -i -e '/^#\?\(\s*'${var//\//\\/}'\s*=\s*\).*/{s//\1'${value//\//\\/}'/;:a;n;ba;q}' -e '$a'${var//\//\\/}'='${value//\//\\/} "$3"
  else
    sed -i -e '/^#\?\(\s*'${var//\//\\/}'\s*=\s*\).*/{s//\1'${value//\//\\/}'/;:a;n;ba;q}' -e '$a'${var//\//\\/}'='${value//\//\\/} "$3"
  fi
}

# Comment Key File
Comment() {
    local regex="${1:?}"
    local file="${2:?}"
    local comment_mark="${3:-#}"
    if SudoRequired $file; then
      sudo sed -ri "s:^([ ]*)($regex):\\1$comment_mark\\2:" "$file"
    else
      sed -ri "s:^([ ]*)($regex):\\1$comment_mark\\2:" "$file"
    fi
}

# uncomment Key File
Uncomment() {
    local regex="${1:?}"
    local file="${2:?}"
    local comment_mark="${3:-#}"
    if SudoRequired $file; then
      sudo sed -ri "s:^([ ]*)[$comment_mark]+[ ]?([ ]*$regex):\\1\\2:" "$file"
    else
      sed -ri "s:^([ ]*)[$comment_mark]+[ ]?([ ]*$regex):\\1\\2:" "$file"
    fi
}

# AskYesNo "Are you sure?" n
AskYesNo() {
  local userInput
  local defaultAnswer
  local defaultHint
  local result
  # set default answer
  if [ -z "$2" ]; then
    defaultAnswer="y"
      defaultHint="[${STYLE_BOLD}Y${STYLE_RESET}/n]"
  else
    defaultAnswer="${2,,}"
    if [ $defaultAnswer = "y" ]; then 
      defaultHint="[${STYLE_BOLD}Y${STYLE_RESET}/n]"
    else 
      defaultHint="[y/${STYLE_BOLD}N${STYLE_RESET}]"
    fi
  fi

#  read -p "$1 $defaultHint" userInput
  userInput=$(ReadInput "$1 $defaultHint" $defaultAnswer)
  userInput="${userInput,,}"
  echo $userInput

  if [ $userInput = "y" ]; then 
    return 0
  else 
    return 1
  fi

}

# name=$(Ask "Enter your name?")
Ask() {
  local userInput
  local defaultAnswer
  local defaultHint
  # set default answer
  if [ -n "$2" ]; then
    defaultAnswer="$2"
    defaultHint="[$2]"
  fi

  while true; do
    if [ -n "$defaultHint" ]; then
      userInput=$(ReadInput "$1 $defaultHint" $defaultAnswer)
    else
      userInput=$(ReadInput "$1" $defaultAnswer)
    fi

    if [ -n "$userInput" ]; then
#      echo "${userInput,,}"
      echo "${userInput}"
      return 0
    else
      echo -e "${STYLE_YELLOW}Answer required!${STYLE_RESET}"
    fi
  done
}

# answer=$(ReadInput "Delete all folders? [y/N]" n)
ReadInput() {
  local input
  echo -e -n "${1}: " > /dev/tty
  read -p "" input
  if [ -z "$input" ]; then
    echo "$2"
  else
    echo "$input"
  fi
}

CheckState() {
  if [ $? -eq 0 ]; then
      return 0
  else
      echo -e "${STYLE_RED}Error ($?) occured.${STYLE_RESET}"
      return $?
  fi  
}

# CreateVirtualHost postfix home-gateway.ml 25344
# $1 = subdomain
# $2 = domain
# $3 = port
# $4 = alias / subfolder
# CreateHttpProxyPassVirtualHost() {
# file="/etc/apache2/sites-available/$1.$2.conf"
# sudo dd of=$file << EOF
# <VirtualHost *:$3>
#   ServerName $1.$2
#   SSLEngine on
#   ProxyPreserveHost On

#   SSLCertificateFile /etc/letsencrypt/live/$2/fullchain.pem
#   SSLCertificateKeyFile /etc/letsencrypt/live/$2/privkey.pem

#   ProxyPass /$4 !

#   ProxyPass / http://localhost/$4
#   ProxyPassReverse / http://localhost/$4
# </VirtualHost>
# EOF

# sudo a2ensite "$1.$2.conf"
# }

# ZipFolder /etc/letsencrypt/live/home-gateway.ml
ZipFolder() {
  if [ "$2" = "sudo" ]; then
    sudo zip -r "$(basename $1).zip" $1
  else
    zip -r "$(basename $1).zip" $1
  fi

}

# FileBackup /etc/apache2/sites-available/default-ssl.conf (sudo)
FileBackup() {
  if sudo [ ! -f $1 ]; then 
    recho "[ERROR]: file not found: $1"
    return
  fi 

  if [ "$2" = "sudo" ]; then
    sudo cp $1 "$1.$(date +%Y%m%d-%H%M%S)"
  else
    cp $1 "$1.$(date +%Y%m%d-%H%M%S)"
  fi
}

FileMove() {
  if sudo [ ! -f $1 ]; then 
    recho "[ERROR]: file not found: $1"
    return
  fi 

  if [ "$2" = "sudo" ]; then
    sudo mv $1 "$1.$(date +%Y%m%d-%H%M%S)"
  else
    mv $1 "$1.$(date +%Y%m%d-%H%M%S)"
  fi
}

SudoRequired() {
  if [ -w $1 ]; then
    return 1
  else
    return 0
  fi
}

EtcCommit() {

  if [ -z $SSH_AUTH_SOCK ]; then
    eval $(ssh-agent)
    ssh-add ~/.ssh/github_rsa
  fi

  sudo -E etckeeper commit "$@"
}

SysUsbInfo() {
  yecho "USB Devices:"
  lsusb
  echo ""
  lsblk
  echo ""
  df -h
}