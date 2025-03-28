# 📡 xl2tp — L2TP without IPsec Setup Script

Simple script to set up an L2TP VPN **without IPsec**, useful for specific client devices like some Asus routers.

> ✅ Tested on **Ubuntu 22.04**

---

## 🚀 Features

- 🛠 Installs and configures `xl2tpd`
- 🔐 Adds user authentication via CHAP
- 🔥 Sets up IP forwarding and firewall rules (iptables)
- 🧠 Auto-detects external network interface
- 📋 Displays final connection info (IP address, username, password)

---

## 📦 Installation & Usage

### 1. Clone this repository

```bash
git clone https://github.com/nstrvntn/xl2tp.git
cd xl2tp
```

### 2. Run the script

You can run the script directly:

```bash
bash xl2tp.sh
```

Or make it executable and run:

```bash
chmod +x xl2tp.sh
./xl2tp.sh
```

---

## 📥 Input required

During script execution, you will be prompted to enter:

- **Username**
- **Password**

These credentials will be securely stored in:

```
/etc/ppp/chap-secrets
```

---

## 🧪 Example output

```text
[*] Installing xl2tpd...
[*] Configuring...
[*] VPN is ready!

Server IP:    123.456.789.012
Username:     myuser
Password:     mypass
```

---

## 📎 Notes

- Ensure your server **accepts UDP traffic on port 1701**.
- This script sets up **plain L2TP without IPsec** — make sure your client supports it.
- Tested on a clean installation of **Ubuntu 22.04 LTS**.

---
