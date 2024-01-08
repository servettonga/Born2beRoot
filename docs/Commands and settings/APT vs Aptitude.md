# APT vs Aptitude

Aptitude is a high-level package manager while APT is lower-level package manager which can be used by other higher-level package managers.

## What is APT

[Apt](https://wiki.debian.org/Apt) is the default Linux command-line tool to manage the packages on a Debian-based system. It comes by default and doesn't offer a graphical interface to manage the tools that are installed and the ones that you can need in the future. To install a package, you need to specify the name of the package just after the `apt install` command. The package manager reads the `/etc/apt/sources.list` file and the contents of the `/etc/apt/sources.list.d` folder to retrieve the ones that you need with all the dependencies.

Apt command offers a lot of sub-commands that help you to manage your system so that the packages can be added, updated, removed, or fixed if a problem occurs. During those processes, it will automatically install, update or remove the necessary dependencies or the other packages which depend on the main package that is being operated

## What is Aptitude ​

[Aptitude](https://www.debian.org/doc/manuals/aptitude/rn01re01.en.html) is another popular tool that you can use over apt. It offers a command-line and text-based front-end for package management. It doesn't come by default, so you need to install it with the `apt` command. aptitude offers the possibility to manage your packages through command lines and also from a visual interface directly on your terminal. You can perform the main actions like installing, updating, and deleting your packages. it also offers sub-commands to manage your packages as apt but some people prefer the visual interface as it's easy to use.

### Let's understand the difference

If you consider only the command-line interfaces of each, they are quite similar as each of them offers you different ways to manage your packages. Therefore, there are a few differences that we can list:

- Apt offers a command-line interface, while aptitude offers a visual interface
- When facing a package conflict, `apt` will not fix the issue while `aptitude` will suggest a resolution that can do the job
- aptitude can interactively retrieve and displays the Debian change log of all available official packages

​Apt requires the user to have a solid knowledge of Linux systems and package management as you are running everything in the command line. It can be difficult for a novice to handle.

On the other hand, aptitude with its interface is more user-friendly as it offers a layer of abstraction regarding the different sub-commands to use for installation, upgrades, etc.

---

Source: [https://blog.packagecloud.io/know-the-difference-between-apt-and-aptitude/](https://blog.packagecloud.io/know-the-difference-between-apt-and-aptitude/)
