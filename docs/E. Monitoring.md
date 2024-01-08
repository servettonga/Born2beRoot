# E. Monitoring

## Monitoring.sh

Write `monitoring.sh` file as root and put it in `/root` directory.

Check the following commands to figure out how to write the script:

- `uname` : architecture information
- `/proc/cpuinfo` : CPU information
- `free` : RAM information
- `df` : disk information
- `top -bn1` : process information
- `who` : boot and connected user information
- `lsblk` : partition and LVM information
- `/proc/net/sockstat` : TCP information
- `hostname` : hostname and IP information
- `ip link show` / `ip address` : IP and MAC information

Remember to give the script execution permissions, i.e.:

```shell
chmod 755 monitoring.sh
or
chmod +x monitoring.sh
```

The `wall` command allows us to broadcast a message to all users in all terminals. This can be incorporated into the monitoring.sh script or added later in cron.

To schedule the broadcast every 10 minutes, we need to enable cron:

```shell
systemctl enable cron
```

Then start a crontab file for root:

```shell
crontab -e
```

And add the job like this:

```shell
@reboot bash -l monitoring.sh
*/10 * * * * bash -l monitoring.sh
```

The `@reboot` directive tells `cron` to run the script at startup, and the `*/10 * * * *` directive tells `cron` to run the script every every 10 minutes throughout the hour. For example, it will run at 1:00, 1:10, 1:20, 1:30, and so on, until 1:50, and then it will start the same cycle in the next hour at 2:00, 2:10, etc.

See: [Crontab](./Commands%20and%20settings/Crontab.md), [crontab-generator](https://crontab-generator.org/), [crontab.guru](https://crontab.guru/)

From here, `monitoring.sh` will be executed every 10 minute.

```shell
sudo apt-get install net-tools
```

`monitoring.sh`

```shell
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
```

## Failed to send host log message

The error message that appears at VM boot, `[drm:vmw_host_log [vmwgfx]] ERROR Failed to send host log message` can easily be fixed. It is a graphics controller error. All we have to do is:

- Shut down VM
- In VirtualBox, go to VM settings
- `Display` >> `Screen` >> `Graphics Controller` >> Choose `VBoxVGA`.

---

Source: [https://github.com/mcombeau/Born2beroot/blob/main/guide/configuration_debian.md](https://github.com/mcombeau/Born2beroot/blob/main/guide/configuration_debian.md)
