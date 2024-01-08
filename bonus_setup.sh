#!/bin/bash
# Bonus Setup

# Exit if any command fails
set -e

# Variables
php=php8.1

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

# Update and upgrade packages
information "Resynchronizing the package index files from their sources."
sudo apt update && sudo apt upgrade

# Installing PHP
information "Installing ${php}"
if dpkg -s "${php}" >/dev/null 2>&1; then
	sudo apt-get purge --auto-remove -y ${php}
fi
sudo apt update && sudo apt install -y curl
sudo curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
sudo apt update
sudo apt install -y --no-install-recommends ${php}
sudo apt-get install -y ${php}-cli ${php}-common ${php}-mysql ${php}-zip ${php}-cgi ${php}-gd ${php}-mbstring ${php}-curl ${php}-xml ${php}-bcmath
php -v
valid "Done."
echo ""

# Installing MariaDB
information "Installing mariadb-server"
if dpkg -s mariadb-server >/dev/null 2>&1; then
	sudo apt-get purge --auto-remove -y mariadb-server
fi
sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sleep 2
information "Running MySQL secure installation:"
warning "Set a password for root and keep it. Example configuration:"
printf "Enter current password for root (enter for none): <Enter>\n
Switch to unix_socket authentication [Y/n]: Y\n
Set root password? [Y/n]: Y\n
New password: SecurePassw0rd!\n
Re-enter new password: SecurePassw0rd!\n
Remove anonymous users? [Y/n]: Y\n
Disallow root login remotely? [Y/n]: Y\n
Remove test database and access to it? [Y/n]:  Y\n
Reload privilege tables now? [Y/n]:  Y\v"
sudo mysql_secure_installation
sudo systemctl restart mariadb
information "Creating a database for WordPress with user: admin, pass: WPpassword123"
mysql -u root -p -e "CREATE DATABASE wordpress_db;
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'WPpassword123';
GRANT ALL ON wordpress_db.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;"
mysql -u root -p -e "SHOW DATABASES;"
information "Everything is set if you see wordpress_db listed"
valid "Done."
echo ""

# Installing WordPress
information "Installing WordPress"
sudo rm -rf /var/www/html/*
sudo apt install -y wget tar
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
sudo mkdir -p /var/www/html/
sudo mv wordpress/* /var/www/html/
rm -rf latest.tar.gz wordpress/
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
information "Edit /var/www/html/wp-config.php with database information you set:"
echo "define( 'DB_NAME', 'wordpress_db' );"
echo "define( 'DB_USER', 'admin' );"
echo "define( 'DB_PASSWORD', 'WPpassword123' );"
echo "define( 'DB_HOST', 'localhost' );"
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
valid "Done."
echo ""

# Installing Lighttpd
information "Installing lighttpd"
if dpkg -s lighttpd >/dev/null 2>&1; then
	sudo apt-get purge --auto-remove -y lighttpd
fi
sudo apt install -y lighttpd
sudo systemctl start lighttpd
sleep 1
sudo systemctl enable lighttpd
sleep 2
sudo systemctl status lighttpd
if ! dpkg -s ufw >/dev/null 2>&1; then
	warning "ufw is not installed, trying to install it now"
	sudo apt-get install -y ufw
echo "If lighttpd fails to start, make sure that the settings in lighttpd.conf"
echo "are correct without doubles."
fi

# Configure UFW
information "Setting UFW to allow 4242 and 80(http)/443(https) TCP Ports"
sudo ufw --force disable
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 4242/tcp
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable
information "Activating lighttpd FastCGI module"
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload

# The configuration file
confFile="/etc/lighttpd/lighttpd.conf"

# The desired values
desiredDocumentRoot='server.document-root = "/var/www/html"'
desiredPort='server.port = 80'
sudo mkdir -p /var/www/html

# Check if the desired values are in the file
if grep -Fxq "$desiredDocumentRoot" "$confFile" && grep -Fxq "$desiredPort" "$confFile"
then
	information "The lighttpd configuration file is already set correctly."
else
	# If not, change the values
	information "Configuring lighttpd"
	sudo sed -i 's|.*server.document-root.*|'"$desiredDocumentRoot"'|' "$confFile"
	sudo sed -i 's|.*server.port.*|'"$desiredPort"'|' "$confFile"
	information "The configuration file has been updated."
fi
valid "Done."
echo ""
