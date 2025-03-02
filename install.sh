#!/bin/bash

# List of packages to install
packages=(alacritty kitty neovim fish)

# Directory for backup
backup_dir="$HOME/config_backup"
mkdir -p "$backup_dir"

# Configuration files to backup and replace
config_files=(".config/alacritty" ".config/kitty" ".config/nvim" ".config/fish" ".bashrc")

# Adding pacman.conf to the backup and replace process
system_config_files=("/etc/pacman.conf")

echo "Warning: This script will delete your existing config files and replace them with Sumedh's configurations."
echo "This could break your system if not done properly. Do you want to proceed? (yes/no)"
read -r choice

if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
    # Install missing packages using pacman
    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            echo "Installing $pkg..."
            sudo pacman -S --noconfirm "$pkg"
        else
            echo "$pkg is already installed."
        fi
    done

    # Backup and replace config files
    for file in "${config_files[@]}"; do
        if [[ -e "$HOME/$file" ]]; then
            echo "Backing up $file to $backup_dir"
            mv "$HOME/$file" "$backup_dir/"
        fi
        
        echo "Copying new config for $file"
        cp -r "config_files/$file" "$HOME/$file"
    done

    # Backup and replace system configuration files
    for sys_file in "${system_config_files[@]}"; do
        if [[ -e "$sys_file" ]]; then
            echo "Backing up $sys_file to $backup_dir"
            sudo cp "$sys_file" "$backup_dir/"
        fi
        
        echo "Copying new config for $sys_file"
        sudo cp "config_files${sys_file}" "$sys_file"
    done

    # Update .bashrc using Christ Titus Tech's mybash
    mkdir -p "$HOME/build"
    cd "$HOME/build" || exit
    git clone https://github.com/christitustech/mybash mybash_tmp
    cd mybash_tmp || exit
    ./setup.sh

    # Cleanup
    echo "Cleaning up..."
    rm -rf "$HOME/build/mybash_tmp"

    echo "Configuration update complete. Restart your terminal for changes to take effect."
else
    echo "Nothing has changed. Exiting."
    exit 0
fi
