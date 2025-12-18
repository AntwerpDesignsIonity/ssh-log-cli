@echo off
REM SSH Installation and Key Generation Script for Windows
REM Auto-elevates to Administrator if not already running with admin privileges
REM Copyright (c) Ionity - Licensed under CC-BY-NC-SA-4.0

NET SESSION >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ================================================================
echo       SSH Installation and Key Management Tool
echo                    Ionity (c)
echo          Licensed under CC-BY-NC-SA-4.0
echo ================================================================
echo.

REM Check if OpenSSH is installed
where ssh >nul 2>&1
if %errorLevel% neq 0 (
    echo OpenSSH Client not found. Installing...
    powershell -Command "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
    echo OpenSSH Client installed successfully.
    echo.
)

where ssh-keygen >nul 2>&1
if %errorLevel% neq 0 (
    echo ssh-keygen not found. Please ensure OpenSSH is properly installed.
    pause
    exit /b 1
)

REM Prompt for user information
set /p USER_EMAIL="Enter your email address: "
set /p USER_COMMENT="Enter a comment for your keys (optional): "

if "%USER_COMMENT%"=="" set USER_COMMENT=%USER_EMAIL%

REM Ask how many keys to generate
set /p NUM_KEYS="How many SSH keys do you want to generate? (1-10): "
if "%NUM_KEYS%"=="" set NUM_KEYS=1
if %NUM_KEYS% lss 1 set NUM_KEYS=1
if %NUM_KEYS% gtr 10 set NUM_KEYS=10

echo.
echo ================================================================
echo Creating SSH directory structure...
echo ================================================================

if not exist "%USERPROFILE%\.ssh" (
    mkdir "%USERPROFILE%\.ssh"
    echo Created %USERPROFILE%\.ssh directory
)

REM Ask for backup location
echo.
echo Would you like to backup your keys to a specific location?
set /p BACKUP_CHOICE="[Y/N]: "

if /I "%BACKUP_CHOICE%"=="Y" (
    powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $folder = New-Object System.Windows.Forms.FolderBrowserDialog; $folder.Description = 'Select backup location for SSH keys'; $folder.ShowDialog() | Out-Null; $folder.SelectedPath" > "%TEMP%\backup_path.txt"
    set /p BACKUP_PATH=<"%TEMP%\backup_path.txt"
    del "%TEMP%\backup_path.txt"
    
    if not "!BACKUP_PATH!"=="" (
        if not exist "!BACKUP_PATH!" mkdir "!BACKUP_PATH!"
        echo Backup location set to: !BACKUP_PATH!
    ) else (
        echo No backup location selected.
        set BACKUP_PATH=
    )
)

setlocal enabledelayedexpansion

REM Generate keys in a loop
for /L %%i in (1,1,%NUM_KEYS%) do (
    echo.
    echo ================================================================
    echo Generating SSH Key %%i of %NUM_KEYS%
    echo ================================================================
    echo.
    echo Select key type:
    echo 1. RSA (2048 bits)
    echo 2. RSA (4096 bits)
    echo 3. RSA (8192 bits)
    echo 4. Ed25519 (recommended)
    echo 5. ECDSA (256 bits)
    echo 6. ECDSA (384 bits)
    echo 7. ECDSA (521 bits)
    echo.
    
    set /p KEY_TYPE_CHOICE="Enter your choice (1-7): "
    
    set KEY_TYPE=
    set KEY_BITS=
    set KEY_NAME_SUFFIX=
    
    if "!KEY_TYPE_CHOICE!"=="1" (
        set KEY_TYPE=rsa
        set KEY_BITS=2048
        set KEY_NAME_SUFFIX=rsa_2048
    )
    if "!KEY_TYPE_CHOICE!"=="2" (
        set KEY_TYPE=rsa
        set KEY_BITS=4096
        set KEY_NAME_SUFFIX=rsa_4096
    )
    if "!KEY_TYPE_CHOICE!"=="3" (
        set KEY_TYPE=rsa
        set KEY_BITS=8192
        set KEY_NAME_SUFFIX=rsa_8192
    )
    if "!KEY_TYPE_CHOICE!"=="4" (
        set KEY_TYPE=ed25519
        set KEY_BITS=
        set KEY_NAME_SUFFIX=ed25519
    )
    if "!KEY_TYPE_CHOICE!"=="5" (
        set KEY_TYPE=ecdsa
        set KEY_BITS=256
        set KEY_NAME_SUFFIX=ecdsa_256
    )
    if "!KEY_TYPE_CHOICE!"=="6" (
        set KEY_TYPE=ecdsa
        set KEY_BITS=384
        set KEY_NAME_SUFFIX=ecdsa_384
    )
    if "!KEY_TYPE_CHOICE!"=="7" (
        set KEY_TYPE=ecdsa
        set KEY_BITS=521
        set KEY_NAME_SUFFIX=ecdsa_521
    )
    
    if "!KEY_TYPE!"=="" (
        echo Invalid choice. Using Ed25519 as default.
        set KEY_TYPE=ed25519
        set KEY_NAME_SUFFIX=ed25519
    )
    
    set KEY_FILE=%USERPROFILE%\.ssh\id_!KEY_NAME_SUFFIX!_%%i
    
    echo.
    echo Generating !KEY_TYPE! key...
    
    if "!KEY_BITS!"=="" (
        ssh-keygen -t !KEY_TYPE! -C "!USER_COMMENT!" -f "!KEY_FILE!" -N ""
    ) else (
        ssh-keygen -t !KEY_TYPE! -b !KEY_BITS! -C "!USER_COMMENT!" -f "!KEY_FILE!" -N ""
    )
    
    if !errorLevel! equ 0 (
        echo Successfully generated key: !KEY_FILE!
        echo Public key: !KEY_FILE!.pub
        
        REM Backup if location was specified
        if not "!BACKUP_PATH!"=="" (
            copy "!KEY_FILE!" "!BACKUP_PATH!\" >nul
            copy "!KEY_FILE!.pub" "!BACKUP_PATH!\" >nul
            echo Keys backed up to !BACKUP_PATH!
        )
    ) else (
        echo Failed to generate key.
    )
)

