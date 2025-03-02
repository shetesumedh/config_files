#!/bin/bash

# Function to check if the distribution is Arch Linux
check_distro() {
    if [[ ! -f /etc/arch-release ]]; then
        echo "This script is intended for Arch Linux only. Aborting."
        exit 1
    fi
}

# Function to install packages if not already installed
install_packages() {
    local packages=("kitty" "alacritty" "fish" "neovim")
    local missing_packages=()

    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &> /dev/null; then
            missing_packages+=("$pkg")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        echo "Installing missing packages: ${missing_packages[*]}"
        sudo pacman -S --noconfirm "${missing_packages[@]}"
    else
        echo "All required packages are already installed."
    fi
}

# Function to install Nerd Fonts
install_fonts() {
    local fonts=(
        "ttc-firacode-nerd"
        "ttf-jetbrains-mono-nerd"
        "ttf-firacode-nerd"
        "ttf-firacode-nerd-bold"
        "ttf-firacode-nerd-italic"
        "ttf-firacode-nerd-bold-italic"
    )

    local missing_fonts=()

    for font in "${fonts[@]}"; do
        if ! pacman -Qi "$font" &> /dev/null; then
            missing_fonts+=("$font")
        fi
    done

    if [[ ${#missing_fonts[@]} -gt 0 ]]; then
        echo "Installing missing fonts: ${missing_fonts[*]}"
        sudo pacman -S --noconfirm "${missing_fonts[@]}"
    else
        echo "All required fonts are already installed."
    fi
}

# Define the backup directory
BACKUP_DIR="$HOME/backup_config"

# Define the config directories and files
declare -A CONFIG_DIRS=(
    ["alacritty"]="$HOME/.config/alacritty"
    ["kitty"]="$HOME/.config/kitty"
    ["fish"]="$HOME/.config/fish"
    ["nvim"]="$HOME/.config/nvim"
)

CONFIG_FILES=(
    ["pacman.conf"]="/etc/pacman.conf"
)

# Function to display warning and prompt user
prompt_user() {
    echo "WARNING: This script will back up your existing config files to $BACKUP_DIR and replace them with Sumedh's config files."
    echo "If interrupted or not done correctly, your system could break."
    read -p "Do you want to proceed? (yes/y or no/n): " user_input

    if [[ "$user_input" =~ ^(yes|y)$ ]]; then
        echo "Proceeding with the script..."
        return 0
    elif [[ "$user_input" =~ ^(no|n)$ ]]; then
        echo "Aborting the script. No changes were made."
        exit 0
    else
        echo "Invalid input. Please enter 'yes/y' or 'no/n'."
        prompt_user
    fi
}

# Function to back up existing config files
backup_configs() {
    echo "Creating backup directory at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"

    # Backup directories
    for dir_name in "${!CONFIG_DIRS[@]}"; do
        dir_path="${CONFIG_DIRS[$dir_name]}"
        if [[ -d "$dir_path" ]]; then
            echo "Backing up $dir_name directory: $dir_path"
            cp -r "$dir_path" "$BACKUP_DIR/${dir_name}_backup"
        else
            echo "No existing directory found for $dir_name at $dir_path"
        fi
    done

    # Backup files
    for file_name in "${!CONFIG_FILES[@]}"; do
        file_path="${CONFIG_FILES[$file_name]}"
        if [[ -f "$file_path" ]]; then
            echo "Backing up $file_name file: $file_path"
            cp "$file_path" "$BACKUP_DIR/${file_name}_backup"
        else
            echo "No existing file found for $file_name at $file_path"
        fi
    done
}

# Function to replace config files with Sumedh's configs
replace_configs() {
    echo "Replacing config files with Sumedh's versions..."

    # Replace directories
    for dir_name in "${!CONFIG_DIRS[@]}"; do
        dir_path="${CONFIG_DIRS[$dir_name]}"
        repo_dir="$(dirname "$0")/$dir_name"  # Assumes directories are in the same directory as the script

        if [[ -d "$repo_dir" ]]; then
            echo "Replacing $dir_name directory with Sumedh's version..."
            mkdir -p "$(dirname "$dir_path")"
            cp -r "$repo_dir" "$(dirname "$dir_path")"
        else
            echo "No directory found for $dir_name in the repository."
        fi
    done

    # Replace files
    for file_name in "${!CONFIG_FILES[@]}"; do
        file_path="${CONFIG_FILES[$file_name]}"
        repo_file="$(dirname "$0")/$file_name"  # Assumes files are in the same directory as the script

        if [[ -f "$repo_file" ]]; then
            echo "Replacing $file_name file with Sumedh's version..."
            sudo cp "$repo_file" "$file_path"
        else
            echo "No file found for $file_name in the repository."
        fi
    done
}

chris_bash(){
	mkdir -p "$HOME/build"
    cd "$HOME/build" || exit
    git clone https://github.com/christitustech/mybash mybash_tmp
    cd mybash_tmp || exit
    ./setup.sh

    # Cleanup
    echo "Cleaning up..."
    rm -rf "$HOME/build/mybash_tmp"
}

# Main script execution
check_distro
install_packages
install_fonts
prompt_user
backup_configs
replace_configs
chris_bash

echo "Config files have been successfully replaced. Please restart your applications to apply changes."
