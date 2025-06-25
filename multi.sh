#!/bin/bash

# Define colors
CYAN='\033[0;36m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Header display
display_header() {
    clear
    echo -e "${CYAN}"
    echo -e " ${BLUE} ██████╗ ██╗  ██╗    ██████╗ ███████╗███╗   ██╗ █████╗ ███╗   ██╗${NC}"
    echo -e " ${BLUE}██╔═████╗╚██╗██╔╝    ██╔══██╗██╔════╝████╗  ██║██╔══██╗████╗  ██║${NC}"
    echo -e " ${BLUE}██║██╔██║ ╚███╔╝     ██████╔╝█████╗  ██╔██╗ ██║███████║██╔██╗ ██║${NC}"
    echo -e " ${BLUE}████╔╝██║ ██╔██╗     ██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║██║╚██╗██║${NC}"
    echo -e " ${BLUE}╚██████╔╝██╔╝ ██╗    ██║  ██║███████╗██║ ╚████║██║  ██║██║ ╚████║${NC}"
    echo -e " ${BLUE}╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo -e "${BLUE}===============================================================${NC}"
    echo -e "${GREEN}         ✨ Nexus Multi-Nodes Auto-Installer ✨${NC}"
    echo -e "${BLUE}===============================================================${NC}"
}

display_header

# Step 1: Enable swap if missing
echo -e "\n${GREEN}🧠 Checking system memory swap...${NC}"
if ! swapon --show | grep -q '/swapfile'; then
  echo "💾 Creating 2GB swapfile to improve stability..."
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
  echo "✅ Swap is now active."
else
  echo "💾 Swap is already active."
fi

# Step 2: Ask how many nodes to run
echo ""
read -p "🔢 How many Nexus nodes would you like to run? " NODE_COUNT
if ! [[ "$NODE_COUNT" =~ ^[0-9]+$ ]]; then
  echo "❌ Invalid input. Please enter a numeric value."
  exit 1
fi

# Step 3: Install dependencies
echo -e "\n${GREEN}📦 Installing required packages...${NC}"
sudo apt update -y
REQUIRED_PKGS=(build-essential pkg-config libssl-dev git git-all protobuf-compiler curl)
for pkg in "${REQUIRED_PKGS[@]}"; do
  dpkg -s "$pkg" &>/dev/null || sudo apt install -y "$pkg"
  sleep 0.5
done

# Step 4: Install Rust if not present
if ! command -v rustup &>/dev/null; then
  echo -e "\n🦀 Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

source "$HOME/.cargo/env"
rustup target add riscv32i-unknown-none-elf

# Step 5: Clone and build Nexus CLI
echo -e "\n📥 Setting up Nexus CLI..."
if [ ! -d "$HOME/nexus-cli/clients/cli" ]; then
  rm -rf "$HOME/nexus-cli"
  git clone https://github.com/nexus-xyz/nexus-cli "$HOME/nexus-cli"
fi

cd "$HOME/nexus-cli/clients/cli" || exit 1
cargo build --release -j 2
sudo cp target/release/nexus-network /usr/local/bin/

# Step 6: Set up nodes
mkdir -p "$HOME/nexus-multi"

for ((i = 1; i <= NODE_COUNT; i++)); do
  echo -e "\n🚀 Configuring Node $i..."
  read -p "🔑 Enter Node ID for node$i: " NODE_ID

  NODE_DIR="$HOME/nexus-multi/node$i"
  mkdir -p "$NODE_DIR"
  echo "{ \"node_id\": \"$NODE_ID\" }" > "$NODE_DIR/config.json"

  SERVICE_NAME="nexus-node$i"
  SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"

  if [ -f "$SERVICE_PATH" ]; then
    echo "⚠️  Service $SERVICE_NAME already exists. Backing it up..."
    sudo mv "$SERVICE_PATH" "$SERVICE_PATH.bak.$(date +%s)"
  fi

  sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Nexus Node $i - Managed by Hustle Script
After=network-online.target
StartLimitIntervalSec=200
StartLimitBurst=5

[Service]
Type=simple
User=$USER
WorkingDirectory=$NODE_DIR
ExecStart=/usr/local/bin/nexus-network start --node-id $NODE_ID --headless
Restart=on-failure
RestartSec=15
LimitNOFILE=65535
Environment="NEXUS_HOME=$NODE_DIR"

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable "$SERVICE_NAME"
  sudo systemctl start "$SERVICE_NAME"

  sleep 3
  STATUS=$(systemctl is-active "$SERVICE_NAME")
  if [ "$STATUS" == "active" ]; then
    echo "✅ Node $i is up and running as service: $SERVICE_NAME"
  else
    echo "❌ Node $i failed to start. Showing logs:"
    journalctl -u "$SERVICE_NAME" --no-pager | tail -n 20
  fi
done

# Final notes
echo -e "\n${GREEN}🎉 All nodes set up successfully!${NC}"
echo -e "📄 To view logs for a node: ${CYAN}journalctl -u nexus-nodeX -f${NC}"
echo -e "🛑 To stop a node:         ${CYAN}sudo systemctl stop nexus-nodeX${NC}"
echo -e "🔁 To restart a node:      ${CYAN}sudo systemctl restart nexus-nodeX${NC}"
