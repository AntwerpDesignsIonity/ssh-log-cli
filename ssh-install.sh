#!/bin/bash

# SSH Installation and Key Generation Script for Linux/Mac
# Copyright (c) Ionity - Licensed under CC-BY-NC-SA-4.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Main script
clear
print_header "SSH Installation and Key Management Tool"
echo -e "${BLUE}                    Ionity (c)${NC}"
echo -e "${BLUE}          Licensed under CC-BY-NC-SA-4.0${NC}"
echo ""

# Check if running with sufficient privileges for some operations
if [ "$EUID" -eq 0 ]; then
    print_info "Running with root privileges"
else
    print_info "Running as regular user (recommended for SSH key generation)"
fi

# Check if ssh-keygen is installed
if ! command -v ssh-keygen &> /dev/null; then
    print_error "ssh-keygen not found!"
    echo ""
    echo "Please install OpenSSH:"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  Ubuntu/Debian: sudo apt-get install openssh-client"
        echo "  Fedora/RHEL: sudo dnf install openssh-clients"
        echo "  Arch: sudo pacman -S openssh"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS: OpenSSH should be pre-installed"
        echo "  If missing, install via Homebrew: brew install openssh"
    fi
    
    exit 1
fi

print_success "OpenSSH found"
echo ""

# Prompt for user information
read -p "Enter your email address: " USER_EMAIL
read -p "Enter a comment for your keys (optional, press Enter to use email): " USER_COMMENT

if [ -z "$USER_COMMENT" ]; then
    USER_COMMENT="$USER_EMAIL"
fi

# Ask how many keys to generate
read -p "How many SSH keys do you want to generate? (1-10): " NUM_KEYS
NUM_KEYS=${NUM_KEYS:-1}

# Validate number
if ! [[ "$NUM_KEYS" =~ ^[0-9]+$ ]] || [ "$NUM_KEYS" -lt 1 ] || [ "$NUM_KEYS" -gt 10 ]; then
    print_info "Invalid number. Using 1 as default."
    NUM_KEYS=1
fi

echo ""
print_header "Creating SSH directory structure"

# Create .ssh directory if it doesn't exist
SSH_DIR="$HOME/.ssh"
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    print_success "Created $SSH_DIR directory"
else
    print_success "$SSH_DIR directory exists"
fi

# Ask for backup location
echo ""
read -p "Would you like to backup your keys to a specific location? [y/N]: " BACKUP_CHOICE

BACKUP_PATH=""
if [[ "$BACKUP_CHOICE" =~ ^[Yy]$ ]]; then
    read -e -p "Enter backup directory path: " BACKUP_PATH
    
    if [ -n "$BACKUP_PATH" ]; then
        # Expand tilde
        BACKUP_PATH="${BACKUP_PATH/#\~/$HOME}"
        
        if [ ! -d "$BACKUP_PATH" ]; then
            mkdir -p "$BACKUP_PATH"
            print_success "Created backup directory: $BACKUP_PATH"
        else
            print_success "Using existing backup directory: $BACKUP_PATH"
        fi
        chmod 700 "$BACKUP_PATH"
    else
        print_info "No backup location specified"
    fi
fi

# Generate keys in a loop
for ((i=1; i<=NUM_KEYS; i++)); do
    echo ""
    print_header "Generating SSH Key $i of $NUM_KEYS"
    echo ""
    echo "Select key type:"
    echo "1. RSA (2048 bits)"
    echo "2. RSA (4096 bits)"
    echo "3. RSA (8192 bits)"
    echo "4. Ed25519 (recommended)"
    echo "5. ECDSA (256 bits)"
    echo "6. ECDSA (384 bits)"
    echo "7. ECDSA (521 bits)"
    echo ""
    
    read -p "Enter your choice (1-7): " KEY_TYPE_CHOICE
    
    KEY_TYPE=""
    KEY_BITS=""
    KEY_NAME_SUFFIX=""
    
    case $KEY_TYPE_CHOICE in
        1)
            KEY_TYPE="rsa"
            KEY_BITS="2048"
            KEY_NAME_SUFFIX="rsa_2048"
            ;;
        2)
            KEY_TYPE="rsa"
            KEY_BITS="4096"
            KEY_NAME_SUFFIX="rsa_4096"
            ;;
        3)
            KEY_TYPE="rsa"
            KEY_BITS="8192"
            KEY_NAME_SUFFIX="rsa_8192"
            ;;
        4)
            KEY_TYPE="ed25519"
            KEY_BITS=""
            KEY_NAME_SUFFIX="ed25519"
            ;;
        5)
            KEY_TYPE="ecdsa"
            KEY_BITS="256"
            KEY_NAME_SUFFIX="ecdsa_256"
            ;;
        6)
            KEY_TYPE="ecdsa"
            KEY_BITS="384"
            KEY_NAME_SUFFIX="ecdsa_384"
            ;;
        7)
            KEY_TYPE="ecdsa"
            KEY_BITS="521"
            KEY_NAME_SUFFIX="ecdsa_521"
            ;;
        *)
            print_info "Invalid choice. Using Ed25519 as default."
            KEY_TYPE="ed25519"
            KEY_NAME_SUFFIX="ed25519"
            ;;
    esac
    
    KEY_FILE="$SSH_DIR/id_${KEY_NAME_SUFFIX}_${i}"
    
    echo ""
    print_info "Generating $KEY_TYPE key..."
    
    if [ -z "$KEY_BITS" ]; then
        ssh-keygen -t "$KEY_TYPE" -C "$USER_COMMENT" -f "$KEY_FILE" -N ""
    else
        ssh-keygen -t "$KEY_TYPE" -b "$KEY_BITS" -C "$USER_COMMENT" -f "$KEY_FILE" -N ""
    fi
    
    if [ $? -eq 0 ]; then
        chmod 600 "$KEY_FILE"
        chmod 644 "$KEY_FILE.pub"
        print_success "Successfully generated key: $KEY_FILE"
        print_success "Public key: $KEY_FILE.pub"
        
        # Backup if location was specified
        if [ -n "$BACKUP_PATH" ]; then
            cp "$KEY_FILE" "$BACKUP_PATH/"
            cp "$KEY_FILE.pub" "$BACKUP_PATH/"
            print_success "Keys backed up to $BACKUP_PATH"
        fi
    else
        print_error "Failed to generate key"
    fi
