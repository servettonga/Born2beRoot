# AppArmor

**AppArmor** ("Application Armor") is a Linux kernel [security module](https://en.wikipedia.org/wiki/Linux_Security_Modules) that allows the system administrator to restrict programs' capabilities with per-program profiles. Profiles can allow capabilities like network access, raw socket access, and the permission to read, write, or execute files on matching paths. AppArmor supplements the traditional Unix [discretionary access control](https://en.wikipedia.org/wiki/Discretionary_access_control) (DAC) model by providing [mandatory access control](https://en.wikipedia.org/wiki/Mandatory_access_control) (MAC). It has been partially included in the mainline Linux kernel since version 2.6.36 and its development has been supported by [Canonical](https://en.wikipedia.org/wiki/Canonical_(company)) since 2009.

AppArmor is installed and loaded by default. It uses *profiles* of an application to determine what files and permissions the application requires. Some packages will install their own profiles, and additional profiles can be found in the `apparmor-profiles` package.

To install the `apparmor-profiles` package from a terminal prompt:

```shell
sudo apt install apparmor-profiles
```

AppArmor profiles have two modes of execution:

- Complaining/Learning: profile violations are permitted and logged. Useful for testing and developing new profiles.
- Enforced/Confined: enforces profile policy as well as logging the violation.

In addition to manually creating profiles, AppArmor includes a learning mode, in which profile violations are logged, but not prevented. This log can then be used for generating an AppArmor profile, based on the program's typical behavior.

AppArmor is implemented using the [Linux Security Modules](https://en.wikipedia.org/wiki/Linux_Security_Modules) (LSM) kernel interface.

AppArmor is offered in part as an alternative to [SELinux](https://en.wikipedia.org/wiki/Security-Enhanced_Linux), which critics consider difficult for administrators to set up and maintain. Unlike SELinux, which is based on applying labels to files, AppArmor works with file paths. Proponents of AppArmor claim that it is less complex and easier for the average user to learn than SELinux. They also claim that AppArmor requires fewer modifications to work with existing systems. For example, SELinux requires a filesystem that supports "security labels", and thus cannot provide access control for files mounted via [NFS](https://en.wikipedia.org/wiki/Network_File_System). AppArmor is filesystem-agnostic.

---

Source: [https://en.wikipedia.org/wiki/AppArmor](https://en.wikipedia.org/wiki/AppArmor)
