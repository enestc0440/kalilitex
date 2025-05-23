# kalilitex
KaliLiteX

![License](https://img.shields.io/github/license/ENESxAIs/KaliLiteX?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Kali%20Linux%20%7C%20WSL2-red?style=flat-square)
![Python](https://img.shields.io/badge/python-3.8%2B-blue?style=flat-square)
![Status](https://img.shields.io/badge/status-active-brightgreen?style=flat-square)


# ⚡ KaliLiteX Ultimate Security Suite
# 🛡️ KaliLiteX: Ultimate Offensive Security Terminal Suite

> **Yalnızca yasal ve etik test ortamları için geliştirilmiş, kapsamlı ve modüler siber güvenlik araç seti.**
>⚠️ Sorumluluk Reddi
KaliLiteX yalnızca eğitim, araştırma ve yetkili sızma testleri için tasarlanmıştır. Bu yazılımın herhangi bir yasa dışı veya izinsiz sistemlere karşı kullanımı tamamen kullanıcı sorumluluğundadır.

> ⚠️ **Açık Kaynak & Topluluğa Açık Geliştirme**  
> KaliLiteX, topluluğun katkılarına tamamen açık bir projedir.  
> Bu yazılım aktif olarak geliştirilmektedir ve yeni modüller, düzeltmeler, temalar veya diller eklemek isteyen herkes katkıda bulunabilir.  
> Forklayabilir, pull request gönderebilir ya da fikirlerinizi Issues sekmesinden paylaşabilirsiniz.

> 🧩 Katkı Sağla: [Nasıl Katkıda Bulunabilirim?](https://github.com/ENESxAIs/KaliLiteX/issues)
[![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/ENESxAIs/KaliLiteX/issues)


Bu yazılım:

Kapsamında üçüncü parti araçlar ve framework'ler barındırır.

KaliLiteX yalnızca merkezi Python scriptini (çekirdek orchestrator) sağlar.

Dahil edilen araçların her biri kendi lisansı ve geliştiricisine sahiptir.

Hiçbir şekilde aşağıdaki işlemler için geliştirici sorumluluk kabul etmez:

Kötüye kullanım

Verilerin kaybı veya bozulması

Yetkisiz erişim, izinsiz denetim veya deneme

Kullanım öncesinde her bileşenin lisans ve yasal gerekliliklerini okuyup kabul ettiğinizi varsayarız.


> 

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-Kali%20Linux%20%7C%20WSL2%20%7C%20Ubuntu-red)](https://www.kali.org/)
- windows / linux / WSL2 / belki macos 
> 🔥 Tüm siber güvenlik araçları tek terminalde,  görsel raporlar ile!

---

### ✨ Özellikler

- 🛡️ **Port ve Zafiyet Taraması**: `nmap`, `nikto`, `sqlmap`, `sn1per`, `wapiti`, `recon-ng` ve daha fazlası
- 🌐 **OSINT (Açık Kaynak İstihbarat)**: `Photon`, `SpiderFoot`, `social_media_profiler`, `dark_sorgu`
- 📡 **Kablosuz Ağ Araçları**: `aircrack-ng`, `kismet`, `wifite`
- 📱 **Mobil Güvenlik**: `PhoneSploit`, `Evilginx2`, `SocialBox`
- 💥 **Exploit ve Brute-Force**: `AutoSploit`, `CMSeek`, `Hashcat`
- 🧠 **1337 Hacker Modu**: Matrix animasyonu, terminal görsel efektleri
- 📊 **Otomatik Raporlama**: PDF, HTML, CSV ve grafik çıktılar
- ✅ **Etik Kullanım Sözleşmesi** ile sorumluluk bilinci

---

### ⚙️ Kurulum
İlk çalıştırmada tüm bağımlılıklar otomatik kurulur. Eksik araçlar için bilgilendirme verilir.

for macos 
# Install via Homebrew
brew install nmap nikto dirb whatweb fierce dnsrecon coreutils

# Install Python tools
pip3 install theHarvester sublist3r sherlock-project

# Make executable
chmod +x security_toolkit.sh
./security_toolkit.sh

> 🔴 **UYARI**: Yalnızca yetkili sistemlerde ve yasal amaçlarla kullanınız.

#### 💻 Gereksinimler

- Python 3.8+
- windows / linux / WSL2 / belki macos 
- Aşağıdaki bağımlılıklar:

```bash
Alternatif olarak otomatik kurulum:

bash

python3 kalisuite.py
İlk çalıştırmada tüm modüller otomatik yüklenir ve eksik araçlar için kurulum komutları verilir.

🚀 Kullanım
bash

python3 kalisuite.py
Ana menüden kullanmak istediğiniz aracı seçin:

1: Port Tarama (nmap)

2: Zafiyet Tarama (nikto)

...

1337: 1337 Hacker Modu (Matrix Efekti)

q: Çıkış

📑 Örnek Ekran Görüntüsü
text

KaliLiteX Ultimate security suite

Sürüm: 4.5 | Geliştirici: ENESxAİs | 1337 Mod Aktif

╭────────────KaliLiteX Ultimate Menüsü────────────╮
│ Seçenek │ Araç                                 │
│    1    │ Port Tarama (Nmap)                   │
│    2    │ Zafiyet Tarama (Nikto)               │
│   ...   │ ...                                   │
│  1337   │ Hacker Modu (Easter Egg)             │
│    q    │ Çıkış                                │
╰────────────────────────────────────────────────╯
🧩 İçerdiği Araçlar
Kategori	Araçlar
Taramalar	nmap, nikto, sqlmap, CMSeek, sn1per
OSINT	photon, recon-ng, spiderfoot, socialbox
Exploit	autosploit, evilginx2, hashcat
WiFi	aircrack-ng, wifite, kismet
Mobil	phonesploit
Bonus	dark_sorgu, 1337 Hacker Modu, rapor üretimi

📄 Lisans
MIT Lisansı. Detaylar için LICENSE dosyasına bakınız.
📝 Lisans
Bu proje MIT Lisansı ile lisanslanmıştır. Ancak:

CMSeek, Nikto, Sn1per, SocialBox, Photon, SQLMap gibi bağımsız projeler kendi geliştiricilerine aittir.

KaliLiteX bu araçları yükler, başlatır ve raporlar. Bu araçların hiçbirini içeriğinde barındırmaz, sadece erişim sağlar.
 bu arada lütfen projeyi geliştirmemize yardım edin kendinizden bişeyler ekleyin ve mükemmelleştirin
🙋 Sorumluluk Reddi
Bu araç yalnızca eğitim, test ve izinli siber güvenlik çalışmaları için tasarlanmıştır. Geliştirici, yasa dışı kullanımlardan sorumlu değildir.

🧠 Geliştirici
👤 ENESxAİs
📧 İletişim için GitHub Issues kullanabilirsiniz. yada instagram eness._200w
