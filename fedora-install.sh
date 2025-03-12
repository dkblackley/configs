#!/bin/bash

# Fedora Setup Script
# This script installs various applications and development tools on Fedora

# Exit on error
set -e

echo "Starting Fedora setup..."

# Update system
echo "Updating system packages..."
sudo dnf update -y

# Install DNF utilities for repository management
echo "Installing repository management tools..."
sudo dnf install -y dnf-plugins-core
sudo dnf install openssl -y


# Add RPM Fusion repositories (free and non-free)
echo "Adding RPM Fusion repositories..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Flatpak and add Flathub repository
echo "Setting up Flatpak and Flathub repository..."
sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Enable Flathub for all users
sudo flatpak remote-modify --enable flathub

# Update Flatpak
sudo flatpak update -y

# Install communication apps
echo "Installing communication applications..."
# Install Thunderbird email client
sudo dnf install -y --skip-unavailable thunderbird

# Install Signal
echo "Installing Signal..."
# Add Signal repository (using flatpak instead of problematic repo method)
sudo flatpak install -y flathub org.signal.Signal

# Install Slack
echo "Installing Slack..."
# Using Flatpak for Slack
sudo flatpak install -y flathub com.slack.Slack

sudo flatpak install -y flathub org.gnome.Extensions
sudo flatpak install -y flathub org.gnome.Tweaks
sudo flatpak install -y flathub com.valvesoftware.Steam
sudo flatpak install -y flathub md.obsidian.Obsidian

sudo dnf install -y steam-devices

# Install Syncthing
echo "Installing Syncthing..."
sudo dnf install -y syncthing
# Enable and start Syncthing service for current user
systemctl --user enable syncthing.service
systemctl --user start syncthing.service

# Install Chromium
echo "Installing Chromium..."
sudo dnf install -y chromium

# Install OpenSSL development files
echo "Installing OpenSSL development libraries..."
sudo dnf install -y --skip-unavailable openssl-devel
sudo dnf install -y --skip-unavailable perl-FindBin perl-devel
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
# Install additional Rust components
rustup component add clippy rust-analyzer rustfmt

# Install development tools
echo "Installing development tools..."
# Try to find available groups first
echo "Available development groups:"
sudo dnf group list | grep -i "development" || echo "No development groups found"

# Install individual development tools instead of using groups
echo "Installing essential development tools..."
sudo dnf install -y --skip-unavailable \
    gcc \
    gcc-c++ \
    make \
    gdb \
    lldb \
    cmake \
    ninja-build \
    meson \
    autoconf \
    automake \
    libtool \
    pkg-config \
    clang \
    clang-tools-extra

# Install utilities
echo "Installing utilities..."
sudo dnf install -y --allowerasing --skip-unavailable \
    nmap \
    htop \
    tmux \
    neofetch \
    git \
    git-lfs \
    curl \
    wget \
    ripgrep \
    fd-find \
    jq \
    tree \
    bat \
    tldr \
    vim \
    zsh \
    flameshot

# Install fonts
echo "Installing fonts..."
sudo dnf install -y --skip-unavailable ibm-plex-mono-fonts

# Install desktop enhancement tools
echo "Installing desktop enhancement tools..."
# Install Latte Dock (note: may have limited functionality under Wayland)
sudo dnf install -y --skip-unavailable latte-dock

# Install Alacritty terminal
echo "Installing Alacritty terminal..."
sudo dnf install -y --skip-unavailable alacritty

# Install Zellij terminal multiplexer
echo "Installing Zellij..."
# Install OpenSSL development files needed for Zellij
sudo dnf install -y --skip-unavailable openssl-devel
# Now install Zellij
OPENSSL_NO_VENDOR=1 cargo install --locked zellij

# Install Emacs
echo "Installing Emacs..."
sudo dnf install -y --skip-unavailable emacs

# Setup Zsh and Oh My Zsh
echo "Setting up Zsh and Oh My Zsh..."
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set Zsh as default shell
chsh -s $(which zsh) $USER

# Install Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure Zsh
cat > ~/.zshrc << 'EOL'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  docker
  kubectl
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH=$HOME/.cargo/bin:$PATH

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias zj='zellij'

