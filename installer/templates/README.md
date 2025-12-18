# Connection Files Configuration
# This directory contains templates and examples for SSH connections

## Files in this directory:

- ssh_config_template: SSH client configuration template
- authorized_keys_template: Template for server-side authorized keys
- known_hosts_example: Example known_hosts entries

## How to use these files:

### 1. SSH Config Template
Copy to: ~/.ssh/config (Linux/macOS) or %USERPROFILE%\.ssh\config (Windows)

This file allows you to create shortcuts for SSH connections:
Instead of: ssh -i ~/.ssh/id_ed25519_1 -p 2222 user@long-hostname.example.com
You can use: ssh myserver

### 2. Authorized Keys Template
On the remote server, add your public key to: ~/.ssh/authorized_keys

This enables passwordless SSH authentication.

### 3. Known Hosts
File location: ~/.ssh/known_hosts (Linux/macOS) or %USERPROFILE%\.ssh\known_hosts (Windows)

This file stores fingerprints of hosts you've connected to.
It helps prevent man-in-the-middle attacks.

## Quick Start Guide:

1. Generate SSH keys using ssh-install.bat or ssh-install.sh
2. Copy the SSH config template to your .ssh directory
3. Edit the config file to add your servers
4. Copy your public key to remote servers:
   - Linux/macOS: ssh-copy-id -i ~/.ssh/id_ed25519_1.pub user@host
   - Windows: Manually append the public key to the server's authorized_keys file

## Best Practices:

- Use Ed25519 keys for new installations (smaller, faster, more secure)
- Use different keys for different purposes/servers
- Keep private keys secure (never share them)
- Backup your keys to a secure location
- Use strong passphrases (optional but recommended)
- Regularly rotate keys for sensitive systems
- Use SSH agent to avoid repeatedly entering passphrases

## File Permissions:

Correct permissions are critical for SSH security:

Linux/macOS:
- ~/.ssh directory: 700 (drwx------)
- Private keys: 600 (-rw-------)
- Public keys: 644 (-rw-r--r--)
- config file: 600 (-rw-------)
- authorized_keys: 600 (-rw-------)
- known_hosts: 644 (-rw-r--r--)

Windows:
- Permissions are typically managed automatically
- Ensure only your user account has access to private keys
