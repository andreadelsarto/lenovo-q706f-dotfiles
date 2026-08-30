# 🛡️ Regole e Linee Guida per la Sicurezza — postmarketOS Dotfiles

Questo documento definisce le policy di sicurezza, le buone pratiche e le regole operative adottate per la gestione del tablet **Lenovo Q706F** e del relativo repository dotfiles.

---

## 🔒 1. Gestione dei Segreti e Privacy nel Repository

### Regola d'Oro: MAI committare credenziali o token
Il repository dotfiles traccia **esclusivamente** configurazioni non sensibili. Prima di eseguire `dotfiles add`, verificare che i file non contengano:
* Chiavi private SSH (`~/.ssh/id_*`).
* Token API, token GitHub, password o token OAuth.
* Profili completi di browser contenenti cookie e cronologie (`~/.mozilla/`, `~/.config/chromium/Default/Cookies`, ecc.).
* File di connessione di rete con password in chiaro (`/etc/NetworkManager/system-connections/`).
* File di cache o database locali (`~/.cache/`, `~/.local/share/evolution/`, ecc.).

> [!CAUTION]
> Nel caso in cui un segreto venga aggiunto per errore al repository Git, eseguire immediatamente la rotazione/revoca della chiave sul servizio interessato, poiché riscrivere la cronologia git non garantisce che i dati non siano stati letti.

---

## 🔑 2. Gestione Accessi SSH e Permessi Chiavi

1. **Permessi Rigidi**:
   - `~/.ssh/`: permessi impostati a `700` (`rwx------`).
   - `~/.ssh/authorized_keys`, `~/.ssh/id_*`, `~/.ssh/config`: permessi impostati a `600` (`rw-------`).
2. **Separazione delle Chiavi**:
   - La chiave per la sincronizzazione GitHub (`id_ed25519_pc`) è dedicata e isolata in `~/.ssh/config`.
   - L'accesso SSH al tablet da rete locale o Tailscale è consentito esclusivamente tramite autenticazione a chiave pubblica (`PasswordAuthentication no` raccomandato su sshd).

---

## 🛡️ 3. Privilegi Utente e Configurazione Sudo

1. **Principio del Minimo Privilegio**:
   - Nessuna applicazione desktop o interfaccia grafica (KDE Plasma, Firefox, Waydroid) deve essere eseguita come utente `root`.
2. **Regole Sudoers Dedicate**:
   - Le autorizzazioni `NOPASSWD` sono circoscritte esclusivamente a script specifici di utilità (es. `/etc/sudoers.d/99-waydroid-toggle` per avviare/fermare il container senza esporre una shell root globale).
3. **Audit del Sistema**:
   - Eseguire periodicamente `sudo apk audit` per verificare l'integrità dei binari di sistema e dei file di configurazione `/etc/`.

---

## 🌐 4. Sicurezza di Rete e Firewall (nftables & Tailscale)

1. **Firewall locale (`nftables`)**:
   - Porte in ascolto limitate: solo SSH (porta 22) e KDE Connect (porte UDP/TCP 1714-1764) limitate alla subnet locale (`192.168.1.0/24`).
   - Le regole per KDE Connect sono gestite in `/etc/nftables.d/50-kdeconnect.nft`.
2. **Accesso Remoto via Tailscale**:
   - Le connessioni fuori dalla LAN domestica transitano tramite rete crittografata WireGuard su Tailscale.
   - I nodi offline o non più in uso devono essere revocati dalla dashboard di Tailscale.

---

## 📱 5. Blocco Schermo e Protezione Dati su Dispositivo

* **KScreenLocker**: Blocco automatico dello schermo impostato a 5 minuti di inattività (`~/.config/kscreenlockerrc`).
* **Protezione Sensori e Waydroid**: Il container Android Waydroid non ha accesso root persistente e viene fermato automaticamente quando non in uso tramite lo script di toggle.
