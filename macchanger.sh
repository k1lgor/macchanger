#!/bin/bash

# Display a welcome message with ASCII art
echo "██╗  ██╗ ██╗██╗      ██████╗  ██████╗ ██████╗ "
echo "██║ ██╔╝███║██║     ██╔════╝ ██╔═══██╗██╔══██╗."
echo "█████╔╝ ╚██║██║     ██║  ███╗██║   ██║██████╔╝."
echo "██╔═██╗  ██║██║     ██║   ██║██║   ██║██╔══██╗."
echo "██║  ██╗ ██║███████╗╚██████╔╝╚██████╔╝██║  ██║."
echo "╚═╝  ╚═╝ ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝."

# Check if the script is being run as root
if [ $EUID -ne 0 ]; then
    echo "ERROR ==================="
    echo "====>    Run it as root"
    echo "ERROR ==================="
    exit 1
fi

# Function to check if 'ifconfig' is installed and install it if necessary
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

# Function to check the user's operating system
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

# Main function to list all network interfaces except 'lo'
all_devices() {
    FILTER=""
    for i in $(ifconfig | egrep "\b([a-z0-9]+:)" | awk '{print$1}' | cut -d : -f 1); do
        if [ $i != 'lo' ]; then
            FILTER+=" $i"
        fi
    done
    
    FILTER_ARRAY=($FILTER)
}

# Function to list all network interfaces except 'lo' and their corresponding numbers
list_all_devices() {
    for i in ${FILTER_ARRAY[@]}; do
        echo -e "[$COUNTER] --> [$i]"
        ((COUNTER++))
    done
}

# Main function to change the MAC address of a selected network interface
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

# Call the necessary functions
check_ifconfig
checking_distro
all_devices
list_all_devices

# Prompt the user to choose a network interface by its number
echo "Choose your device by the number: [number]"
read NUMBER

# Call the function to change the MAC address of the selected network interface
change_mac
