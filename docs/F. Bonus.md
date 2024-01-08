# F. Bonus

## Installing PHP

To get the latest version of PHP (8.1 at the time of this writing), we need to add a different APT repository, Sury's repository.

```shell
sudo apt update
sudo apt install curl
sudo curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
sudo apt update
```

Install PHP version 8.1:

```shell
sudo apt install --no-install-recommends php8.1
```

The `--no-install-recommends` flag will ensure that other packages like the Apache web server are not installed.

Check php version:

```shell
php -v
```

You will receive output like this:

```other
Output
PHP 8.1.2 (cli) (built: Apr  7 2022 17:46:26) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.1.2, Copyright (c) Zend Technologies
    with Zend OPcache v8.1.2, Copyright (c), by Zend Technologies
```

You can also install more than one package at a time. Here are a few suggestions of the most common modules you will most likely want to install:

```shell
sudo apt-get install -y php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-cgi php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath
```

This command will install the following modules:

- `php8.1-cli` - command interpreter, useful for testing PHP scripts from a shell or performing general shell scripting tasks
- `php8.1-common` - documentation, examples, and common modules for PHP
- `php8.1-mysql` - for working with MySQL databases
- `php8.1-zip` - for working with compressed files
- `php8.1-gd` - for working with images
- `php8.1-mbstring` - used to manage non-ASCII strings
- `php8.1-curl` - lets you make HTTP requests in PHP
- `php8.1-xml` - for working with XML data
- `php8.1-bcmath` - used when working with precision floats

PHP configurations related to Apache are stored in `/etc/php/8.1/apache2/php.ini`. You can list all loaded PHP modules with the following command:

```shell
php -m
```

### Installing Lighttpd

Apache may be installed due to PHP dependencies. Uninstall it if it is to avoid conflicts with lighttpd:

```shell
systemctl status apache2
sudo apt purge apache2
```

Install lighttpd:

```shell
sudo apt install lighttpd
```

Check version, start, enable lighttpd and check status:

```shell
sudo lighttpd -v
sudo systemctl start lighttpd
sudo systemctl enable lighttpd
sudo systemctl status lighttpd
```

Next, allow http port (port 80) through UFW:

```shell
sudo ufw allow http
sudo ufw status
```

And forward host port 8080 to guest port 80 in VirtualBox:

- Go to VM >> `Settings` >> `Network` >> `Adapter 1` >> `Port Forwarding`
- Add rule for host port `8080` to forward to guest port `80`

To test Lighttpd, go to host machine browser and type in address `http://127.0.0.1:8080` or `http://localhost:8080`. You should see a Lighttpd "placeholder page".

Back in VM, activate lighttpd FastCGI module:

```shell
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload
```

The default configuration for Lighttpd is located in the `/etc/lighttpd/lighttpd.conf` file. You can edit this file to configure Lighttpd to serve your website. For a simple website, you can use the following configuration:

```shell
server.document-root = /var/www/html
```

This tells Lighttpd to serve the website files from the `/var/www/html` directory.

You can also configure Lighttpd to use a different port than the default port 80. To do this, add the following line to the `lighttpd.conf` file:

```shell
server.port = 8080
```

To test php is working with lighttpd, create a file in `/var/www/html` named `info.php`. In that php file, write:

```php
<?php
phpinfo();
?>
```

Save and go to host browser and type in the address `http://127.0.0.1:8080/info.php`. You should get a page with PHP information.

### Installing MariaDB

Install MariaDB:

```shell
sudo apt install mariadb-server
```

Start, enable and check MariaDB status:

```shell
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb
```

Then do the MySQL secure installation:

```shell
sudo mysql_secure_installation
```

