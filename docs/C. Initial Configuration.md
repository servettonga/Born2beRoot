# C. Initial Configuration

## Sudo Setup

Log in as root:

```shell
su root
```

Install sudo:

```shell
apt update && apt upgrade && apt install sudo
```

Add user to sudo group:

```shell
sudo usermod -aG sudo <username>
```

Then `exit` root session and `exit` again to return to login prompt. Log in again as user.

Let's check if this user has sudo privileges:

```shell
sudo whoami
```

It should answer `root`. If not, modify `sudoers` file as explained below and add this line:

```shell
username  ALL=(ALL:ALL) ALL
```

Edit `sudoers.tmp` file as root with the command:

```shell
sudo visudo
```

And add these default settings as per subject instructions:

```shell
Defaults     passwd_tries=3
Defaults     badpass_message="Wrong password. Try again!"
Defaults     logfile="/var/log/sudo/sudo.log"
Defaults     log_input
Defaults     log_output
Defaults     requiretty
```

If `var/log/sudo` directory does not exist, `mkdir var/log/sudo`.

See: [[Commands and settings/What do PTY and TTY Mean?]], [[Commands and settings/How To Edit the Sudoers File]], [[Commands and settings/How To Edit the Sudoers File#How To Modify the sudoers File]], [[Commands and settings/Create a New Sudo-enabled User]]

## UFW Setup

Install and enable UFW:

```shell
sudo apt update && sudo apt upgrade && sudo apt install ufw
sudo ufw enable
```

Check UFW status:

```shell
sudo ufw status verbose
```

Allow or deny ports:

```shell
sudo ufw default deny incoming
sudo ufw allow 4242/tcp
sudo ufw --force enable
```

Remove port rule:

```shell
sudo ufw delete allow <port>
sudo ufw delete deny <port>
```

Or, another method for rule deletion:

```shell
sudo ufw status numbered
sudo ufw delete <port index number>
```

Careful with the numbered method, the index numbers change after a deletion, check between deletes to get the correct port index number!

See: [[Commands and settings/UFW Essentials: Common Firewall Rules and Commands]]

## SSH Setup

Install OpenSSH:

```shell
sudo apt update && sudo apt upgrade
sudo apt install openssh-server
```

Check SSH status:

```shell
sudo systemctl status ssh
```

Change SSH listening port to 4242:

```shell
sudo nano /etc/ssh/sshd_config
```

And uncomment (delete #) and change them to:

```shell
Port 4242
PermitRootLogin no
PasswordAuthentication yes
```

Restart SSH service

```shell
sudo systemctl restart ssh
```

Don't forget to add a UFW rule to allow port 4242!

```shell
sudo ufw default deny incoming
sudo ufw allow 4242/tcp
sudo ufw --force enable
```

Forward the host port 4242 to the guest port 4242: in VirtualBox,

- go to VM >> Settings >> Network >> Adapter 1 >> Advanced >> Port Forwarding.
- add a rule: Host port 4242 and guest port 4242.

Restart SSH service after this change.

In the host terminal, connect like this:

```shell
ssh <username>@localhost -p 4242
```

Or like this:

```shell
ssh <username>@127.0.0.1 -p 4242
```

To quit the ssh connection, just `exit`.

See: [Secure Shell (SSH)](./General%20Information/Secure%20Shell%20(SSH).md), [UFW](Commands%20and%20settings/UFW%20Essentials:%20Common%20Firewall%20Rules%20and%20Commands.md#allow-ssh)

---

Source: [https://github.com/mcombeau/Born2beroot/blob/main/guide/configuration_debian.md](https://github.com/mcombeau/Born2beroot/blob/main/guide/configuration_debian.md)
