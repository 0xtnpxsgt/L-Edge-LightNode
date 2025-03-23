# L-Edge-LightNode

## Overview
LayerEdge is the first decentralized network that enhances the capabilities of Bitcoin Blockspace with ZK & BitVM, enabling every layer to be secured on Bitcoin.

# Installation & Setup

## 1. Install Screen 
```bash
apt-install screen
```
## 1.1 Install GO
```bash
wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.bashrc
```

## 2. Install Light-Node
```bash
rm -rf layeredge.sh
wget https://raw.githubusercontent.com/0xtnpxsgt/L-Edge-LightNode/refs/heads/main/layeredge.sh -O layeredge.sh && chmod +x layeredge.sh && ./layeredge.sh
```

```bash
cd $HOME/light-node/
screen -S lightnode
```
## 3.create .env file
```
nano .env
```
- Copy & Paste This 
- Add Your Private Key: PRIVATE_KEY=XXXXXXXXXXXXXXXXXXXXX
```
GRPC_URL=grpc.testnet.layeredge.io:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=https://layeredge.mintair.xyz/
API_REQUEST_TIMEOUT=100
POINTS_API=https://light-node.layeredge.io
PRIVATE_KEY='your-cli-node-private-key'
```

## 4.run light node
```
go build
./light-node
```
## 5.Detach Screen 
```bash
ctrl A + D
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
