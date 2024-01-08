# D. Password Policy and User Management

## Password Policy

Edit `/etc/login.defs` and find "password aging controls". Modify them as per subject instructions:

```shell
PASS_MAX_DAYS 30
PASS_MIN_DAYS 2
PASS_WARN_AGE 7
PASS_MIN_LEN 7
```

See: [login.defs](./Commands%20and%20settings/login.defs.md)

These changes aren't automatically applied to existing users, so use `chage` command to modify for any users and for root:

```shell
sudo chage -M 30 -m 2 -W 7 <username/root>
```

Use `chage -l <username/root>` to check user settings.

Install password quality verification library:

```shell
sudo apt install libpam-pwquality
```

Then, edit the `/etc/security/pwquality.conf` file like so:

```shell
# Number of characters in the new password that must not be present in the
# old password.
difok = 7
# The minimum acceptable size for the new password (plus one if
# credits are not disabled which is the default)
minlen = 10
# The maximum credit for having digits in the new password. If less than 0
# it is the minimun number of digits in the new password.
dcredit = -1
# The maximum credit for having uppercase characters in the new password.
# If less than 0 it is the minimun number of uppercase characters in the new
# password.
ucredit = -1
# ...
# The maximum number of allowed consecutive same characters in the new password.
# The check is disabled if the value is 0.
maxrepeat = 3
# ...
# Whether to check it it contains the user name in some form.
# The check is disabled if the value is 0.
usercheck = 1
# ...
# Prompt user at most N times before returning with error. The default is 1.
retry = 3
# Enforces pwquality checks on the root user password.
# Enabled if the option is present.
enforce_for_root
# ...
```

>`enforce_for_root`
>
>The module will return error on failed check even if the user changing the password is root. This option is off by default which means that just the message about the failed check is printed but root can change the password anyway. Note that root is not asked for an old password so the checks that compare the old and new password are not performed.

```shell
sudo bash -c "sed -i 's/^# *minlen *=.*/minlen = 10/' /etc/security/pwquality.conf && \
sed -i 's/^# *dcredit *=.*/dcredit = -1/' /etc/security/pwquality.conf && \
sed -i 's/^# *ucredit *=.*/ucredit = -1/' /etc/security/pwquality.conf && \
sed -i 's/^# *maxrepeat *=.*/maxrepeat = 3/' /etc/security/pwquality.conf && \
sed -i 's/^# *difok *=.*/difok = 7/' /etc/security/pwquality.conf && \
sed -i 's/^# *usercheck *=.*/usercheck = 1/' /etc/security/pwquality.conf && \
sed -i 's/^# *retry *=.*/retry = 3/' /etc/security/pwquality.conf && \
sed -i 's/^# *enforce_for_root.*/enforce_for_root/' /etc/security/pwquality.conf"
```

Change user passwords to comply with password policy:

```shell
sudo passwd <user/root>
```

See: [pam_pwquality](./Commands%20and%20settings/pam_pwquality.md)

## Hostname, Users and Groups

The hostname must be `your_intra_login42`, but the hostname must be changed during the Born2beRoot evaluation. The following commands might help:

```shell
sudo hostnamectl set-hostname <new_hostname>
hostnamectl status
```

There must be a user with `your_intra_login` as username. During evaluation, you will be asked to create, delete, modify user accounts. The following commands are useful to know:

- `useradd` : creates a new user.
- `usermod` : changes the user’s parameters: `-l` for the username, `-c` for the full name, `-g` for groups by group ID.

```shell
sudo useradd -M -G sudo,user42 <username>
```

- `userdel -r` : deletes a user and all associated files.
- `id -u` : displays user ID.
- `users` : shows a list of all currently logged in users.
- `cat /etc/passwd | cut -d ":" -f 1` : displays a list of all users on the machine.
- `awk -F':' '{ print $1}' /etc/passwd`: same as above.

The user named your_intra_login must be part of the `sudo` and `user42` groups. You must also be able to manipulate user groups during evaluation with the following commands:

- `groupadd` : creates a new group.
- `gpasswd -a` : adds a user to a group.
- `gpasswd -d` : removes a user from a group.
- `groupdel` : deletes a group.
- `groups` : displays the groups of a user.
- `id -g` : shows a user’s main group ID.
- `getent group` : displays a list of all users in a group.

---

Source: [https://github.com/mcombeau/Born2beroot/blob/main/guide/configuration_debian.md](https://github.com/mcombeau/Born2beroot/blob/main/guide/configuration_debian.md)