REM GPG/PGP Key Generation
echo.
echo ================================================================
echo Would you like to generate GPG/PGP keys?
echo ================================================================
set /p GPG_CHOICE="[Y/N]: "

if /I "%GPG_CHOICE%"=="Y" (
    where gpg >nul 2>&1
    if !errorLevel! neq 0 (
        echo.
        echo GPG is not installed on your system.
        echo Please install GPG from: https://gnupg.org/download/
        echo Or install via Chocolatey: choco install gnupg
    ) else (
        echo.
        echo Generating GPG key batch file...
        
        set GPG_BATCH_FILE=%TEMP%\gpg_batch_%%random%%.txt
        
        echo Key-Type: RSA > "!GPG_BATCH_FILE!"
        echo Key-Length: 4096 >> "!GPG_BATCH_FILE!"
        echo Subkey-Type: RSA >> "!GPG_BATCH_FILE!"
        echo Subkey-Length: 4096 >> "!GPG_BATCH_FILE!"
        echo Name-Real: %USER_COMMENT% >> "!GPG_BATCH_FILE!"
        echo Name-Email: %USER_EMAIL% >> "!GPG_BATCH_FILE!"
        echo Expire-Date: 0 >> "!GPG_BATCH_FILE!"
        echo %%no-protection >> "!GPG_BATCH_FILE!"
        echo %%commit >> "!GPG_BATCH_FILE!"
        
        echo Generating GPG key pair...
        gpg --batch --gen-key "!GPG_BATCH_FILE!"
        
        del "!GPG_BATCH_FILE!"
        
        echo.
        echo GPG key generated successfully!
        echo.
        echo To list your GPG keys, run: gpg --list-keys
        echo To export your public key, run: gpg --armor --export %USER_EMAIL% ^> pubkey.asc
        
        if not "!BACKUP_PATH!"=="" (
            echo.
            echo Backing up GPG keys to !BACKUP_PATH!...
            gpg --export-secret-keys --armor %USER_EMAIL% > "!BACKUP_PATH!\gpg_private_key.asc" 2>nul
            gpg --export --armor %USER_EMAIL% > "!BACKUP_PATH!\gpg_public_key.asc" 2>nul
            echo GPG keys backed up.
        )
    )
)

REM Display SSH configuration
echo.
echo ================================================================
echo SSH Configuration Complete
echo ================================================================
echo.
echo Your SSH keys are located in: %USERPROFILE%\.ssh
echo.
echo To use your keys with SSH:
echo   ssh -i "%USERPROFILE%\.ssh\id_[keytype]_[number]" user@host
echo.
echo To add your key to ssh-agent:
echo   1. Start ssh-agent: ssh-agent
echo   2. Add your key: ssh-add "%USERPROFILE%\.ssh\id_[keytype]_[number]"
echo.
echo To copy your public key:
echo   type "%USERPROFILE%\.ssh\id_[keytype]_[number].pub"
echo.

if not "!BACKUP_PATH!"=="" (
    echo Keys backed up to: !BACKUP_PATH!
    echo.
)

REM Open SSH directory
set /p OPEN_DIR="Would you like to open the SSH directory? [Y/N]: "
if /I "%OPEN_DIR%"=="Y" (
    explorer "%USERPROFILE%\.ssh"
)

echo.
echo Press any key to exit...
pause >nul

endlocal
