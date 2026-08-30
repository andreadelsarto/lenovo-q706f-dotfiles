# 📱 Lenovo Tab P11/P12 Pro (Q706F) — postmarketOS Dotfiles & Wayback Backup

[![OS: postmarketOS edge](https://img.shields.io/badge/OS-postmarketOS%20edge-009900.svg)](https://postmarketos.org)
[![Desktop: KDE Plasma](https://img.shields.io/badge/Desktop-KDE%20Plasma-1d99f3.svg)](https://kde.org/plasma-desktop/)
[![Hardware: Snapdragon 870](https://img.shields.io/badge/SoC-Qualcomm%20SM8250-red.svg)]()
[![Display: OLED 120Hz](https://img.shields.io/badge/Display-OLED%20120Hz-purple.svg)]()

Repository bare Git per il backup, versioning e ripristino istantaneo (**stile "Wayback Machine"**) delle configurazioni di sistema, ambiente desktop KDE Plasma, ottimizzazioni hardware e script di utilità per il tablet **Lenovo Tab P11 Pro Gen 2 / Xiaoxin Pad Pro (lenovo-q706f)** con **postmarketOS (Alpine Linux edge)**.

---

## 📑 Documentazione Dedicata

Per mantenere la massima chiarezza e modularità, consulta le guide tematiche:

* 🛡️ **[SECURITY.md](SECURITY.md)**: Regole e linee guida per la sicurezza (gestione segreti, SSH, sudo/doas, firewall nftables, Tailscale).
* ⚡ **[OPTIMIZATIONS.md](OPTIMIZATIONS.md)**: Ottimizzazioni per display OLED, refresh 120Hz, zRAM, gestione batteria, GPU Freedreno e Waydroid on-demand.
* 📜 **[CHANGELOG.md](CHANGELOG.md)**: Registro cronologico di tutte le modifiche, upgrade di sistema e snapshot della configurazione.

---

## 🏛️ Architettura del Versioning (Bare Git)

Il repository è configurato come **Bare Git Repository** isolato in `~/.dotfiles.git`, con work-tree coincidente con `$HOME`. Questo evita directory `.git` ingombranti nella home e garantisce che solo i file esplicitamente monitorati vengano tracciati (`status.showUntrackedFiles = no`).

### Alias shell
Disponibile globalmente in `zsh`, `bash` e `ash`:
```bash
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
```

---

## 🚀 Utilizzo Rapido

### 1. Snapshot Pre-Aggiornamento ("Wayback Machine")
Prima di aggiornare il sistema o apportare modifiche pesanti allambiente grafico, esegui: