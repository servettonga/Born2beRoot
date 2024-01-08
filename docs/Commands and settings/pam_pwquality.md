# pam_pwquality

`pam_pwquality` - PAM module to perform password quality checking

## Description

This module can be plugged into the *password* stack of a given service to provide some plug-in strength-checking for passwords. The code was originally based on `pam_cracklib` module and the module is backwards compatible with its options.

The action of this module is to prompt the user for a password and check its strength against a system dictionary and a set of rules for identifying poor choices.

The first action is to prompt for a single password, check its strength and then, if it is considered strong, prompt for the password a second time (to verify that it was typed correctly on the first occasion). All being well, the password is passed on to subsequent modules to be installed as the new authentication token.

The strength checks works in the following manner: at first the `Cracklib` routine is called to check if the password is part of a dictionary; if this is not the case an additional set of strength checks are done. These checks are:

Palindrome

   Is the new password a palindrome?

Case Change Only

   Is the new password the the old one with only a change of case?

Similar

   Is the new password too much like the old one? This is primarily controlled by one argument, `difok` which is a number of changes between the old and new are enough to accept the new password.

Simple

   Is the new password too small? This is controlled by 5 arguments `minlen`, `dcredit`, `ucredit`, `lcredit`, and `ocredit`. See the section on the arguments for the details of how these work and there defaults.

Rotated

   Is the new password a rotated version of the old password?

Same consecutive characters

   Optional check for same consecutive characters.

Contains user name

   Optional check whether the password contains the user name in some form.

These checks are configurable either by use of the module arguments or by modifying the `/etc/security/pwquality.conf` configuration file.

## Options

`debug`

   This option makes the module write information to [**syslog**](https://linux.die.net/man/3/syslog)(3) indicating the behavior of the module (this option does not write password information to the log file).

`authtok_type=XXX`

   The default action is for the module to use the following prompts when requesting passwords: "New UNIX password: " and "Retype UNIX password: ". The example word *UNIX* can be replaced with this option, by default it is empty.

`retry=N`

   Prompt user at most *N* times before returning with error. The default is *1*.

`difok=N`

   This argument will change the default of *5* for the number of changes in the new password from the old password.

`minlen=N`

   The minimum acceptable size for the new password (plus one if credits are not disabled which is the default). In addition to the number of characters in the new password, credit (of +1 in length) is given for each different kind of character (*other*, *upper*, *lower* and *digit*). The default for this parameter is *9* . Note that there is a pair of length limits also in `Cracklib`, which is used for dictionary checking, a "way too short" limit of 4 which is hard coded in and a build time defined limit (6) that will be checked without reference to `minlen`.

`dcredit=N`

   (N >= 0) This is the maximum credit for having digits in the new password. If you have less than or *N* digits, each digit will count +1 towards meeting the current `minlen` value. The default for `dcredit` is 1 which is the recommended value for `minlen` less than 10.

   (N < 0) This is the minimum number of digits that must be met for a new password.

`ucredit=N`

   (N >= 0) This is the maximum credit for having upper case letters in the new password. If you have less than or *N* upper case letters each letter will count +1 towards meeting the current `minlen` value. The default for `ucredit` is *1* which is the recommended value for `minlen` less than 10.

   (N < 0) This is the minimum number of upper case letters that must be met for a new password.

`lcredit=N`

   (N >= 0) This is the maximum credit for having lower case letters in the new password. If you have less than or *N* lower case letters, each letter will count +1 towards meeting the current `minlen` value. The default for `lcredit` is 1 which is the recommended value for `minlen` less than 10.

   (N < 0) This is the minimum number of lower case letters that must be met for a new password.

`ocredit=N`

   (N >= 0) This is the maximum credit for having other characters in the new password. If you have less than or *N* other characters, each character will count +1 towards meeting the current `minlen` value. The default for `ocredit` is 1 which is the recommended value for `minlen` less than 10.

   (N < 0) This is the minimum number of other characters that must be met for a new password.

`minclass=N`

   The minimum number of required classes of characters for the new password. The default number is zero. The four classes are digits, upper and lower letters and other characters. The difference to the `credit` check is that a specific class if of characters is not required. Instead *N* out of four of the classes are required.

`maxrepeat=N`

   Reject passwords which contain more than N same consecutive characters. The default is 0 which means that this check is disabled.

`maxclassrepeat=N`

   Reject passwords which contain more than N consecutive characters of the same class. The default is 0 which means that this check is disabled.

`gecoscheck=N`

   If nonzero, check whether the individual words longer than 3 characters from the `passwd GECOS` field of the user are contained in the new password. The default is 0 which means that this check is disabled.

`badwords=__`

   The words more than 3 characters long from this space separated list are individually searched for and forbidden in the new password. By default the list is empty which means that this check is disabled.

`enforce_for_root`

   The module will return error on failed check even if the user changing the password is root. This option is off by default which means that just the message about the failed check is printed but root can change the password anyway.

`use_authtok`

   This argument is used to *force* the module to not prompt the user for a new password but use the one provided by the previously stacked *password* module.

`dictpath=/path/to/dict`

   Path to the `cracklib` dictionaries.

---

Source: [https://linux.die.net/man/8/pam_pwquality](https://linux.die.net/man/8/pam_pwquality)

