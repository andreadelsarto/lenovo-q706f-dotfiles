#!/usr/bin/env bash
set -e

TABLET_IP="${1:-192.168.1.14}"
TABLET_USER="${2:-user}"
TARGET_DIR="/home/$TABLET_USER/.local/share/plasma/plasmoids/org.kde.plasma.decklauncher"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SSH_OPTS="-F /dev/null -o StrictHostKeyChecking=no"

echo "=========================================================="
echo "  Deploy NebulaDeck su Tablet ($TABLET_USER@$TABLET_IP) "
echo "=========================================================="

echo "[1/3] Creazione directory remota..."
ssh $SSH_OPTS "$TABLET_USER@$TABLET_IP" "mkdir -p $TARGET_DIR"

echo "[2/3] Sincronizzazione file sorgenti..."
rsync -avz -e "ssh $SSH_OPTS" --delete --exclude '.git' --exclude 'package/deploy_tablet.sh' "$SCRIPT_DIR/" "$TABLET_USER@$TABLET_IP:$TARGET_DIR/"

echo "[3/3] Registrazione plasmoide con kpackagetool6..."
ssh $SSH_OPTS "$TABLET_USER@$TABLET_IP" << 'REMOTECMD'
kpackagetool6 -t Plasma/Applet --upgrade ~/.local/share/plasma/plasmoids/org.kde.plasma.decklauncher 2>/dev/null || \
kpackagetool6 -t Plasma/Applet --install ~/.local/share/plasma/plasmoids/org.kde.plasma.decklauncher 2>/dev/null || true
echo "Plasmoide registrato correttamente su Plasma 6!"
REMOTECMD

echo "=========================================================="
echo "Deployment completato con successo!"
echo "=========================================================="
