# DomainHunter

CachyOS / Arch Linux için Bash tabanlı domain keşif ve envanter aracı.

## Özellikler

- Pasif keşif: Subfinder, OWASP Amass (passive), Assetfinder ve crt.sh
- Aktif DNS wordlist keşfi (sınırlandırılabilir sorgu sayısı)
- A, AAAA, CNAME, MX, NS, TXT, SOA ve CAA kayıt analizi
- HTTP/HTTPS canlılık, durum kodu, başlık ve teknoloji tespiti (ProjectDiscovery httpx)
- Nmap ile sınırlı TCP servis/sürüm keşfi
- Tarama başına ayrı sonuç klasörü ve JSON/HTML raporlama

## Kurulum

    git clone https://github.com/umutakksy/Network.git
    cd Network
    chmod +x domainhunter.sh install.sh
    ./install.sh
    export PATH="$HOME/go/bin:$PATH"
    ./domainhunter.sh

## Kullanım ve yetkilendirme

Yalnızca sahibi olduğunuz veya yazılı olarak test izniniz bulunan domainlerde kullanın. Aktif DNS sorguları, HTTP istekleri ve Nmap port kontrolleri hedef sistemlere trafik üretir. Tam tarama öncesinde yetki onayı istenir. Port taraması menüden ayrıca başlatılır.

## Sonuçlar

Her çalıştırma results/<domain>_<timestamp>/ altında tutulur. results/latest.txt son taramanın dizinini gösterir. Sonuç klasörlerini paylaşmadan önce hassas verileri kontrol edin.

Bu proje keşif ve varlık envanteri aracıdır; exploit, kimlik bilgisi denemesi veya güvenlik açığı istismarı gerçekleştirmez.
