#!/bin/bash

# Definisi Warna
Green='\033[0;32m'
NC='\033[0m'

# Harus user root
if [ "$EUID" -ne 0 ]; then
  echo "Script harus dijalankan sebagai root." >&2
  exit 1
fi

# Variabel
NODE_EXPORTER_VERSION="1.8.1"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
TEMP_DIR="/tmp/node_exporter"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"
IP=$(hostname -I | awk '{print $1}')

echo -e "${Green}Otomatisasi Install Node Exporter by Rullabcd${NC}"

# Update Repository & Install curl
echo -e "${Green}Update Repository & Install curl...${NC}"
apt update && apt install -y curl tar

# Buat user node_exporter jika belum ada
if id "node_exporter" &>/dev/null; then
  echo -e "${Green}User node_exporter sudah ada.${NC}"
else
  echo -e "${Green}Menambahkan user node_exporter...${NC}"
  useradd --no-create-home --shell /bin/false node_exporter
fi

# Download & Ekstrak
echo -e "${Green}Download & Ekstrak Node Exporter...${NC}"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
curl -LO "$DOWNLOAD_URL"
tar -xzf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
cp "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" "$INSTALL_DIR"
chown node_exporter:node_exporter "$INSTALL_DIR/node_exporter"
rm -rf "$TEMP_DIR"

# Buat systemd service
echo -e "${Green}Membuat service Node Exporter...${NC}"
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
Group=node_exporter
ExecStart=$INSTALL_DIR/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan mulai service
echo -e "${Green}Reload systemd dan mulai Node Exporter...${NC}"
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo -e "${Green}Node Exporter terinstal dan berjalan di http://${IP}:9100${NC}"
