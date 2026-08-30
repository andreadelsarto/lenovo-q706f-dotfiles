# ==============================================================================
# 🚀 ULTRA-OPTIMIZED ZSH CONFIG FOR LENOVO TAB P12 PRO (OLED 120Hz)
# ==============================================================================

# Enable Colors and Completion
autoload -U colors && colors
autoload -Uz compinit && compinit

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Load Syntax Highlighting and Autosuggestions
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions Color (Subtle Gray for OLED)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555e70"

# Useful Clean Aliases
alias update="echo 1234 | sudo -S apk update && echo 1234 | sudo -S apk upgrade"
alias ll="ls -lah --color=auto"
alias la="ls -A --color=auto"
alias l="ls -CF --color=auto"
alias cls="clear"
alias mem="free -h && echo '--- zRAM Status ---' && zramctl"
alias bat="cat /sys/class/power_supply/bq27541-0/capacity"
alias batbench="battery-benchmark"
alias wt="waydroid-toggle"
alias ts="tailscale"

# Fast Starship Prompt Initialization
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    PROMPT='%F{cyan}%n@lenovo-p12%f:%F{yellow}%~%f%F{green} ❯%f '
fi
alias batlog=\ tail -n 30 -f /home/user/Documents/consumo_batteria.log\

# Dotfiles bare git alias & PATH
export PATH="$HOME/.local/bin:$PATH"
alias dotfiles="/usr/bin/git --git-dir=\$HOME/.dotfiles.git/ --work-tree=\$HOME"
