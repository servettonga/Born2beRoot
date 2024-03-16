#!/bin/bash
# Base Setup Tests

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

information "Base setup test script"

# Check if the script is running as root
if [ ! "$(whoami)" = "root" ]; then
	warning "This script must be running as root in order to test properly."
	exit 1
fi

# Get a list of all logical volumes
lv_list=$(sudo lvdisplay)

# Count the number of encrypted volumes
encrypted_count=$(echo "$lv_list" | grep -c "LV Status              available")

if [ "$encrypted_count" -ge 2 ]; then
    passed "At least 2 encrypted partitions using LVM are created."
else
    failed "Less than 2 encrypted partitions using LVM are created."
fi

# Check for the X server
if ! command -v Xorg >/dev/null 2>&1; then
    passed "No GUI is installed on this system."
else
    failed "A GUI is installed on this system."
fi

# Check if SSH is running on port 4242
ssh_check=$(sudo lsof -i :4242 | grep sshd)

if [ -n "$ssh_check" ]; then
    passed "SSH is running on port 4242."
else
    failed "SSH is not running on port 4242."
fi

# Check if root login is disabled
root_login=$(sudo grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')

if [ "$root_login" == "no" ]; then
    passed "Root login is disabled."
else
    failed "Root login is enabled"
fi

# Check if UFW is enabled
ufw_status=$(sudo ufw status | grep -o "^Status: .*" | cut -d' ' -f2)

if [ "$ufw_status" == "active" ]; then
    passed "UFW firewall is on."
else
    failed "UFW firewall is off."
fi

# Check if ports 4242 and 80 are open for both IPv4 and IPv6
open_ports=$(sudo ufw status | grep -o "[0-9]*.*ALLOW.*" | cut -d' ' -f1)
expected_ports=("4242/tcp" "80/tcp" "443")

for port in "${expected_ports[@]}"; do
    if [[ "$open_ports" == *"$port"* ]]; then
        passed "Port $port is open."
    else
        failed "Port $port is not open."
    fi
done

# Get the username and hostname
username=$SUDO_USER
hostname=$(hostname)

# Check if the hostname is the username followed by "42"
if [ "$hostname" = "$username"42 ]; then
    passed "The hostname is the username followed by '42'."
else
    failed "The hostname is not the username followed by '42'."
fi

# Check if the user belongs to the "user42" group
if getent group user42 | grep -wq "${username}"; then
    passed "The user belongs to the 'user42' group."
else
    failed "The user does not belong to the 'user42' group."
fi

# Check if the user belongs to the "sudo" group
if getent group sudo | grep -wq "${username}"; then
    passed "The user belongs to the 'sudo' group."
else
    failed "The user does not belong to the 'sudo' group."
fi

# Check if PASS_MAX_DAYS is set to 30
if grep -q "^PASS_MAX_DAYS 30" /etc/login.defs; then
    passed "Password is set to expire every 30 days"
else
    failed "Password is not set to expire every 30 days"
fi

# Check if PASS_MIN_DAYS is set to 2
if grep -q "^PASS_MIN_DAYS 2" /etc/login.defs; then
    passed "The minimum number of days allowed before the modification is set to 2"
else
    failed "The minimum number of days allowed before the modification is not set to 2"
fi

# Check if PASS_WARN_AGE is set to 7
if grep -q "^PASS_WARN_AGE 7" /etc/login.defs; then
    passed "Password expiration warning is set to 7 days"
else
    failed "Password expiration warning is not set to 7 days"
fi

# Check password policy
minlen=$(sudo grep "^minlen" /etc/security/pwquality.conf | awk '{print $3}')
ucredit=$(sudo grep "^ucredit" /etc/security/pwquality.conf | awk '{print $3}')
dcredit=$(sudo grep "^dcredit" /etc/security/pwquality.conf | awk '{print $3}')
maxrepeat=$(sudo grep "^maxrepeat" /etc/security/pwquality.conf | awk '{print $3}')
usercheck=$(sudo grep "^usercheck" /etc/security/pwquality.conf | awk '{print $3}')
enforce_for_root=$(sudo grep "^enforce_for_root" /etc/security/pwquality.conf | awk '{print $1}')
retry=$(sudo grep "^retry" /etc/security/pwquality.conf | awk '{print $3}')

if [ "$minlen" -ge 10 ]; then
    passed "Password is at least 10 characters long"
else
    failed "Password is not at least 10 characters long"
fi

if [ "$ucredit" -le -1 ]; then
    passed "Password contains at least one uppercase letter"
else
    failed "Password does not contain at least one uppercase letter"
fi

if [ "$dcredit" -le -1 ]; then
    passed "Password contains at least one number"
else
    failed "Password does not contain at least one number"
fi

if [ "$maxrepeat" -le 3 ]; then
    passed "Password does not contain more than 3 consecutive identical characters"
else
    failed "Password contains more than 3 consecutive identical characters"
fi

if [ "$usercheck" -le 1 ]; then
    passed "Password can not include the name of the user"
else
    failed "Password can include the name of the user"
fi

if [ "$enforce_for_root" = "enforce_for_root" ]; then
	passed "Returns error on failed check if the user changing the password is root"
else
    failed "Doesn't return error on failed check if the user changing the password is root"
fi

if [ "$retry" -le 3 ]; then
    passed "Password attempt is limited by 3"
else
    failed "Password attempt is limited by 3"
fi

# Test sudo group configuration
if sudo grep -Eq "Defaults\s+logfile=/var/log/sudo/.*" /etc/sudoers; then
    passed "The log file is set to be saved in the /var/log/sudo/ folder."
else
    failed "The log file is not set."
fi

if sudo grep -Eq "Defaults\s+log_input,log_output" /etc/sudoers; then
    passed "sudo actions are set to be archived."
else
    failed "sudo actions are not set to be archived."
fi

if sudo grep -Eq "Defaults\s+passwd_tries=3" /etc/sudoers; then
    passed "Authentication using sudo is limited to 3 attempts"
else
    failed "Authentication using sudo is no limited to 3 attempts"
fi

if sudo grep -Eq 'Defaults\s+badpass_message=".*"' /etc/sudoers; then
    passed "A custom message is set to be displayed"
else
    failed "Couldn't find any message to be displayed"
fi

if sudo grep -Eq 'Defaults\s+secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"' /etc/sudoers; then
    passed "The paths that can be used by sudo are restricted"
else
    failed "The paths that can be used by sudo are not restricted"
fi

if sudo grep -Eq "Defaults\s+requiretty" /etc/sudoers; then
    passed "The TTY mode is required"
else
    failed "The TTY mode is not required"
fi

# Check if monitoring.sh exists in the /root directory
if sudo test -f /root/monitoring.sh; then
    passed "The monitoring.sh file exists in the /root directory"
else
    failed "The monitoring.sh couldn't be found in the /root directory"
fi

# Check if cron is running
if systemctl is-enabled --quiet cron; then
    passed "Cron service is enabled"
else
    failed "Cron service is not enabled"
fi

if systemctl is-active --quiet cron; then
    passed "Cron service is running"
else
    failed "Cron service is not running"
fi

if [ -n "$(crontab -l)" ]; then
    passed "There is at least one task in the crontab"
else
    failed "There are no tasks in the crontab"
fi

warning "This test doesn't cover the contents of monitoring.sh"
