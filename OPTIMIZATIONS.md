# ⚡ Ottimizzazioni Hardware e Sistema — Lenovo Q706F (postmarketOS)

Questa guida raccoglie le ottimizzazioni implementate per sfruttare al massimo l'hardware del tablet **Lenovo Tab P11/P12 Pro (Q706F)** con SoC **Qualcomm Snapdragon 870 (SM8250)**, display **OLED 120Hz** e ambiente **KDE Plasma su Wayland**.

---

## 🖥️ 1. Display OLED & Tuning Grafico 120Hz

| Parametro | Configurazione | Obiettivo / Beneficio |
| :--- | :--- | :--- |
| **Refresh Rate** | `120 Hz` nativo (KWin Output Config) | Fluidità massima nelle animazioni touch e scrolling |
| **Tema KDE / GTK** | Breeze Dark / Black OLED (#000000) | Riduzione consumo energetico pixel spenti OLED (~30-40% risparmio batteria) |
| **Prompt Starship** | Palette a basso contrasto per OLED (`#555e70`) | Eliminazione abbagliamento notturno e prevenzione burn-in |
| **Fontconfig** | Subpixel rendering con hintslight | Resa ottimale dei caratteri su matrice OLED ad alta densità (2.5K) |

---

## 🚀 2. Gestione Memoria (zRAM & Sysctl Tuning)

Configurazioni applicate in `/etc/sysctl.d/99-mac-memory-tuning.conf` e gestione zRAM:

```ini
# Ottimizzazioni memoria e swap per postmarketOS
vm.swappiness = 100
vm.vfs_cache_pressure = 50
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
```

* **zRAM con algoritmo di compressione lz4/zstd**: Estende la RAM fisica disponibile comprimendo le pagine in memoria anziché effettuare swap su disco eMMC/UFS, migliorando la reattività e riducendo l'usura della memoria flash.
* **Comando rapido di monitoraggio**:
  ```bash
  mem   # alias per free -h && zramctl
  ```

---

## 🎮 3. GPU Freedreno & Driver Grafici Mesa

* **Driver Mesa Vulkan Freedreno (`mesa-vulkan-freedreno`)**: Accelerazione grafica 3D hardware nativa per GPU Adreno 650.
* **Mesa EGL / GBM**: Compositing Wayland hardware completo tramite KWin Wayland, con zero tearing e latenza di input ridotta per interazione touch/penna.
* **Compatibilità Emulatori e Giochi**: Pipeline ottimizzata per RetroArch, ScummVM e DeckLauncher.

---

## 🔋 4. Risparmio Energetico & Servizi Standby

### Always-On-Display (AOD)
* **`aod-idle.service`**: Servizio systemd in spazio utente che attiva il widget orologio minimale a schermo spento/basso consumo quando il tablet entra in idle.

### Waydroid On-Demand
* **Waydroid Toggle (`wt`)**: Il demone e la sessione container Waydroid consumano risorse CPU/RAM anche in background.
* Con l'alias `wt` (`waydroid-toggle`), il container viene avviato solo quando necessario e terminato completamente al termine dell'uso:
  ```bash
  wt    # Avvia o arresta la sessione Waydroid con rilascio immediato della memoria
  ```

### Monitoraggio Batteria BQ27541
* **`bat`**: Lettura istantanea dello stato del chip indicatore di carica Qualcomm/TI:
  ```bash
  bat   # Legge /sys/class/power_supply/bq27541-0/capacity
  ```

---

## 🐚 5. Shell ZSH e Avvio Istantaneo

* **Autoload moduli e compilazione cache**: `autoload -Uz compinit` e cache `.zcompdump`.
* **Plugin asincroni**: Caricamento di `zsh-autosuggestions` e `zsh-syntax-highlighting` da `/usr/share/zsh/plugins/`.
* **Storico ottimizzato**: `HISTSIZE=10000`, `SHARE_HISTORY`, eliminazione duplicati e righe vuote consecutive.
