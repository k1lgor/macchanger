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

FILTER=$(
  ifconfig | egrep "\b([a-z0-9]+:)" | awk '{print$1}' | cut -d : -f 1 | grep [^ether]
)
FILTER_ARRAY=()
COUNTER=1

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
  ip link set dev ${FILTER_ARRAY[$NUMBER]} down
  macchanger -r ${FILTER_ARRAY[$NUMBER]}
  ip link set dev ${FILTER_ARRAY[$NUMBER]} up
  macchanger -s
}

change_mac
