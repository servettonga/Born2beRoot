#!/bin/bash
# Base Setup Configurator

# Exit if any command fails
set -e

# Variables
USERNAME=$SUDO_USER
HOSTNAME=$(hostname)
SUDO=false

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
invalid() { set_red && echo -e "$1" && reset_color
}
valid() { set_green && echo -e "$1" && reset_color
}
warning() { set_orange && echo -e "$1" && reset_color
}
information() { set_cyan && echo -e "$1" && reset_color
}

# Check if sudo is installed
if ! command -v sudo &> /dev/null
then
    invalid "'sudo' could not be found, install it by following commands:"
    printf "
    1. Login as root 'su -'\n
    2. Type your root password\n
	3. 'apt update && apt upgrade && apt install sudo'\n
    4. Add your 'username' to sudo group:\n
       'sudo usermod -aG sudo <username>'\n
    5. 'exit' and 'exit' again to relogin\n
    \n
    You can test it by typing 'sudo echo Hello'\n
    Or 'sudo whoami' should show 'root'\n
    If not, you can edit /etc/sudoers file\n
    Add your user '<username> ALL=(ALL:ALL) ALL'\n
	It should be ready now, run the script as sudo user.\n"
    exit 0
fi

# Check if the script is running as root
if [ ! "$(whoami)" = "root" ]; then
	warning "This script must be running as root in order to operate properly."
	exit 1
fi

timeout 2 sudo id >/dev/null 2>&1 && SUDO="Yes" || SUDO="No"

configure_sudo() {
	# Configure sudo
    information "Configuring sudo"
	sudo mkdir /var/log/sudo/ -p
    # Define the changes
    changes=(
    'Defaults        logfile=/var/log/sudo/sudo.log'
    'Defaults        log_input,log_output'
    'Defaults        passwd_tries=3'
    'Defaults        badpass_message="Wrong password! Please try again."'
    'Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"'
    'Defaults        requiretty'
    )
    # Check each change
    for change in "${changes[@]}"; do
        if ! sudo grep -q "$change" /etc/sudoers; then
            echo "Added: $change"
            echo "$change" | sudo tee -a /etc/sudoers > /dev/null
        fi
    done

    valid "Done."
    echo ""
}

configure_groups() {
    information "Creating groups"
    if getent group user42 > /dev/null 2>&1; then
        echo "The group 'user42' exists."
    else
        sudo groupadd user42
    fi
    # Add the current user to sudo groups:
    information "Adding the current user to sudo groups"
    sudo usermod -aG sudo,user42 "${USERNAME}"
    echo 'Actual groups:'
    groups
    valid "Done."
    echo ""
}

set_hostname() {
    # Set hostname
    information "Setting the hostname"
    hostnamectl set-hostname "${USERNAME}42"
    echo 'The current hostname:'
    hostnamectl status
    valid "Done."
    echo ""
}

install_packages() {
    # Install necessary packages
    information "Installing requried packages"
    sudo apt-get install -y openssh-server ufw libpam-pwquality net-tools
    valid "Done."
    echo ""
}

configure_ssh() {
    # Configure SSH
    information "Configuring ssh server"
    if ! dpkg -s openssh-server >/dev/null 2>&1; then
        information "openssh-server is not installed, trying to install it now"
        sudo apt-get install -y openssh-server
    fi
    information "Setting sshd_config"
    {
        echo 'Port 4242'
        echo 'PermitRootLogin no'
        echo 'PasswordAuthentication yes'
        echo 'ClientAliveInterval 120'
    } | sudo tee /etc/ssh/sshd_config >/dev/null
    warning "Login by using port 4242: ssh $USERNAME@localhost -p 4242"

    # Restart SSH
    echo 'Restarting ssh service'
    sudo systemctl restart ssh
    valid "Done."
    echo ""
}

configure_ufw() {
    # Configure UFW
    information "Configuring UFW"
    if ! dpkg -s ufw >/dev/null 2>&1; then
        information "ufw is not installed, trying to install it now"
        sudo apt-get install -y ufw
    fi
    information "Setting UFW to allow 4242 and 80(http)/443(https) TCP Ports"
	sudo ufw --force disable
	sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 4242/tcp
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw --force enable
    sleep 2
    echo 'UFW Status:'
    sudo ufw status

    # Restart SSH
    echo 'Restarting ssh service'
    sudo systemctl restart ssh

    valid "Done."
    echo ""
}