Answer the questions like so (root here does not mean root user of VM, it's the root user of the databases!):

```other
Enter current password for root (enter for none): <Enter>
Switch to unix_socket authentication [Y/n]: Y
Set root password? [Y/n]: Y
New password: 101Asterix!
Re-enter new password: 101Asterix!
Remove anonymous users? [Y/n]: Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n]:  Y
Reload privilege tables now? [Y/n]:  Y
```

Restart MariaDB service:

```shell
sudo systemctl restart mariadb
```

Enter MariaDB interface:

```shell
mysql -u root -p
```

Enter MariaDB root password, then create a database for WordPress:

```sql
MariaDB [(none)]> CREATE DATABASE wordpress_db;
MariaDB [(none)]> CREATE USER 'admin'@'localhost' IDENTIFIED BY 'WPpassw0rd';
MariaDB [(none)]> GRANT ALL ON wordpress_db.* TO 'admin'@'localhost' WITH GRANT OPTION;
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> EXIT;
```

Check that the database was created successfully, go back into MariaDB interface:

```shell
mysql -u root -p
```

And show databases:

```sql
MariaDB [(none)]> show databases;
```

You should see something like this:

```other
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| wordpress_db       |
+--------------------+
```

If the database is there, everything's good!

### Installing WordPress

We need to install two tools:

```shell
sudo apt install wget tar
```

Then download the latest version of Wordpress, extract it and place the contents in `/var/www/html/` directory. Then clean up archive and extraction directory:

```shell
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
sudo mv wordpress/* /var/www/html/
rm -rf latest.tar.gz wordpress/
```

Create WordPress configuration file:

```shell
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```

Edit `/var/www/html/wp-config.php` with database info:

```php
<?php
/* ... */
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress_db' );

/** Database username */
define( 'DB_USER', 'admin' );

/** Database password */
define( 'DB_PASSWORD', 'WPpassw0rd' );

/** Database host */
define( 'DB_HOST', 'localhost' );
```

Change permissions of WordPress directory to grant rights to web server and restart lighttpd:

```shell
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo systemctl restart lighttpd
```

In host browser, connect to `http://127.0.0.1:8080` and finish WordPress installation.

## Installing Fail2ban

For the second bonus, I chose to install Fail2ban as a security measure for SSH against brute force attacks.

Install Fail2ban:

```shell
sudo apt install fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
sudo systemctl status fail2ban
```

Create `/etc/fail2ban/jail.local` local configuration file.

```shell
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

You’ll start by evaluating the defaults set within the file. These will be found under the `[DEFAULT]` section within the file. These items set the general policy and can be overridden on a per-application basis. If you are using `nano`, you can search within the file by pressing `Ctrl+W`, entering a search string, then pressing enter.

One of the first items to look at is the list of clients that are not subject to the `fail2ban` policies. This is set by the `ignoreip` directive. It is sometimes a good idea to add your own IP address or network to the list of exceptions to avoid locking yourself out. This is less of an issue with web server logins than SSH, since if you are able to maintain shell access you can always reverse a ban. You can uncomment this line and add additional IP addresses or networks delimited by a space, to the existing list:

```shell
[DEFAULT]

. . .
#ignoreip = 127.0.0.1/8 your_home_IP
```

Another item that you may want to adjust is the `bantime`, which controls how many seconds an offending member is banned for. It is ideal to set this to a long enough time to be disruptive to malicious, automated efforts, while short enough to allow users to correct mistakes. By default, this is set to 10 minutes. You can increase or decrease this value:

```shell
bantime = 10m
```

The next two items determine the scope of log lines used to determine an offending client. The `findtime` specifies an amount of time in seconds and the `maxretry` directive indicates the number of attempts to be tolerated within that time. If a client makes more than `maxretry` attempts within the amount of time set by `findtime`, they will be banned:

```shell
findtime = 10m
maxretry = 5
```

Find line ~279 the "SSH servers" heading and modify [sshd] configurations like this:

```other
[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
# mode   = normal
enabled  = true
maxretry = 3
findtime = 10m
bantime  = 20m
port     = 4242
logpath  = %(sshd_log)s
backend  = %(sshd_backend)s
```

In case it fails to start, change `backend` to `systemd`. See: [\#3292](https://github.com/fail2ban/fail2ban/issues/3292)

Restart Fail2ban:

```shell
sudo systemctl restart fail2ban
```

To check failed connection attempts and banned IP addresses, use these commands:

```shell
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo tail -f /var/log/fail2ban.log
```

Test by setting a low value `bantime` (like 10m) in `/etc/fail2ban/jail.local` `sshd` settings, and try to connect multiple times via SSH with the wrong password to get banned.

Example output:

```plaintext
2024-01-04 12:10:09,987 fail2ban.jail           [23454]: INFO    Jail 'sshd' uses systemd {}
2024-01-04 12:10:09,987 fail2ban.jail           [23454]: INFO    Initiated 'systemd' backend
2024-01-04 12:10:09,988 fail2ban.filter         [23454]: INFO      maxLines: 1
2024-01-04 12:10:09,997 fail2ban.filtersystemd  [23454]: INFO    [sshd] Added journal match for: '_SYSTEMD_UNIT=sshd.service + _COMM=sshd'
2024-01-04 12:10:09,997 fail2ban.filter         [23454]: INFO      maxRetry: 3
2024-01-04 12:10:09,997 fail2ban.filter         [23454]: INFO      findtime: 600
2024-01-04 12:10:09,997 fail2ban.actions        [23454]: INFO      banTime: 1200
2024-01-04 12:10:09,997 fail2ban.filter         [23454]: INFO      encoding: UTF-8
2024-01-04 12:10:10,000 fail2ban.filtersystemd  [23454]: INFO    [sshd] Jail is in operation now (process new journal entries)
2024-01-04 12:10:10,000 fail2ban.jail           [23454]: INFO    Jail 'sshd' started
2024-01-04 12:11:27,459 fail2ban.filter         [23454]: INFO    [sshd] Found 10.0.2.2 - 2024-01-04 12:11:27
2024-01-04 12:11:30,994 fail2ban.filter         [23454]: INFO    [sshd] Found 10.0.2.2 - 2024-01-04 12:11:30
2024-01-04 12:11:34,494 fail2ban.filter         [23454]: INFO    [sshd] Found 10.0.2.2 - 2024-01-04 12:11:34
2024-01-04 12:11:34,695 fail2ban.actions        [23454]: NOTICE  [sshd] Ban 10.0.2.2
```

```shell
ssh sehosaf@127.0.0.1 -p 4242                                                          х 255 11s Py base 18:11:34
kex_exchange_identification: read: Connection reset by peer
Connection reset by 127.0.0.1 port 4242
```

You can also see the new rule by checking your `iptables` output. `iptables` is a command for interacting with low-level port and firewall rules on your server. If you followed DigitalOcean’s guide to initial server setup, you will be using `ufw` to manage firewall rules at a higher level. Running `iptables -S` will show you all of the firewall rules that `ufw` already created:

```shell
sudo iptables -S
```

If you pipe the output of `iptables -S` to `grep` to search within those rules for the string `f2b`, you can see the rules that have been added by fail2ban:

```shell
sudo iptables -S | grep f2b
```

---

Sources and to read further on: [https://github.com/mcombeau/Born2beroot/blob/main/guide/bonus_debian.md](https://github.com/mcombeau/Born2beroot/blob/main/guide/bonus_debian.md)

[https://www.digitalocean.com/community/tutorials/how-to-install-php-8-1-and-set-up-a-local-development-environment-on-ubuntu-22-04](https://www.digitalocean.com/community/tutorials/how-to-install-php-8-1-and-set-up-a-local-development-environment-on-ubuntu-22-04)

[https://www.webhi.com/how-to/setup-lighttpd-on-ubuntu-debian-linux/](https://www.webhi.com/how-to/setup-lighttpd-on-ubuntu-debian-linux/)

[https://www.digitalocean.com/community/tutorials/install-wordpress-on-ubuntu](https://www.digitalocean.com/community/tutorials/install-wordpress-on-ubuntu)

[https://www.digitalocean.com/community/tutorials/how-to-protect-an-nginx-server-with-fail2ban-on-ubuntu-22-04](https://www.digitalocean.com/community/tutorials/how-to-protect-an-nginx-server-with-fail2ban-on-ubuntu-22-04)
