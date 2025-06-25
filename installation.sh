#!/bin/bash

# Define colors
CYAN='\033[0;36m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Header
clear
echo -e "${CYAN}"
echo -e " ${BLUE} ██████╗ ██╗  ██╗    ██████╗ ███████╗███╗   ██╗ █████╗ ███╗   ██╗${NC}"
echo -e " ${BLUE}██╔═████╗╚██╗██╔╝    ██╔══██╗██╔════╝████╗  ██║██╔══██╗████╗  ██║${NC}"
echo -e " ${BLUE}██║██╔██║ ╚███╔╝     ██████╔╝█████╗  ██╔██╗ ██║███████║██╔██╗ ██║${NC}"
echo -e " ${BLUE}████╔╝██║ ██╔██╗     ██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║██║╚██╗██║${NC}"
echo -e " ${BLUE}╚██████╔╝██╔╝ ██╗    ██║  ██║███████╗██║ ╚████║██║  ██║██║ ╚████║${NC}"
echo -e " ${BLUE}╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
echo -e "${BLUE}===============================================================${NC}"
echo -e "${BLUE}=======================================================${NC}"
echo -e "${GREEN}        ✨ Nexus CLI Node Auto-Installer ✨${NC}"
echo -e "${BLUE}=======================================================${NC}"

# Login instructions
echo -e "\n${YELLOW}🔐 Step 1: Log in to Nexus Dashboard${NC}"
echo -e "   👉 ${CYAN}https://app.nexus.xyz/nodes${NC}"
echo -e "   - Login with email OR Web3 wallet"
echo -e "   - Click 'Add CLI Node' and copy the Node ID (e.g. 345677)"

# Prompt for Node ID
while true; do
    echo ""
    read -p "$(echo -e "${GREEN}🔢 Enter your numeric Node ID: ${NC}")" yournodeid
    if [[ "$yournodeid" =~ ^[0-9]+$ ]]; then
        echo -e "${GREEN}✅ Node ID accepted: $yournodeid${NC}"
        break
    else
        echo -e "${RED}❌ Invalid input. Please enter digits only.${NC}"
    fi
done

# Install dependencies
echo -e "\n${CYAN}📦 Installing dependencies...${NC}"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y screen curl build-essential pkg-config libssl-dev git git-all protobuf-compiler

# Install Rust
echo -e "\n${CYAN}🦀 Installing Rust...${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustup target add riscv32i-unknown-none-elf

# Clone and build Nexus CLI
echo -e "\n${CYAN}📥 Cloning and building Nexus CLI...${NC}"
git clone https://github.com/nexus-xyz/nexus-cli
cd nexus-cli/clients/cli || { echo -e "${RED}❌ Failed to enter CLI directory${NC}"; exit 1; }
cargo build --release

# Copy binary
echo -e "\n${CYAN}🔧 Installing Nexus binary...${NC}"
sudo cp target/release/nexus-network /usr/local/bin/
nexus-network --version

# Create systemd service
echo -e "\n${CYAN}🛠️  Creating systemd service...${NC}"
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus CLI Node
After=network-online.target

[Service]
Type=simple
User=$USER
ExecStart=/usr/local/bin/nexus-network start --node-id $yournodeid --headless
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Start the service
echo -e "\n${CYAN}🚀 Starting node service...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

sleep 2
if [[ $(systemctl is-active nexus) == "active" ]]; then
    echo -e "\n${GREEN}🎉 Nexus node is up and running!${NC}"
else
    echo -e "\n${RED}❌ Failed to start the Nexus node.${NC}"
    journalctl -u nexus --no-pager | tail -n 20
    exit 1
fi

# Final message
echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${GREEN}📄 Live logs will be shown below. Press Ctrl+C to exit.${NC}"
echo -e "${BLUE}=======================================================${NC}"
sleep 2
journalctl -u nexus -f
