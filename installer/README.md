# SSH Installation Toolkit

## Overview

This toolkit provides automated SSH and GPG/PGP key generation and management tools for Windows, Linux, and macOS platforms.

## What's Included

### Installation Scripts

1. **ssh-install.bat** - Windows batch script
   - Auto-elevates to administrator privileges
   - Installs OpenSSH if not present
   - Interactive key generation wizard
   - Multiple key type support
   - GPG/PGP key generation
   - Automatic backup functionality

2. **ssh-install.sh** - Linux/macOS bash script
   - Color-coded terminal output
   - Interactive prompts
   - Multiple key type support
   - GPG/PGP key generation
   - Automatic backup functionality
   - File browser integration

3. **index.html** - Static webpage
   - Project information and metadata
   - Download links for scripts
   - Installation instructions
   - License information (CC-BY-NC-SA-4.0)
   - Ionity branding

### Installer Directory Structure

```
installer/
├── config/          # Configuration templates
├── templates/       # SSH config templates
└── README.md        # This file
```

## Features

### Key Types Supported

- **RSA**: 2048, 4096, 8192 bits
- **Ed25519**: Modern elliptic curve (recommended)
- **ECDSA**: 256, 384, 521 bits
- **GPG/PGP**: 4096-bit RSA keys for encryption and signing

### Advanced Features

- ✅ **Auto-elevation**: Windows script automatically requests admin rights
- ✅ **Multiple keys**: Generate as many keys as you need in one session
- ✅ **Interactive prompts**: User-friendly guided setup
- ✅ **Automatic backup**: Save keys to a custom location
- ✅ **File browser**: Visual selection of backup directories
- ✅ **No password needed**: Scripts handle everything automatically
- ✅ **GPG support**: Email encryption and code signing keys
- ✅ **Cross-platform**: Windows, Linux, macOS

## Installation Instructions

### Windows Installation

1. Download `ssh-install.bat` from the repository or webpage
2. Double-click the file to run (it will auto-elevate to administrator)
   - Or right-click and select "Run as administrator"
3. Follow the interactive prompts:
   - Enter your email address
   - Enter an optional comment
   - Choose how many keys to generate
   - Select key types and bit lengths
   - Choose whether to backup keys
   - Optionally generate GPG keys
4. Your keys will be saved to `%USERPROFILE%\.ssh`

### Linux/macOS Installation

1. Download `ssh-install.sh` from the repository or webpage
2. Make the script executable:
   ```bash
   chmod +x ssh-install.sh
   ```
3. Run the script:
   ```bash
   ./ssh-install.sh
   ```
4. Follow the interactive prompts:
   - Enter your email address
   - Enter an optional comment
   - Choose how many keys to generate
   - Select key types and bit lengths
   - Choose whether to backup keys
   - Optionally generate GPG keys
5. Your keys will be saved to `~/.ssh`

## Usage After Installation

### Using Your SSH Keys

Once generated, you can use your SSH keys to connect to remote servers:

```bash
# Linux/macOS
ssh -i ~/.ssh/id_ed25519_1 user@hostname

# Windows
ssh -i %USERPROFILE%\.ssh\id_ed25519_1 user@hostname
```

### Adding Keys to SSH Agent

#### Windows (PowerShell)
```powershell
# Start ssh-agent
Start-Service ssh-agent

# Add your key
ssh-add $env:USERPROFILE\.ssh\id_ed25519_1
```

#### Linux/macOS
```bash
# Start ssh-agent
eval "$(ssh-agent)"

# Add your key
ssh-add ~/.ssh/id_ed25519_1
```

### Copying Public Keys to Servers

#### Linux/macOS
```bash
ssh-copy-id -i ~/.ssh/id_ed25519_1.pub user@hostname
```

#### Windows/Manual Method
```bash
# Display your public key
cat ~/.ssh/id_ed25519_1.pub   # Linux/macOS
type %USERPROFILE%\.ssh\id_ed25519_1.pub   # Windows

# Then add it to the server's ~/.ssh/authorized_keys file
```

### Using GPG Keys

After generating GPG keys, you can use them for:

**Listing your keys:**
```bash
gpg --list-keys
gpg --list-secret-keys
```

**Exporting public key:**
```bash
gpg --armor --export your.email@example.com > pubkey.asc
```

**Encrypting files:**
```bash
gpg --encrypt --recipient your.email@example.com file.txt
```

**Signing Git commits:**
```bash
git config --global user.signingkey YOUR_GPG_KEY_ID
git config --global commit.gpgsign true
```

## Key Management Best Practices

1. **Backup Your Keys**: Always keep a secure backup of your private keys
2. **Use Strong Keys**: Ed25519 or RSA 4096-bit keys are recommended
3. **Protect Private Keys**: Never share your private keys
4. **Use SSH Agent**: Avoid typing passwords repeatedly
5. **Rotate Keys**: Generate new keys periodically
6. **Different Keys for Different Purposes**: Use separate keys for different servers/services

## File Locations

### Windows
- SSH keys: `C:\Users\YourUsername\.ssh\`
- GPG keys: `C:\Users\YourUsername\AppData\Roaming\gnupg\`
- Backup location: User-selected via file browser

### Linux/macOS
- SSH keys: `/home/username/.ssh/` or `~/.ssh/`
- GPG keys: `/home/username/.gnupg/` or `~/.gnupg/`
- Backup location: User-selected path

## Troubleshooting

### Windows Issues

**OpenSSH not installing:**
- Try manually: Settings → Apps → Optional Features → Add OpenSSH Client
- Or use PowerShell: `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`

**GPG not found:**
- Install from: https://gnupg.org/download/
- Or use Chocolatey: `choco install gnupg`

**Permission denied:**
- Make sure you're running as administrator
- Check antivirus isn't blocking the script

### Linux/macOS Issues

**ssh-keygen not found:**
- Ubuntu/Debian: `sudo apt-get install openssh-client`
- macOS: Should be pre-installed; try `brew install openssh` if missing

**GPG not found:**
- Ubuntu/Debian: `sudo apt-get install gnupg`
- macOS: `brew install gnupg`

**Permission errors:**
- Ensure `.ssh` directory has proper permissions: `chmod 700 ~/.ssh`
- Ensure private keys have proper permissions: `chmod 600 ~/.ssh/id_*`

## Requirements

### Windows
- Windows 10 or later
- PowerShell 5.0 or later (pre-installed)
- Administrator privileges (script will auto-elevate)
- Optional: GPG for Windows (for GPG key generation)

### Linux
- Any modern Linux distribution
- Bash 4.0 or later
- OpenSSH client
- Optional: GPG/GnuPG (for GPG key generation)

### macOS
- macOS 10.12 or later
- Bash or Zsh
- OpenSSH client (pre-installed)
- Optional: GPG Suite or GPG from Homebrew

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC-BY-NC-SA-4.0).

**Copyright © 2025 Ionity - All Rights Reserved**

You are free to:
- **Share** — copy and redistribute the material
- **Adapt** — remix, transform, and build upon the material

Under the following terms:
- **Attribution** — Give appropriate credit to Ionity
- **NonCommercial** — Not for commercial use
- **ShareAlike** — Distribute contributions under the same license

For more information: https://creativecommons.org/licenses/by-nc-sa/4.0/

## Support

For issues, questions, or contributions:
- GitHub Repository: https://github.com/AntwerpDesignsIonity/ssh-log-cli
- Issue Tracker: https://github.com/AntwerpDesignsIonity/ssh-log-cli/issues

## Credits

Developed and maintained by **Ionity** as part of the Antwerp Designs Ionity organization.

Special thanks to the open-source community for SSH and GPG tools.
