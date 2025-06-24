#!/bin/bash

# Load colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Show welcome
whiptail --title "🚀 Nexus CLI Node Setup" --msgbox "Welcome! This script will help you install and run your Nexus CLI node.\n\nMake sure you’re logged into https://app.nexus.xyz/nodes before continuing." 12 60

# Step 1 – Guide user to get Node ID
whiptail --title "🔐 Login Instructions" --msgbox "1. Go to https://app.nexus.xyz/nodes\n2. Login with your email or Web3 wallet\n3. Click 'Add CLI Node'\n4. Copy your numeric Node ID (e.g. 345677)" 12 60

# Step 2 – Ask for Node ID
while true; do
    NODE_ID=$(whiptail --inputbox "Enter your Node ID (numbers only):" 10 60 --title "🧩 Node ID" 3>&1 1>&2 2>&3)
    [[ $? -ne 0 ]] && exit 1
    if [[ "$NODE_ID" =~ ^[0-9]+$ ]]; then
        break
    else
        whiptail --title "❌ Invalid Input" --msgbox "Node ID must be numeric. Please try again." 8 50
    fi
done

# Step 3 – Confirm and continue
whiptail --title "✅ Node ID Set" --msgbox "Node ID set to: $NODE_ID\n\nLet's move on to installation..." 10 50

# Step 4 – Install dependencies
{
    echo 10; sleep 1
    sudo apt update -y > /dev/null 2>&1
    echo 30; sleep 1
    sudo apt upgrade -y > /dev/null 2>&1
    echo 50; sleep 1
    sudo apt install screen curl build-essential pkg-config libssl-dev git git-all protobuf-compiler -y > /dev/null 2>&1
    echo 80; sleep 1
    sudo apt update > /dev/null 2>&1
    echo 100; sleep 1
} | whiptail --gauge "Installing system packages..." 6 50 0

# Step 5 – Install Rust
{
    echo 30; sleep 1
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y > /dev/null 2>&1
    source "$HOME/.cargo/env"
    echo 70; sleep 1
    rustup target add riscv32i-unknown-none-elf > /dev/null 2>&1
    echo 100; sleep 1
} | whiptail --gauge "Installing Rust..." 6 50 0

# Step 6 – Clone and build nexus-cli
{
    echo 20; sleep 1
    git clone https://github.com/nexus-xyz/nexus-cli > /dev/null 2>&1
    echo 50; sleep 1
    cd nexus-cli/clients/cli
    cargo build --release > /dev/null 2>&1
    echo 100; sleep 1
} | whiptail --gauge "Cloning and building Nexus CLI..." 6 50 0

# Step 7 – Move binary and create service
{
    sudo cp target/release/nexus-network /usr/local/bin/
    sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Node Service
After=network-online.target

[Service]
Type=simple
User=$USER
ExecStart=/usr/local/bin/nexus-network start --node-id $NODE_ID --headless
Restart=always
RestartSec=2
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable nexus
    sudo systemctl start nexus
} > /dev/null 2>&1

# Step 8 – Final confirmation
whiptail --title "🎉 Done!" --msgbox "Your Nexus node has been installed and is now running as a service!\n\nPress OK to watch the logs in real time." 12 60

# Show logs
clear
echo "${GREEN}✅ Node running successfully! Showing logs below:${RESET}"
echo "${CYAN}Press Ctrl+C to exit.${RESET}"
sleep 2
journalctl -u nexus -f
