#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run the button logo script (optional branding)
curl -sL https://raw.githubusercontent.com/0xtnpxsgt/logo/refs/heads/main/logo.sh | bash
sleep 5

echo -e "🚀 Starting setup process..."
rm -rf $HOME/light-node
echo -e "🔗 Cloning repository..."
git clone https://github.com/Layer-Edge/light-node.git && echo -e "✅ Repository cloned!"
cd light-node

echo -e "📥 Downloading and installing dependencies..."
curl -L https://risczero.com/install | bash && echo -e "✅ RISC0 installer downloaded!"

# Ensure RISC0 is in the PATH
export PATH="$HOME/.risc0/bin:$PATH"
echo 'export PATH="$HOME/.risc0/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install RISC0 toolchain
echo -e "🔧 Installing RISC0 toolchain..."
rzup install && echo -e "✅ RISC0 toolchain installed!"
source ~/.bashrc

# Verify installation
if ! command -v rzup &> /dev/null; then
    echo -e "${RED}❌ RISC0 toolchain installation failed!${NC}"
    exit 1
fi
echo -e "✅ RISC0 toolchain is available!"

echo -e "🔄 Applying environment variables..."
export GRPC_URL=grpc.testnet.layeredge.io:9090
export CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
export ZK_PROVER_URL=https://layeredge.mintair.xyz/
export API_REQUEST_TIMEOUT=100
export POINTS_API=https://light-node.layeredge.io
echo -e "🔑 Please enter your private key: "
read PRIVATE_KEY
echo -e "✅ Private key set!"
export PRIVATE_KEY

# Save environment variables to a file
ENV_FILE="$HOME/light-node/.env"
echo "GRPC_URL=$GRPC_URL" > $ENV_FILE
echo "CONTRACT_ADDR=$CONTRACT_ADDR" >> $ENV_FILE
echo "ZK_PROVER_URL=$ZK_PROVER_URL" >> $ENV_FILE
echo "API_REQUEST_TIMEOUT=$API_REQUEST_TIMEOUT" >> $ENV_FILE
echo "POINTS_API=$POINTS_API" >> $ENV_FILE
echo "PRIVATE_KEY=$PRIVATE_KEY" >> $ENV_FILE

echo -e "🛠️ Building risc0-merkle-service..."
cd risc0-merkle-service
cargo clean
cargo build --release && echo -e "✅ risc0-merkle-service built!"

cd ..
echo -e "🛠️ Building LayerEdge Light Node..."
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
go build && echo -e "✅ Light Node built!"

# Create logs directory
LOG_DIR="/var/log/layeredge"
mkdir -p $LOG_DIR

# Create systemd service for risc0-merkle-service
echo -e "⚙️ Setting up systemd service for risc0-merkle-service..."
sudo bash -c "cat > /etc/systemd/system/layeredge-merkle.service <<EOF
[Unit]
Description=LayerEdge Merkle Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/light-node/risc0-merkle-service
ExecStart=$HOME/.cargo/bin/cargo run --release
Restart=on-failure
RestartSec=10
StandardOutput=append:$LOG_DIR/merkle.log
StandardError=append:$LOG_DIR/merkle-error.log

[Install]
WantedBy=multi-user.target
EOF"

# Create systemd service for Light Node
echo -e "⚙️ Setting up systemd service for Light Node..."
sudo bash -c "cat > /etc/systemd/system/layeredge-node.service <<EOF
[Unit]
Description=LayerEdge Light Node
After=layeredge-merkle.service
Requires=layeredge-merkle.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/light-node
EnvironmentFile=$HOME/light-node/.env
ExecStart=$HOME/light-node/light-node
Restart=on-failure
RestartSec=10
StandardOutput=append:$LOG_DIR/node.log
StandardError=append:$LOG_DIR/node-error.log

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd and enable services
echo -e "🔄 Reloading systemd and enabling services..."
sudo systemctl daemon-reload
sudo systemctl enable layeredge-merkle.service
sudo systemctl enable layeredge-node.service

# Start services
echo -e "🚀 Starting services..."
sudo systemctl start layeredge-merkle.service
sudo systemctl start layeredge-node.service

# Check service status
sleep 5
if systemctl is-active --quiet layeredge-merkle.service && systemctl is-active --quiet layeredge-node.service; then
    echo -e "${GREEN}🎉 Setup complete! Both services are running under systemd.${NC}"
else
    echo -e "${RED}❌ One or both services failed to start! Check logs for details.${NC}"
    echo -e "🔍 Check logs using:"
    echo -e "   journalctl -u layeredge-merkle.service --no-pager | tail -20"
    echo -e "   journalctl -u layeredge-node.service --no-pager | tail -20"
fi
