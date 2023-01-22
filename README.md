# Windows Profile

My personal windows profile. Exists primarily to sync between different machines.

## Installation

Download fonts and install:

- <https://github.com/andreberg/Meslo-Font>
- <https://github.com/belluzj/fantasque-sans>

### Packages

```powershell
& .\Packages.ps1
```

Grab non-profile-directory configuration from [this gist](https://gist.github.com/jeremytwfortune/fe850de4eb384b2c78812bf2c0b97e64).

### Terminal

- Copy WindowsTerminal.settings.json content

### GPG

Download the GPG private key.

```powershell
gpg --import .\key.pvt
gpg --edit-key 35E40FA7
```

Add both sign and encrypt RSA keys

```powershell
gpg --with-keygrip --list-key 35E40FA7
```

Select the keygrip and

```powershell
$keygrip = ""
Remove-Item "$home\AppData\Roaming\.gnupg\private-keys-v1.d\${keygrip}.key"
```
