# G. Evaluation

## Signature.txt

To extract the VM's signature for the correction, go to the Virtual Box VMs folder in your local computer:

- Windows: `%HOMEDRIVE%%HOMEPATH%\VirtualBox VMs\`
- Linux: `~/VirtualBox VMs/`
- MacM1: `~/Library/Containers/com.utmapp.UTM/Data/Documents/`
- MacOS: `~/VirtualBox VMs/`

Then use the following command (replace `centos_serv` with your machine name):

- Windows: `certUtil -hashfile centos_serv.vdi sha1`
- Linux: `sha1sum centos_serv.vdi`
- For Mac M1: `shasum Centos.utm/Images/disk-0.qcow2`
- MacOS: `shasum centos_serv.vdi`

This is an example of what kind of output you will get:

• 6e657c4619944be17df3c31faa030c25e43e40af

And save the signature to a file named `signature.txt`.

## Manual tests

### User check

Add a new user

```shell
sudo adduser <username>
```

Verify password expiration dates

```shell
sudo chage -l username
```

Assign user to groups

```shell
sudo usermod -aG sudo,user42 <username>
```

### System check

Partitions

```shell
lsblk
```

AppArmor status

```shell
sudo aa-status
```

sudo and user42 group users

```shell
getent group sudo
getent group user42
```

ssh and ufw status

```shell
sudo service ssh status
sudo ufw status
```

Connection via ssh

```shell
ssh <username>@ipadress -p 4242
```

sudo config file

```shell
/etc/sudoers
```

Password expire policy

```shell
/etc/login.defs
```

Password policy (for pwquality)

```shell
/etc/security/pwquality.conf
```

cron schedule

```shell
sudo crontab -l
```

### Changes

Hostname (/etc/hostname)

```shell
hostnamectl set-hostname <newhostname>
```

Add or remove ports in ufw

```shell
sudo ufw status
sudo ufw deny <port>
sudo ufw allow <port>
```

Cron jobs

```shell
sudo crontab -e
```
