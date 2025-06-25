# 🚀 Nexus CLI: One-Command Installation Guide
Set up your Nexus node in **two ways**: **Simple (Single Node)** or **Multiple Nodes**. Choose the method that fits your needs!

---

## 🚦 Simple Node Setup (Recommended for Most Users)

This method runs **one node per VPS or PC**.

### **Install & Run Nexus Node**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/HustleAirdrops/Nexus-Node-One-Command/main/installation.sh)
```

- The script will prompt for your **Node ID** (see below).
- Your node will start automatically after setup.

#### 🔍 **How to Find Your Node ID**

1. 🌐 Visit [https://app.nexus.xyz/nodes](https://app.nexus.xyz/nodes)
2. 🔑 Login and copy your **Node ID** from the dashboard.
3. 📋 Paste it when prompted during installation.

---

## 🔄 Multiple Node Setup (Advanced: Run Multiple Nodes on One VPS/PC)

> **Note:** 1 vps = Multiple node IDs of one account run. ( Around 8gb Ram = 1 Nexus multi )

### **Run the Multi-Node Script**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/HustleAirdrops/Nexus-Node-One-Command/main/multi.sh)
```

- The script will ask **how many nodes** you want to run.
- Enter the number, then provide a **Node ID** for each node (one by one).

---

## 🛠️ Useful Commands

### **Start Node Manually (Single Node)**

```bash
nexus-network start --node-id <Node_ID>
```
Replace `<Node_ID>` with your actual Node ID.

### 📄 **Check Node Logs**

#### **For Single Node Setup**

```bash
journalctl -fu nexus -o cat
```

#### **For Multiple Node Setup**

```bash
journalctl -u nexus-nodeX -f
```
> 📌 Replace `X` with the node number (e.g., 1, 2, ...).

### 🗑️ **Delete All Nodes (Cleanup Commands)**

#### **For Single Node Setup**

```bash
sudo systemctl stop nexus && \
sudo systemctl disable nexus && \
sudo rm /etc/systemd/system/nexus.service && \
sudo systemctl daemon-reload && \
sudo rm -rf ~/nexus-cli && \
sudo rm -rf ~/.cargo && \
sudo rm -rf /usr/local/bin/nexus-network
```

#### **For Multiple Node Setup**

```bash
sudo systemctl stop $(systemctl list-units --type=service --no-pager | grep nexus-node | awk '{print $1}') && \
sudo systemctl disable $(systemctl list-units --type=service --no-pager | grep nexus-node | awk '{print $1}') && \
sudo rm -rf ~/nexus-multi && \
sudo rm -f /etc/systemd/system/nexus-node* && \
sudo systemctl daemon-reload && \
sudo systemctl reset-failed
```

---