# Load Rust environment
source "$HOME/.cargo/env"
EOL

# Install Miniconda
echo "Installing Miniconda..."
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -f ~/miniconda3/miniconda.sh

# Initialize Conda for Zsh
~/miniconda3/bin/conda init zsh

# Create main Conda environment
echo "Creating 'main' Conda environment..."
~/miniconda3/bin/conda create -y -n main python=3.11

# Set Alacritty as default terminal
echo "Setting Alacritty as default terminal..."
xdg-mime default alacritty.desktop x-scheme-handler/terminal

# Create Alacritty configuration
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml << 'EOL'
env:
  TERM: xterm-256color
  SHELL: /usr/bin/zsh

window:
  dimensions:
    columns: 120
    lines: 35
  padding:
    x: 10
    y: 10
  decorations: full
  startup_mode: Windowed
  title: Alacritty
  class:
    instance: Alacritty
    general: Alacritty

scrolling:
  history: 10000
  multiplier: 3

font:
  normal:
    family: monospace
  size: 11.0

cursor:
  style:
    shape: Block
    blinking: On
  blink_interval: 750
  unfocused_hollow: true

shell:
  program: /usr/bin/zsh
EOL

# Create Zellij configuration
mkdir -p ~/.config/zellij
cat > ~/.config/zellij/config.kdl << 'EOL'
keybinds {
    normal {
        bind "Ctrl g" { SwitchToMode "locked"; }
        bind "Ctrl p" { SwitchToMode "pane"; }
        bind "Ctrl n" { SwitchToMode "resize"; }
        bind "Ctrl t" { SwitchToMode "tab"; }
        bind "Ctrl s" { SwitchToMode "scroll"; }
        bind "Ctrl o" { SwitchToMode "session"; }
        bind "Ctrl h" { SwitchToMode "move"; }
        bind "Ctrl b" { Write 2; SwitchToMode "normal"; }
        bind "Ctrl q" { Quit; }
    }
}

themes {
  catppuccin-latte {
    bg "#acb0be" // Surface2
    fg "#4c4f69" // Text
    red "#d20f39"
    green "#40a02b"
    blue "#1e66f5"
    yellow "#df8e1d"
    magenta "#ea76cb" // Pink
    orange "#fe640b" // Peach
    cyan "#04a5e5" // Sky
    black "#e6e9ef" // Mantle
    white "#4c4f69" // Text
  }

  catppuccin-frappe {
    bg "#626880" // Surface2
    fg "#c6d0f5" // Text
    red "#e78284"
    green "#a6d189"
    blue "#8caaee"
    yellow "#e5c890"
    magenta "#f4b8e4" // Pink
    orange "#ef9f76" // Peach
    cyan "#99d1db" // Sky
    black "#292c3c" // Mantle
    white "#c6d0f5" // Text
  }

  catppuccin-macchiato {
    bg "#5b6078" // Surface2
    fg "#cad3f5" // Text
    red "#ed8796"
    green "#a6da95"
    blue "#8aadf4"
    yellow "#eed49f"
    magenta "#f5bde6" // Pink
    orange "#f5a97f" // Peach
    cyan "#91d7e3" // Sky
    black "#1e2030" // Mantle
    white "#cad3f5" // Text
  }

  default {
    bg "#585b70" // Surface2
    fg "#cdd6f4" // Text
    red "#f38ba8"
    green "#a6e3a1"
    blue "#89b4fa"
    yellow "#f9e2af"
    magenta "#f5c2e7" // Pink
    orange "#fab387" // Peach
    cyan "#89dceb" // Sky
    black "#181825" // Mantle
    white "#cdd6f4" // Text
  }
}

pane_frames false
EOL

echo "Installation complete!"
echo "Please log out and log back in to apply all changes."
echo "Your new setup includes:"
echo "- Zsh with Oh My Zsh as your default shell"
echo "- Alacritty as your default terminal"
echo "- Zellij terminal multiplexer (run with 'zellij' or 'zj')"
echo "- Miniconda with a 'main' environment (activate with 'conda activate main')"