configure_password() {
    # Configure PAM for password policy
    information "Configuring password policy with PAM"
    if ! dpkg -s libpam-pwquality >/dev/null 2>&1; then
        echo "libpam-pwquality is not installed, trying to install it now"
        sudo apt-get install -y libpam-pwquality
    fi

    # Modify /etc/login.defs
    information "Modifying /etc/login.defs"
    sudo bash -c "sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 30/' /etc/login.defs && \
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 2/' /etc/login.defs && \
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs && \
    sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 7/' /etc/login.defs"

    # Apply changes to existing users
    information "Applying changes to existing users"
    while IFS= read -r user
    do
        sudo chage -M 30 -m 2 -W 7 "$user"
    done < <(cut -d: -f1 /etc/passwd)
    echo "Password aging controls updated successfully."

    # Modify /etc/security/pwquality.conf for password quality verification library
    information "Modifying /etc/security/pwquality.conf"
    sudo bash -c "sed -i 's/^# *minlen *=.*/minlen = 10/' /etc/security/pwquality.conf && \
    sed -i 's/^# *dcredit *=.*/dcredit = -1/' /etc/security/pwquality.conf && \
    sed -i 's/^# *ucredit *=.*/ucredit = -1/' /etc/security/pwquality.conf && \
    sed -i 's/^# *maxrepeat *=.*/maxrepeat = 3/' /etc/security/pwquality.conf && \
    sed -i 's/^# *difok *=.*/difok = 7/' /etc/security/pwquality.conf && \
    sed -i 's/^# *usercheck *=.*/usercheck = 1/' /etc/security/pwquality.conf && \
    sed -i 's/^# *retry *=.*/retry = 3/' /etc/security/pwquality.conf && \
    sed -i 's/^# *enforce_for_root.*/enforce_for_root/' /etc/security/pwquality.conf"

    valid "Done."
    echo ""
}

monitoring() {
    information "Setting monitoring.sh"
    if [ -f monitoring.sh ]; then
        sudo chmod 755 monitoring.sh
        sudo cp monitoring.sh /root/
        warning "Run crontab -e command as root to edit jobs and add following lines to run it every 10 minutes:"
        echo "@reboot bash -l monitoring.sh"
        echo "*/10 * * * * bash -l monitoring.sh"
        echo ""
        echo "You can enable cron by: systemctl enable cron"
    else
        invalid "The file monitoring.sh does not exist. Create/copy it to the same location as this script."
    fi
    valid "Done."
    echo ""
}

while true;
do
	clear
	# Print current user's information
	set_cyan
	printf "Current user:\n
	\tUsername:\t%s\n
	\tSudo:\t\t%s\n
	\tHostname:\t%s\n\v" "${SUDO_USER}" "${SUDO}" "${HOSTNAME}"

	set_orange
	printf "\vPlease select a configuration to run:\n"
	reset_color
	printf "
	\t1) Configure sudo\n
	\t2) Configure groups\n
	\t3) Set the hostname\n
	\t4) Install required packages\n
	\t5) Configre sshd_config\n
	\t6) Configure UFW\n
	\t7) Set password policy\n
	\t8) monitoring.sh instructions\n
	\t9) All\n
	\t0) Exit\n\v"

	read -rp "Enter the number of your choice: " choice

    case $choice in
        1)
            configure_sudo;	break ;;
		2)
            configure_groups; break ;;
		3)
            set_hostname; break ;;
		4)
            install_packages; break ;;
		5)
            configure_ssh; break ;;
		6)
            configure_ufw; break ;;
		7)
            configure_password; break ;;
		8)
            monitoring; break ;;
		9)
        	configure_groups
			configure_sudo
			set_hostname
			install_packages
			configure_ssh
			configure_ufw
			configure_password
			monitoring
			break ;;
        0)
            exit 0;
        ;;
        *)
            invalid "Invalid option"
			sleep 1
    esac
done

exit 0
