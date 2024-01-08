#!/bin/bash
# Bonus Setup Test

# Color definitions
set_red() {	tput setaf 1
}
set_green() { tput setaf 2
}
set_orange() { tput setaf 214
}
set_cyan() { tput setaf 45
}
reset_color() { tput sgr0
}

# Print functions
failed() { set_red && echo -e "FAILED: $1" && reset_color
}
passed() { set_green && echo -e "PASSED: $1" && reset_color
}
warning() { set_orange && echo -e "WARNING: $1" && reset_color
}
information() { set_cyan && echo -e "INFO: $1" && reset_color
}

information "Bonus setup test script"

# Check if the script is running as root
if [ ! "$(whoami)" = "root" ]; then
	warning "This script must be running as root in order to test properly."
	exit 1
fi

# Check if primary disk partition is at /root and not encrypted
if mount | grep -q '/dev/sda1 on /boot'; then
    passed "Primary disk partition is at /root"
else
    failed "Primary disk partition is not at /root"
fi

if ! sudo blkid /dev/sda1 | grep -q 'TYPE="crypto_LUKS"'; then
    passed "Primary disk partition is not encrypted"
else
    failed "Primary disk partition is encrypted"
fi

if [ "$(df --output=size /dev/sda1 | sed '1d')" -gt 102400 ]; then
    passed "Size of primary disk partition is above 100M"
else
    warning "Size of primary disk partition is below 100M"
fi

# Check if SWAP exists and encrypted
if [ "$(lsblk | grep 'swap' | awk '{print $7}')" = "[SWAP]" ]; then
	passed "Partition SWAP found at [SWAP]"
else
	failed "Partition SWAP not found at [SWAP]"
fi

if [ "$(lsblk | grep 'swap' | awk '{print $6}')" = "lvm" ]; then
	passed "Partition SWAP is encrypted"
else
	failed "Partition SWAP is not encrypted"
fi

# Check if the size is at least 1GB
swap_size_bytes=$(swapon --show=SIZE --bytes --noheadings)

if [ $((swap_size_bytes / (1024**3) )) -ge 1 ]; then
    passed "Size of swap partition is at least 1G"
else
    warning "Size of swap partition is less than 1G"
fi

# Check if logical partitions are encrypted LVM and mounted correctly
partitions=("home" "var" "srv" "tmp" "var-log")

for partition in "${partitions[@]}"; do
	exists=false
	# Chech if partition exists
	if [ "$(lsblk | grep -E "/${partition}($| )" | awk '{print $7}')" = "/${partition}" ]; then
		passed "Partition ${partition} found at /${partition}"
		exists=true
	else
		failed "Partition ${partition} not found at /${partition}"
	fi

	# Check if partition is encrypted
	if ${exists}; then
		if [ "$(lsblk | grep -E "/${partition}($| )" | awk '{print $6}')" = "lvm" ]; then
			passed "$partition is encrypted"
		else
			failed "$partition is not encrypted"
		fi

		# Check if partition size is at least 1G
		size=$(df | grep -E "/${partition}($| )" | awk '{print $2}')
		if [ -n "$size" ] && [ "$size" -ge 1000000 ]; then
			passed "Size of $partition is at least 1G"
		else
			warning "Size of $partition is less than 1G"
		fi
	fi
done

# Check if php installed
if dpkg -s php8.1 >/dev/null 2>&1; then
	passed "php8.1 is installed"
else
	failed "php8.1 is not installed"
fi

# Check if lighttpd installed and running
if dpkg -s lighttpd >/dev/null 2>&1; then
	passed "lighttpd is installed"
else
	failed "lighttpd is not installed"
fi

if pgrep lighttpd >/dev/null 2>&1; then
	passed "lighttpd is running"
else
	failed "lighttpd is not running"
fi

# Check if MariaDB installed and running
if dpkg -s mariadb-server >/dev/null 2>&1; then
	passed "MariaDB is installed"
else
	failed "MariaDB is not installed"
fi

if pgrep -f '/usr/sbin/mariadbd' > /dev/null; then
	passed "MySQL is running"
else
	failed "MySQL is not running"
fi

# Check if WordPress is installed in /var/www/html
if test -f /var/www/html/wp-config.php; then
    passed "The WordPress config file exists"
else
    failed "The WordPress config file does not exist"
fi

# Check if port 4242 and 80 are open for both IPv4 and IPv6
open_ports=$(sudo ufw status | grep -o "[0-9]*/tcp.*ALLOW.*" | cut -d' ' -f1)
expected_ports=("4242/tcp" "80/tcp" "443")

for port in "${expected_ports[@]}"; do
    if [[ "$open_ports" == *"$port"* ]]; then
        passed "Port $port is open."
    else
        failed "Port $port is not open."
    fi
done

warning "This test doesn't cover the optional service"
