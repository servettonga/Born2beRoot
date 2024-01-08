# What do PTY and TTY Mean?

TTY is an acronym for *teletype* or *teletypewriter*. In essence, **TTYs are devices that enable typing (*type*, *typewriter*) from a distance (*tele*)**.

In a modern operating system (OS), the concept applies directly. **Linux uses a** [**device file**](https://www.baeldung.com/linux/dev-directory) to represent a virtual TTY, which enables interaction with the OS** by handling input (usually a keyboard) and output (usually a screen).

While Linux systems can have multiple TTYs, their number is usually limited by the configuration. Actually, we can change this by modifying  `/etc/init/tty*.conf`, `/etc/securetty`, `/etc/systemd/logind.conf`, or similar configuration files depending on the Linux distribution.

In fact, the default number of TTYs is commonly seven. However, in more recent distributions, there are many more:

```bash
find /dev -regex '.*/tty[0-9]+'
/dev/tty63
/dev/tty62
[...]
/dev/tty1
/dev/tty0
```

Here, we see 64 basic *tty* devices via the [filtering *find*](https://www.baeldung.com/linux/find-command-regex) command. Nevertheless, we can use the [*/sys*](https://www.baeldung.com/linux/all-serial-devices) virtual filesystem to list all serial devices:

```shell
find /sys/class/tty/ | sort -V
/sys/class/tty/
/sys/class/tty/console
/sys/class/tty/ptmx
/sys/class/tty/tty
/sys/class/tty/tty0
/sys/class/tty/tty1
[...]
/sys/class/tty/tty63
/sys/class/tty/ttyS0
/sys/class/tty/ttyS1
/sys/class/tty/ttyS2
/sys/class/tty/ttyS3
```

In this case, we see several other related devices:

- [*/dev/tty*](https://www.baeldung.com/linux/monitor-keyboard-drivers#devtty)
- [*/dev/console*](https://www.baeldung.com/linux/monitor-keyboard-drivers#devconsole)
- [*/dev/ttyS#*](https://man7.org/linux/man-pages/man4/ttys.4.html)
- */dev/ptmx*

In fact, we have [already discussed](https://www.baeldung.com/linux/monitor-keyboard-drivers#devconsole) the first two. Importantly, in recent Linux distributions, [*systemd*](https://www.baeldung.com/linux/differences-systemctl-service#1-sysvinit-and-systemd) spawns the `getty@.service`, which generates, provides, and monitors `/dev/tty*` devices. This way, we can use a command like the following to reset a problematic terminal:

```shell
systemctl restart getty@tty1.service
```

Furthermore, **device files such as `/dev/ttyS#`, `/dev/ttyUSB#`, and similar can be handled by *serial-getty@.service* and are meant to be channels for communication with COM, USB, and other devices**.

The last device type is `/dev/ptmx`, which we’ll delve into next. Pure TTYs do allow communication, but they don’t provide much flexibility because at least one end of the TTY is (a keyboard, mouse, or another input device via) the kernel. On the other hand, a PTY can be linked to any application on both ends.

## What Is a PTY?

PTY is an acronym for *pseudo-TTY*. **The name *PTY* stems from the fact that it behaves like a TTY but for any two endpoints**. This minor difference enables multiple PTYs to co-exist within the context of the same TTY.

In fact, both sides of a PTY have a name:

- slave, `/dev/pts`, represented by a file in `/dev/pts/#`
- master, *ptm*, which only exists as a file descriptor of the process, which requests a PTY

This is where `/dev/ptmx`, the pseudo-terminal multiplexor device, comes in. Effectively, there are several steps to establish and use a PTY:

1. A process opens `/dev/ptmx`
2. The OS returns a master `ptm` file descriptor
3. The OS creates a corresponding `/dev/pts/#` slave pseudo-device
4. From this point, slave input goes to the master, while master input goes to the slave

To know the correspondence between a master and slave, we can call the [*ptsname*](https://pubs.opengroup.org/onlinepubs/009695399/functions/ptsname.html) function.

Basically, **a PTY enables bi-directional communication similar to pipes**. Unlike pipes, it provides a terminal interface to any process that requires it.

What do we do with this power?

## Terminal Emulators

One of the main functions PTYs have is enabling the existence of terminal emulators such as [*xterm*](https://invisible-island.net/xterm/), [GNOME Terminal](https://help.gnome.org/users/gnome-terminal/stable/), and [*Konsole*](https://apps.kde.org/konsole/).

In essence, **a terminal emulator requests as many PTYs as it needs from the OS**, often presenting them as tabs or windows in the GUI. Let’s follow how that works and how it links to the concepts of TTY and PTY.

First, Linux boots into a TTY. We can confirm this and the current terminal backend in general via the [`tty`](https://man7.org/linux/man-pages/man1/tty.1.html) command:

```shell
tty
/dev/tty1
```

In this case, we’re on `/dev/tty1`, commonly the first TTY, used for login and the GUI. In fact, we can usually start the [X Window System](https://www.x.org/releases/current/doc/man/man7/X.7.xhtml) with [*startx*](https://www.x.org/releases/X11R7.6/doc/man/man1/startx.1.xhtml). Now, we have a GUI running on `/dev/tty1`.

From there, we can open any terminal emulator application and check its terminal:

```shell
tty
/dev/pts/0
```

The output shows we’re in the first pseudo-TTY slave.

In fact, we can even skip the GUI step, as there are terminal emulators in the CLI.

## PTY Applications

Naturally, we use PTYs to create more terminals inside of our existing terminals. Why do that? One reason is to avoid [overloading TTYs](https://www.baeldung.com/linux/kill-overloaded-terminals). Another is pure convenience.

### GUI in the CLI

Short of having a GUI, using software like [*tmux*](https://www.baeldung.com/linux/tmux) or [*screen*](https://www.baeldung.com/linux/screen-command) is usually the next best thing.

Both of these applications are terminal multiplexors, which more or less [emulate a GUI](https://www.baeldung.com/linux/attach-terminal-detached-process#cli-gui-emulation) in the CLI:

```shell
$ tty              $ tty
/dev/pts/0         /dev/pts/1

   0 bash              1 bash
$ tty              $ tty
/dev/pts/2         /dev/pts/3


   2 bash              3 bash
```

Of course, both *screen* (shown above) and *tmux* provide many other enhancements. For example, **terminal multiplexors support long-running processes without relying on** [***jobs***](https://www.baeldung.com/linux/jobs-job-control-bash) in a terminal** we don’t need to touch for anything else.

Often, this ability comes into play when using the system remotely.

### Remote Connections

**Communication protocols like** [***ssh***](https://www.baeldung.com/linux/secure-shell-ssh) and [***telnet***](https://www.baeldung.com/linux/telnet) depend on terminal emulation to interact with the OS**.

Since they are applications and not hardware, a PTY provides their terminal connection:

```shell
ssh ssh.example.com
tty
/dev/pts/0
```

Here, we see that *tty* returns the pseudo-terminal slave number responsible for servicing the SSH session.

---

Source: [https://www.baeldung.com/linux/pty-vs-tty](https://www.baeldung.com/linux/pty-vs-tty)
