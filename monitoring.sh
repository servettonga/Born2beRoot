#!/bin/bash
# This script displays various system information
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root

# Get the system architecture, kernel version, and other details
ARCH=$(uname -srvmo)

# Get the number of physical CPUs
PCPU=$(lscpu | grep 'Socket(s):' | awk '{print $2}')

# Get the number of virtual CPUs
VCPU=$(nproc)

# Get the total and used RAM, and calculate the percentage of RAM used
RAM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
RAM_USED=$(free -h | grep Mem | awk '{print $3}')
RAM_PERC=$(free -k | grep Mem | awk '{printf("%.2f%%"), $3 / $2 * 100}')

# Get the total and used disk space, and calculate the percentage of disk space used
DISK_TOTAL=$(df -h --total | grep total | awk '{print $2}')
DISK_USED=$(df -h --total | grep total | awk '{print $3}')
DISK_PERC=$(df -k --total | grep total | awk '{print $5}')

# Get the CPU load
CPU_LOAD=$(top -bn1 | grep '^%Cpu' | xargs | awk '{printf("%.1f%%"), $2 + $4}')

# Get the date and time of the last boot
LAST_BOOT=$(who -b | awk '{print $3, $4}')

# Check if LVM is active
LVM=$(if [ "$(lsblk | grep -c lvm)" -eq 0 ]; then printf "no"; else printf "yes"; fi)

# Get the number of established TCP connections
TCP=$(netstat -tn | grep -c 'ESTABLISHED')

# Get the number of users logged in
USER_LOG=$(who | wc -l)

# Get the IP and MAC addresses
IP_ADDR=$(hostname -I | awk '{print $1}')
MAC_ADDR=$(ip link show | grep link/ether | awk '{print $2}')

# Get the number of commands executed with sudo
SUDO_LOG=$(journalctl _COMM=sudo | wc -l)

# Display the information
OUTPUT="
      -----------------------------------------------
                    System Information
      -----------------------------------------------
      Architecture     : $ARCH
      Physical CPU     : $PCPU
      vCPU             : $VCPU
      Memory Usage     : $RAM_USED/$RAM_TOTAL ($RAM_PERC)
      Disk Usage       : $DISK_USED/$DISK_TOTAL ($DISK_PERC)
      CPU Load         : $CPU_LOAD
      Last Boot        : $LAST_BOOT
      LVM use          : $LVM
      TCP Connections  : $TCP established
      Users logged     : $USER_LOG
      Network          : $IP_ADDR ($MAC_ADDR)
      Sudo             : $SUDO_LOG commands used
      -----------------------------------------------"

wall "${OUTPUT}"

# To test web server by showing some info
echo "${OUTPUT}" > /var/www/html/sysinfo.txt
