#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

APPLET_ID="org.kde.plasma.decklauncher"

echo "================================================="
echo "       Installazione NebulaDeck (Plasma 6)       "
echo "================================================="

if ! command -v kpackagetool6 &> /dev/null; then
    echo "Errore: kpackagetool6 non trovato nel PATH di sistema."
    exit 1
fi

echo "Verifica pacchetto esistente..."
if kpackagetool6 -t Plasma/Applet --show "$APPLET_ID" &> /dev/null; then
    echo "Aggiornamento del plasmoide esistente..."
    kpackagetool6 -t Plasma/Applet --upgrade .
else
    echo "Installazione nuovo plasmoide..."
    kpackagetool6 -t Plasma/Applet --install .
fi

echo "================================================="
echo "Installazione completata con successo!"
echo "ID Plasmoide: $APPLET_ID"
echo "Puoi aggiungerlo al desktop/pannello o provarlo con:"
echo "  plasmawindowed $APPLET_ID"
echo "================================================="
