# DomainHunter

Bash tabanlı domain ve subdomain keşif aracı. CachyOS / Arch Linux hedeflenerek hazırlanır.

## Kapsam

- Pasif alt alan adı keşfi (ör. crt.sh, Subfinder, Assetfinder)
- Aktif DNS wordlist keşfi
- DNS kayıt analizi
- HTTP/HTTPS canlılık kontrolü
- İzinli hedeflerde port keşfi
- TXT, CSV, JSON ve HTML raporlama

## Güvenli kullanım

Aracı yalnızca sahibi olduğunuz veya yazılı olarak test izniniz bulunan alan adlarında kullanın. Aktif sorgular ve port kontrolleri hedef sistemlere trafik gönderir; hız sınırlarını ve kapsamı hedef sahibinin kurallarına göre belirleyin.

## Kurulum

```bash
git clone https://github.com/umutakksy/Network.git
cd Network
chmod +x domainhunter.sh install.sh
./install.sh
```

Araçlar kurulmadan önce kurulum betiği bağımlılıkları ve Go tabanlı araçları kontrol eder. Ana menü:

```bash
./domainhunter.sh
```

## Geliştirme durumu

İlk commit proje iskeletini içerir. Modüller aşamalı olarak uygulanacaktır.
