# 🚀 Nexus CLI — One-Command Installation Guide

Easily deploy your Nexus node using a single command. Choose between:

- 🟢 **Simple (Single Node)** — Recommended for most users  
- 🔵 **Advanced (Multi-Node)** — Run multiple nodes on one machine

---

## 🚦 Simple Node Setup *(1 Node per VPS/PC)*

Install & run your Nexus node with one command:

```bash
source <(wget -O - https://raw.githubusercontent.com/renanls6/Nexus-Testnet-CLI-One-Command-/refs/heads/main/installation.sh)
```

🔐 You’ll be prompted for your Node ID during setup.

✅ After installation, your node will start automatically as a background service.

🔍 Find Your Node ID

🌐 Go to: https://app.nexus.xyz/nodes

🔑 Log in to your account

📋 Copy your Node ID from the dashboard

💻 Paste it when prompted during installation

🔄 Multi-Node Setup (Run multiple nodes on one VPS/PC)
⚠️ Recommended: 8GB RAM per VPS for multi-node setup



Run the multi-node installation script:


```bash
source <(wget -O - https://raw.githubusercontent.com/renanls6/Nexus-Testnet-CLI-One-Command-/refs/heads/main/multi.sh)
```

You’ll be asked:

How many nodes you want to run

A Node ID for each one (entered one-by-one)

🛠️ Useful Commands
✅ Start a node manually
bash
Copiar
Editar
nexus-network start --node-id <Your_Node_ID>
📄 View logs
Single Node Setup:

bash
Copiar
Editar
journalctl -fu nexus -o cat
Multi-Node Setup:

bash
Copiar
Editar
journalctl -u nexus-nodeX -f
📌 Replace X with your node number (1, 2, etc.)

🧹 Cleanup Commands
❌ Remove Single Node Setup
bash
Copiar
Editar
sudo systemctl stop nexus && \
sudo systemctl disable nexus && \
sudo rm /etc/systemd/system/nexus.service && \
sudo systemctl daemon-reload && \
sudo rm -rf ~/nexus-cli ~/.cargo /usr/local/bin/nexus-network
❌ Remove Multi-Node Setup
bash
Copiar
Editar
sudo systemctl stop $(systemctl list-units --type=service --no-pager | grep nexus-node | awk '{print $1}') && \
sudo systemctl disable $(systemctl list-units --type=service --no-pager | grep nexus-node | awk '{print $1}') && \
sudo rm -rf ~/nexus-multi && \
sudo rm -f /etc/systemd/system/nexus-node* && \
sudo systemctl daemon-reload && \
sudo systemctl reset-failed
🙌 Community & Support
Need help or want to contribute?

💬 Join the Nexus Discord

🛠️ Official Nexus Docs

🧑‍💻 Maintained by @renanls6

yaml
Copiar
Editar

</details>

---

Se o problema continuar mesmo após limpar e salvar corretamente, envie o conteúdo atual do seu `README.md` e posso corrigir exatamente o que está quebrando o preview.

Deseja que eu revise o arquivo real para garantir 100% de compatibilidade? Você pode colar aqui o con
