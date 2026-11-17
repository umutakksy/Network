#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v pacman >/dev/null 2>&1; then
    echo "Bu kurulum betiği CachyOS / Arch Linux içindir (pacman gerekli)." >&2
    exit 1
fi

echo "[+] Sistem paketleri kontrol ediliyor..."
sudo pacman -S --needed --noconfirm git curl jq bind go python

install_go_tool() {
    local package="$1"
    local binary="$2"

    if command -v "$binary" >/dev/null 2>&1; then
        echo "[=] $binary zaten kurulu: $(command -v "$binary")"
        return 0
    fi

    echo "[+] Kuruluyor: $binary"
    GOBIN="$HOME/go/bin" go install "$package"
}

mkdir -p "$HOME/go/bin"

install_go_tool github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest subfinder
install_go_tool github.com/projectdiscovery/dnsx/cmd/dnsx@latest dnsx
install_go_tool github.com/projectdiscovery/httpx/cmd/httpx@latest httpx

if ! command -v assetfinder >/dev/null 2>&1; then
    install_go_tool github.com/tomnomnom/assetfinder@latest assetfinder
fi

if ! grep -q 'HOME/go/bin' "$HOME/.bashrc" 2>/dev/null; then
    printf '\nexport PATH="$HOME/go/bin:$PATH"\n' >> "$HOME/.bashrc"
fi

echo
echo "[+] Kurulum tamamlandı."
echo "Yeni PATH için terminali yeniden açın veya çalıştırın:"
echo 'export PATH="$HOME/go/bin:$PATH"'
echo
echo "Not: Amass sonraki aşamada ayrı, doğrulanmış kurulum adımı olarak eklenecek."
