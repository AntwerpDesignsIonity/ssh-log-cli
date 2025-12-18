# SSH Log CLI

CLI tool that decrypts and decodes session replay files captured by Cloudflare's Audit SSH proxy.

## 🔐 SSH Installation & Key Management Tools

**NEW!** This repository now includes comprehensive automated SSH and GPG/PGP key generation and management tools.

### Quick Start - SSH Key Generation

#### Windows
```batch
# Download and run ssh-install.bat
# It will auto-elevate to administrator and guide you through key generation
ssh-install.bat
```

#### Linux/macOS
```bash
# Download and run ssh-install.sh
chmod +x ssh-install.sh
./ssh-install.sh
```

### Features
- 🔧 **Auto-elevation** to administrator/root when needed
- 🔑 **Multiple key types**: RSA (2048/4096/8192), Ed25519, ECDSA (256/384/521)
- 💾 **Automatic backup** with file browser integration
- 🔐 **GPG/PGP support** for email encryption and code signing
- 📝 **Interactive setup** with guided prompts
- 🌍 **Cross-platform** support (Windows, Linux, macOS)

For detailed documentation, see the [installer README](installer/README.md) or visit [index.html](index.html) for the web interface.

---

## Installation

### Build from source
1. Install Rust https://doc.rust-lang.org/cargo/getting-started/installation.html;
2. Run `cargo build --release`;
3. Find the compiled binary within `target/release/ssh-log-cli`.

## Generating a key pair

``` shell
$ ssh-log-cli generate-key-pair -o <PRIVATE KEY FILE NAME>
```

This command generates an HPKE public and private key, saving each one to its own file. The public key file gets the same name, but with a `.pub` extension.

#
## Handling SSH session capture files

### Decrypting and parsing any SSH session capture file
``` shell
$ ssh-log-cli decrypt -i <PATH TO INPUT FILE> -k <PATH TO HPKE private key> [-o <PATH TO OUTPUT FILE>]
```

 If no output file name is specified, it defaults it to <encrypted_file_name>.decrypted.zip.

**Note**: the output file path must be a valid ZIP file name.

### Decrypting and replaying an SSH PTY session capture file — *Linux/Mac OS X only*
``` shell
$ ssh-log-cli decrypt -i <PATH TO INPUT FILE> -k <PATH TO HPKE private key> --replay
```
 
 This will decrypt the session capture and replay it to *stdout*.
 
 **Note**: no output file will be generated.
#
## Understanding the Output
 
### PTY Sessions
If the encrypted file has a valid interactive session (PTY) capture, then the output ZIP will contain 2 files:
`term_data.txt` and `term_times.txt`.
 
You can then extract it and either open term_data.txt and analyse it on your own or watch a replay by running:
`scriptreplay --timing term_times.txt term_data.txt`
 
### Non-PTY Sessions
If the encrypted file has a valid non-PTY session capture, then the output ZIP will contain 2 files:
`data_from_client.txt` and `data_from_server.txt`. These contain upstream and downstream traffic, respectively.

---

## License

The SSH Installation & Key Management Tools are licensed under **CC-BY-NC-SA-4.0** (Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International).

Copyright © 2025 **Ionity** - All Rights Reserved

The core SSH Log CLI tool retains its original license.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Credits

- SSH Installation Tools developed by **Ionity**
- Part of the **Antwerp Designs Ionity** organization
- Original SSH Log CLI by Cloudflare
