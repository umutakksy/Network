#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v pacman >/dev/null 2>&1; then
  echo "Bu kurulum CachyOS / Arch Linux içindir." >&2
  exit 1
fi

echo "[+] Sistem paketleri kuruluyor/güncelleniyor..."
sudo pacman -S --needed --noconfirm git curl jq bind go python nmap

export PATH="$HOME/go/bin:$PATH"
mkdir -p "$HOME/go/bin"

install_go_tool() {
  local package="$1" binary="$2"
  if [[ -x "$HOME/go/bin/$binary" ]]; then
    echo "[=] $binary zaten kurulu: $HOME/go/bin/$binary"
    return 0
  fi
  echo "[+] $binary kuruluyor..."
  GOBIN="$HOME/go/bin" go install "$package"
}

install_go_tool github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest subfinder
install_go_tool github.com/projectdiscovery/dnsx/cmd/dnsx@latest dnsx
install_go_tool github.com/projectdiscovery/httpx/cmd/httpx@latest httpx
install_go_tool github.com/tomnomnom/assetfinder@latest assetfinder

if [[ ! -x "$HOME/go/bin/amass" ]]; then
  echo "[+] OWASP Amass v5 kuruluyor..."
  CGO_ENABLED=0 GOBIN="$HOME/go/bin" go install -v github.com/owasp-amass/amass/v5/cmd/amass@main
else
  echo "[=] Amass zaten kurulu: $HOME/go/bin/amass"
fi

# Bash uyumluluğu
if ! grep -Fq 'HOME/go/bin' "$HOME/.bashrc" 2>/dev/null; then
  printf '\nexport PATH="$HOME/go/bin:$PATH"\n' >> "$HOME/.bashrc"
fi

# Fish uyumluluğu
if command -v fish >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/fish/conf.d"
  printf 'fish_add_path "$HOME/go/bin"\n' > "$HOME/.config/fish/conf.d/domainhunter.fish"
fi

export PATH="$HOME/go/bin:$PATH"
echo
echo "[+] Kurulum kontrolü:"
for tool in git curl jq dig go nmap amass subfinder dnsx httpx assetfinder; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  [OK] %-12s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '  [--] %s bulunamadı / PATH dışında\n' "$tool"
  fi
done
echo
echo "Bash: yeni terminal açın veya 'source ~/.bashrc' çalıştırın."
echo "Fish: yeni terminal açın veya 'fish_add_path $HOME/go/bin' çalıştırın."
