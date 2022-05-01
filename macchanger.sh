#!/bin/bash

echo '██╗  ██╗ ██╗██╗      ██████╗  ██████╗ ██████╗ '
echo '██║ ██╔╝███║██║     ██╔════╝ ██╔═══██╗██╔══██╗'
echo '█████╔╝ ╚██║██║     ██║  ███╗██║   ██║██████╔╝'
echo '██╔═██╗  ██║██║     ██║   ██║██║   ██║██╔══██╗'
echo '██║  ██╗ ██║███████╗╚██████╔╝╚██████╔╝██║  ██║'
echo '╚═╝  ╚═╝ ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝'

if [ $EUID -ne 0 ]; then
  echo 'ERROR ==================='
  echo '====>    Run it as root'
  echo 'ERROR ==================='
  exit 1
fi

check_ifconfig() {
  type ifconfig &>/dev/null
  if [ $? -ne 0 ]; then
    case $DISTRO in
    "arch")
      yes | pacman -S net-tools
      ;;
    "debian")
      apt install -y net-tools
      ;;
    "fedora")
      dnf install -y net-tools
      ;;
    "rhel")
      yum install -y net-tools
      ;;
    "suse")
      zypper install -y net-tools
      ;;
    esac
  fi
}

check_ifconfig

FILTER=$(
  ifconfig | egrep "\b([a-z0-9]+:)" | awk '{print$1}' | cut -d : -f 1 | grep [^etherinet46]
)
FILTER_ARRAY=()
COUNTER=1
DISTRO=''

checking_distro() {
  grep -i arch /etc/os-release &>/dev/null
  if [ $? -eq 0 ]; then
    DISTRO=arch
  fi

  egrep -iw 'debian|ubuntu|kali' /etc/os-release &>/dev/null
  if [ $? -eq 0 ]; then
    DISTRO=debian
  fi

  grep -i rhel /etc/os-release &>/dev/null
  if [ $? -eq 0 ]; then
    DISTRO=rhel
  fi

  grep -i suse /etc/os-release &>/dev/null
  if [ $? -eq 0 ]; then
    DISTRO=suse
  fi

  grep -i fedora /etc/os-release &>/dev/null
  if [ $? -eq 0 ]; then
    DISTRO=fedora
  fi
}

checking_distro

all_devices() {
  for i in $FILTER; do
    if [ $i != 'lo' ]; then
      FILTER_ARRAY+=($i)
    fi
  done
}

list_all_devices() {
  for i in ${FILTER_ARRAY[@]}; do
    echo -e "[$COUNTER] --> [$i]"
    ((COUNTER++))
  done
}

all_devices
list_all_devices

TOTAL_DEVICES=${#FILTER_ARRAY[@]}

echo "Choose your device by the number: [number]"
read NUMBER

change_mac() {
  type macchanger &>/dev/null
  if [ $? -ne 0 ]; then
    case $DISTRO in
    "arch")
      yes | pacman -S macchanger
      ;;
    "debian")
      apt install -y macchanger
      ;;
    "fedora")
      dnf install -y macchanger
      ;;
    "rhel")
      yum install -y macchanger
      ;;
    "suse")
      zypper install -y macchanger
      ;;
    esac
  fi
  ifconfig ${FILTER_ARRAY[$NUMBER - 1]} down
  macchanger -r ${FILTER_ARRAY[$NUMBER - 1]}
  ifconfig ${FILTER_ARRAY[$NUMBER - 1]} up
  macchanger -s
}

change_mac
