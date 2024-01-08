# SELinux

## Overview

Security-Enhanced Linux (SELinux) is a [security](https://www.redhat.com/en/topics/security) architecture for [Linux® systems](https://www.redhat.com/en/topics/linux/what-is-linux) that allows administrators to have more control over who can access the system. It was originally developed by the United States National Security Agency (NSA) as a series of [patches](https://www.redhat.com/en/topics/linux/what-is-linux-kernel-live-patching) to the [Linux kernel](https://www.redhat.com/en/topics/linux/what-is-the-linux-kernel) using Linux Security Modules (LSM).

SELinux was released to the [open source](https://www.redhat.com/en/topics/open-source/what-is-open-source) community in 2000, and was integrated into the upstream Linux kernel in 2003.

## How does SELinux work?

SELinux defines access controls for the applications, processes, and files on a system. It uses security policies, which are a set of rules that tell SELinux what can or can’t be accessed, to enforce the access allowed by a policy.

When an application or process, known as a subject, makes a request to access an object, like a file, SELinux checks with an access vector cache (AVC), where permissions are cached for subjects and objects.

If SELinux is unable to make a decision about access based on the cached permissions, it sends the request to the security server. The security server checks for the security context of the app or process and the file. Security context is applied from the SELinux policy database. Permission is then granted or denied.

If permission is denied, an `avc: denied` message will be available in `/var/log.messages`.

### How to configure SELinux

There are a number of ways that you can configure SELinux to protect your system. The most common are targeted policy or multi-level security (MLS).

Targeted policy is the default option and covers a range of processes, tasks, and services. MLS can be very complicated and is typically only used by government organizations.

You can tell what your system is supposed to be running at by looking at the `/etc/sysconfig/selinux` file. The file will have a section that shows you whether SELinux is in permissive mode, enforcing mode, or disabled, and which policy is supposed to be loaded.

### SELinux labeling and type enforcement

Type enforcement and labeling are the most important concepts for SELinux.

SELinux works as a labeling system, which means that all of the files, processes, and ports in a system have an SELinux label associated with them. Labels are a logical way of grouping things together. The [kernel](https://www.redhat.com/en/topics/linux/what-is-the-linux-kernel) manages the labels during boot.

Labels are in the format user:role:type:level (level is optional). User, role, and level are used in more advanced implementations of SELinux, like with MLS. Label type is the most important for targeted policy.

SELinux uses type enforcement to enforce a policy that is defined on the system. Type enforcement is the part of an SELinux policy that defines whether a process running with a certain type can access a file labeled with a certain type.

### Enabling SELinux

If SELinux has been disabled in your environment, you can enable SElinux by editing `/etc/selinux/config` and setting `SELINUX=permissive`. Since SELinux was not currently enabled, you don’t want to set it to enforcing right away because the system will likely have things mislabeled that can keep the system from booting.

You can force the system to automatically [relabel the filesystem](https://access.redhat.com/solutions/24845) by creating an empty file named `.autorelabel` in the root directory and then rebooting. If the system has too many errors, you should reboot while in permissive mode in order for the boot to succeed. After everything has been relabeled, set SELinux to enforcing with `/etc/selinux/config` and reboot, or run `setenforce 1`.

If a sysadmin is less familiar with the command line, there are graphic tools available that can be used to manage SELinux.

SELinux provides an additional layer of security for your system that is built into [Linux distributions](https://www.redhat.com/en/topics/linux/whats-the-best-linux-distro-for-you). It should remain on so that it can protect your system if it is ever compromised.

---

Source: [https://www.redhat.com/en/topics/linux/what-is-selinux](https://www.redhat.com/en/topics/linux/what-is-selinux)
