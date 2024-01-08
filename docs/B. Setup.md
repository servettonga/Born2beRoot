# B. Setup

## Prerequisites

- [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Debian](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/)
- Enough free disk space.

### Create a Virtual Machine in Virtual-box

- `1024MB` memory is good
- Create a `Dynamically allocated` virtual hard disk `VDI`
- `10 to 13 GB` is enough for both mandatory and bonus parts
- Start the virtual machine

## Install Debian

1. Select Debian ISO image as startup disk.
2. When Debian starts, choose `Install`, not graphical install.
3. Choose language, geographical & keyboard layout settings.
4. Hostname must be `your_login42`
5. Domain name leave empty.
6. Choose strong root password & confirm.
7. Create user. `your_login` works for username & name.
8. Choose password for new user.

### Partitioning disks

1. Choose `Guided - use entire disk and set up encrypted LVM`  or  `Manual` partitioning for bonus part.
2. Choose SDA hard disk - `SCSI (0,0,0) (sda)` ...
3. `Yes` create partition table.

Create 2 partitions, the first will be for an unencrypted /boot partition, the other for the encrypted logical volumes :

- `pri/log xxGB FREE SPACE` >> `Create a new partition` >> `500 MB` >> `Primary` >> `Beginning` >> `Mount point` >> `/boot` >> `Done`.
- `pri/log xxGB FREE SPACE` >> `Create a new partition` >> `max` >> `Logical` >> `Mount point` >> `Do not mount it` >> `Done`.

### Encrypting disks

1. `Configure encrypted volumes` >> `Yes`.
2. `Create encrypted volumes`
3. Choose `sda5` ONLY to encrypt. DO NOT encrypt the `sda /boot` partition.
4. `Done` >> `Finish` >> `Yes`.
5. ... wait for formatting to finish...
6. Choose a strong password for disk encryption.

### Logical Volume Manager (LVM)

### Create a volume group

1. `Configure the Logical Volume Manager` >> `Yes`.
2. `Create Volume Group` >> `LVMGroup` >> `/dev/mapper/sda5_crypt`.

### Create Logical Volumes

- `Create Logical Volume` >> `LVMGroup` >> `root` >> `2.8G`
- `Create Logical Volume` >> `LVMGroup` >> `home` >> `2G`
- `Create Logical Volume` >> `LVMGroup` >> `swap` >> `1G`
- `Create Logical Volume` >> `LVMGroup` >> `tmp` >> `2G`
- `Create Logical Volume` >> `LVMGroup` >> `srv` >> `1.5G`
- `Create Logical Volume` >> `LVMGroup` >> `var` >> `2G`
- `Create Logical Volume` >> `LVMGroup` >> `var-log` >> `2G`

`Display configuration details` to double check & `Finish`.

Set filesystems and mount points for each logical volume:

- Under "LV home", `#1 xxGB` >> `Use as` >> `Ext4` >> `Mount point` >> `/home` >> `Done`
- Under "LV root", `#1 xxGB` >> `Use as` >> `Ext4` >> `Mount point` >> `/` >> `Done`
- Under "LV swap", `#1 xxGB` >> `Use as` >> `swap area` >> `Done`
- Under "LV srv", `#1 3GB` >> `Use as` >> `Ext4` >> `Mount point` >> `/srv` >> `Done`
- Under "LV tmp", `#1 3GB` >> `Use as` >> `Ext4` >> `Mount point` >> `/tmp` >> `Done`
- Under "LV var", `#1 3GB` >> `Use as` >> `Ext4` >> `Mount point` >> `/var` >> `Done`
- Under "LV var-log", `#1 4GB` >> `Use as` >> `Ext4` >> `Mount point` >> `Enter manually` >> `/var/log` >> `Done`

Scroll down & `Finish partitioning and write changes to disk`. `Yes`.

### Finish Installation

1. `No`, no need to scan.
2. Choose `country` & `mirror`.
3. Leave proxy field `blank`.
4. `No`, no need to participate in study.
5. Uncheck all software.
6. `Yes`, install GRUB >> `/dev/sda`
7. `Continue`. Installation complete. The virtual machine will now reboot. Enter encryption password and log into created user.

Verify that the install went correctly by running the following commands:

```shell
lsblk
cat /etc/os-release
```

---

Source: [https://github.com/mcombeau/Born2beroot/blob/main/guide/installation_debian.md](https://github.com/mcombeau/Born2beroot/blob/main/guide/installation_debian.md)
