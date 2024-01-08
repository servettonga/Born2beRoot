# UFW Essentials: Common Firewall Rules and Commands

UFW (**u**ncomplicated **f**ire**w**all) is a firewall configuration tool that runs on top of `iptables`, included by default within Ubuntu distributions. It provides a streamlined interface for configuring common firewall use cases via the command line.

This cheat sheet-style guide provides a quick reference to common UFW use cases and commands, including examples of how to allow and block services by port, network interface, and source IP address.

## How To Use This Guide

- This guide is in cheat sheet format with self-contained command-line snippets.
- Jump to any section that is relevant to the task you are trying to complete.
- When you see highlighted text in this guide’s commands, keep in mind that this text should refer to IP addresses from your own network.

Remember that you can check your current UFW ruleset with `sudo ufw status` or `sudo ufw status verbose`.

### Verify UFW Status

To check if `ufw` is enabled, run:

```shell
sudo ufw status
```

```other
OutputStatus: inactive
```

The output will indicate if your firewall is active or not.

### Enable UFW

If you got a `Status: inactive` message when running `ufw status`, it means the firewall is not yet enabled on the system. You’ll need to run a command to enable it.

> By default, when enabled UFW will block external access to all ports on a server. In practice, that means if you are connected to a server via SSH and enable `ufw` before allowing access via the SSH port, you’ll be disconnected. Make sure you follow the section on [[Commands and settings/UFW Essentials: Common Firewall Rules and Commands#Allow SSH]] of this guide before enabling the firewall if that’s your case.

To enable UFW on your system, run:

```shell
sudo ufw enable
```

You’ll see output like this:

```other
OutputFirewall is active and enabled on system startup
```

To see what is currently blocked or allowed, you may use the `verbose` parameter when running `ufw status`, as follows:

```shell
sudo ufw status
```

```other
OutputStatus: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip
```

### Disable UFW

If for some reason you need to disable UFW, you can do so with the following command:

```shell
sudo ufw disable
```

Be aware that this command will fully disable the firewall service on your system.

### Allow SSH

When working with remote servers, you’ll want to make sure that the SSH port is open to connections so that you are able to log in to your server remotely.

The following command will enable the OpenSSH UFW application profile and allow all connections to the default SSH port on the server:

```shell
sudo ufw allow OpenSSH
```

```other
OutputRule added
Rule added (v6)
```

Although less user-friendly, an alternative syntax is to specify the exact port number of the SSH service, which is typically set to `22` by default:

```shell
sudo ufw allow 22
```

```other
OutputRule added
Rule added (v6)
```

### Allow Incoming SSH from Specific IP Address or Subnet

To allow incoming connections from a specific IP address or subnet, you’ll include a `from` directive to define the source of the connection. This will require that you also specify the destination address with a `to` parameter. To lock this rule to SSH only, you’ll limit the `proto` (protocol) to `tcp` and then use the `port` parameter and set it to `22`, SSH’s default port.

The following command will allow only SSH connections coming from the IP address `203.0.113.103`:

```shell
sudo ufw allow from 203.0.113.103 proto tcp to any port 22
```

```other
OutputRule added
```

You can also use a subnet address as `from` parameter to allow incoming SSH connections from an entire network:

```shell
sudo ufw allow from 203.0.113.0/24 proto tcp to any port 22
```

```other
OutputRule added
```

### Allow Nginx HTTP / HTTPS

Upon installation, the Nginx web server sets up a few different UFW profiles within the server. Once you have Nginx installed and enabled as a service, run the following command to identify which profiles are available:

```shell
sudo ufw app list | grep Nginx
```

```shell
Output  Nginx Full
  Nginx HTTP
  Nginx HTTPS
```

To enable both HTTP and HTTPS traffic, choose `Nginx Full`. Otherwise, choose either `Nginx HTTP` to allow only HTTP or `Nginx HTTPS` to allow only HTTPS.

The following command will allow both HTTP and HTTPS traffic on the server (ports `80` and `443`):

```shell
sudo ufw allow "Nginx Full"
```

```other
OutputRule added
Rule added (v6)
```

---

Source: [https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)