done

# GPG/PGP Key Generation
echo ""
print_header "GPG/PGP Key Generation"
read -p "Would you like to generate GPG/PGP keys? [y/N]: " GPG_CHOICE

if [[ "$GPG_CHOICE" =~ ^[Yy]$ ]]; then
    if ! command -v gpg &> /dev/null; then
        print_error "GPG is not installed on your system"
        echo ""
        echo "Please install GPG:"
        
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "  Ubuntu/Debian: sudo apt-get install gnupg"
            echo "  Fedora/RHEL: sudo dnf install gnupg2"
            echo "  Arch: sudo pacman -S gnupg"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  macOS: brew install gnupg"
        fi
    else
        echo ""
        print_info "Generating GPG key pair..."
        
        # Create GPG batch file
        GPG_BATCH_FILE=$(mktemp)
        
        cat > "$GPG_BATCH_FILE" <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $USER_COMMENT
Name-Email: $USER_EMAIL
Expire-Date: 0
%no-protection
%commit
EOF
        
        gpg --batch --gen-key "$GPG_BATCH_FILE"
        rm -f "$GPG_BATCH_FILE"
        
        print_success "GPG key generated successfully!"
        echo ""
        echo "To list your GPG keys, run: gpg --list-keys"
        echo "To export your public key, run: gpg --armor --export $USER_EMAIL > pubkey.asc"
        
        if [ -n "$BACKUP_PATH" ]; then
            echo ""
            print_info "⚠️  WARNING: Backing up private GPG keys. Ensure backup location is secure!"
            print_info "Backing up GPG keys to $BACKUP_PATH..."
            gpg --export-secret-keys --armor "$USER_EMAIL" > "$BACKUP_PATH/gpg_private_key.asc" 2>/dev/null
            gpg --export --armor "$USER_EMAIL" > "$BACKUP_PATH/gpg_public_key.asc" 2>/dev/null
            chmod 600 "$BACKUP_PATH/gpg_private_key.asc"
            chmod 644 "$BACKUP_PATH/gpg_public_key.asc"
            print_success "GPG keys backed up"
        fi
    fi
fi

# Display SSH configuration
echo ""
print_header "SSH Configuration Complete"
echo ""
echo "Your SSH keys are located in: $SSH_DIR"
echo ""
echo "To use your keys with SSH:"
echo "  ssh -i \"$SSH_DIR/id_ed25519_1\" user@host"
echo ""
echo "To add your key to ssh-agent:"
echo "  1. Start ssh-agent: eval \$(ssh-agent)"
echo "  2. Add your key: ssh-add \"$SSH_DIR/id_ed25519_1\""
echo ""
echo "To copy your public key:"
echo "  cat \"$SSH_DIR/id_ed25519_1.pub\""
echo ""

if [ -n "$BACKUP_PATH" ]; then
    echo "Keys backed up to: $BACKUP_PATH"
    echo ""
fi

# Optional: Add to SSH config
echo ""
read -p "Would you like to view the SSH directory? [y/N]: " OPEN_DIR
if [[ "$OPEN_DIR" =~ ^[Yy]$ ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "$SSH_DIR"
    elif command -v open &> /dev/null; then
        open "$SSH_DIR"
    else
        ls -la "$SSH_DIR"
    fi
fi

echo ""
print_success "Setup complete!"
