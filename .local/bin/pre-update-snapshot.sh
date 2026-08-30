#!/bin/sh
set -e

# Dotfiles Git bare repository command
DOTFILES="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"

echo "==> [Snapshot] Preparazione snapshot dotfiles..."

# Aggiunge automaticamente tutte le modifiche ai file già tracciati
$DOTFILES add -u

# Verifica se ci sono modifiche da committare
if $DOTFILES diff-index --quiet HEAD -- 2>/dev/null; then
    echo "==> [Snapshot] Nessuna modifica rilevata nei file tracciati."
else
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
    $DOTFILES commit -m "pre-update snapshot: $TIMESTAMP"
    echo "==> [Snapshot] Commit completato: pre-update snapshot: $TIMESTAMP"
fi

# Aggiorna/forza il tag pre-update localmente
$DOTFILES tag -f pre-update
echo "==> [Snapshot] Tag \"pre-update\" aggiornato con successo."

# Tenta il push su origin main e sincronizza i tag forzando l'aggiornamento del tag pre-update
if $DOTFILES remote | grep -q "^origin$"; then
    echo "==> [Snapshot] Remote origin trovato. Tentativo di push..."
    if $DOTFILES push origin main && $DOTFILES push origin refs/tags/pre-update --force; then
        echo "==> [Snapshot] Push completato con successo."
    else
        echo "==> [Snapshot] Attenzione: push fallito o permessi insufficienti."
    fi
else
    echo "==> [Snapshot] Nessun remote origin configurato. Push saltato."
fi

echo "==> [Snapshot] Snapshot completato."
