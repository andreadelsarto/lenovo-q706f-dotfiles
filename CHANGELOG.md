# 📜 Changelog — Lenovo Q706F postmarketOS Dotfiles

Tutte le modifiche rilevanti a questo repository e all'ambiente tablet vengono documentate in questo file.
Il formato segue le linee guida di [Keep a Changelog](https://keepachangelog.com/it/1.0.0/).

---

## [Unreleased]
### Added
- Linee guida e documentazione per snapshot pre-aggiornamento e rollback.

---

## [2026-08-30] — Configurazione Bare Git, Baseline Snapshot & Upgrade
### Added
- **Bare Git Dotfiles Architecture**: Inizializzato repository bare in `~/.dotfiles.git` con work-tree in `$HOME` e `showUntrackedFiles = no`.
- **Shell Alias `dotfiles`**: Configurato in `.zshrc`, `.profile` e `.bashrc` per gestire il tracciamento rapido dei file di sistema.
- **Helper Script `pre-update-snapshot.sh`**: Creato script in `~/.local/bin/` per automatizzare `dotfiles add -u`, commit con timestamp, tag `pre-update` e push su GitHub.
- **Tracciamento Configurazioni KDE / Plasma**:
  - Layout desktop, pannelli e applet (`plasma-org.kde.plasma.desktop-appletsrc`, `plasmashellrc`, `plasmarc`).
  - Configurazione compositor e output display KWin (`kwinrc`, `kwinoutputconfig.json`, `kwinrulesrc`).
  - Temi globali, icone e scorciatoie (`kdeglobals`, `kglobalshortcutsrc`, `gtk-3.0/`, `gtk-4.0/`, `xsettingsd/`).
  - Gestione alimentazione e blocco schermo (`powerdevilrc`, `kscreenlockerrc`).
  - Plasmoidi custom: `org.kde.plasma.decklauncher` (launcher touch in stile Steam Deck) e `org.kde.plasma.wordclock` (orologio testuale AOD).
- **Servizi Systemd Utente**:
  - `waydroid-session.service` per gestione container Android.
  - `aod-idle.service` per modalità Always-On-Display su schermo OLED.
- **Integrazione GitHub**: Collegato remote `origin` a `git@github.com:andreadelsarto/lenovo-q706f-dotfiles.git` con autenticazione via chiave SSH dedicata.

### Changed
- **Aggiornamento di Sistema (postmarketOS edge)**: Eseguito upgrade di 88 pacchetti di sistema, inclusi:
  - Kernel initramfs e generazione nuovo `boot.img` per Qualcomm Snapdragon 870 (`sm8250-lenovo-q706f`).
  - Stack grafico `mesa` (v26.1.6-r1, supporto Freedreno Vulkan/EGL).
  - Browser: `firefox` (v154.0) e `chromium` (v152.0).
  - Audio & Multimedialità: `wireplumber` (v0.5.16), `libcamera` e pacchetti KDE Gear 26.08.

---

## 📝 Come aggiornare il Changelog
Quando effettui modifiche significative (nuove applicazioni, modifiche ai temi o aggiornamenti firmware):
1. Aggiungi le voci pertinenti sotto `[Unreleased]` o crea una nuova sezione con la data `[AAAA-MM-GG]`.
2. Esegui `pre-update-snapshot.sh` o committa le modifiche con `dotfiles commit -m "docs: aggiornato changelog"`.
