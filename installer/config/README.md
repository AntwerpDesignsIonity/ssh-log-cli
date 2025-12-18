# Configuration Files

This directory contains configuration files and templates for the SSH installation scripts.

## Files

### installer.conf
Default configuration file for the installation scripts. This file contains settings that can be customized:

- General settings (email, comments, backup options)
- SSH key defaults (types, lengths, counts)
- GPG key settings
- Platform-specific options (Windows/Linux)
- Security preferences
- Advanced features

## Usage

The configuration file uses a simple INI-style format:

```ini
[Section]
key=value
```

## Customization

To customize the installation:

1. Copy `installer.conf` to a custom location
2. Edit the values as needed
3. Run the installer scripts (future versions may support loading custom configs)

## Example Customizations

### Generate Ed25519 keys by default:
```ini
[SSH Keys]
default_key_type=ed25519
```

### Auto-backup to a specific location:
```ini
[General]
auto_backup=true
default_backup_path=/path/to/backup
```

### Generate 3 keys by default:
```ini
[SSH Keys]
default_key_count=3
```

### Auto-generate GPG keys:
```ini
[GPG Keys]
auto_generate_gpg=true
```

## Notes

- Boolean values: `true` or `false`
- Empty values mean the script will prompt for input
- Some features may require script modifications to implement
- This configuration is provided as a reference for future enhancements
