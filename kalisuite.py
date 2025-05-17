
import os
import subprocess
import threading
import time
import random
import json
import re
import asyncio
import logging
import argparse
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime
from typing import List, Dict, Optional
import sys
import requests
import nmap
import shodan
from rich.console import Console
from rich.table import Table
from rich.progress import Progress
import pyfiglet
import matplotlib.pyplot as plt
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
import pandas as pd
import platform

# Konsol ve log ayarları
console = Console()
logging.basicConfig(filename='kali_suite.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Etik kullanım
ETHICAL_USAGE_AGREED = False

# Bağımlılıklar
DEPENDENCIES = [
    "requests", "python-nmap", "shodan", "rich", "pyfiglet", "matplotlib", "reportlab", "pandas", "photon"
]

# Harici araçlar
TOOLS = [
    "nmap", "nikto", "hashcat", "wifite", "metasploit-framework", "sqlmap", "aircrack-ng",
    "recon-ng", "spiderfoot", "wapiti", "kismet", "cmseek", "socialbox", "phonesploit",
    "xsshunter", "autosploit", "evilginx2", "sniper"
]

def check_ethical_usage():
    """Etik kullanım sözleşmesini kontrol et."""
    global ETHICAL_USAGE_AGREED
    if not ETHICAL_USAGE_AGREED:
        console.print("[bold red]UYARI: Bu araç yalnızca yasal ve yetkili sistemlerde kullanılmalıdır! Yanlış kullanım yasal sonuçlar doğurabilir![/bold red]")
        agree = input("Etik kullanım sözleşmesini kabul ediyor musunuz? (evet/hayır): ").lower()
        if agree == "evet":
            ETHICAL_USAGE_AGREED = True
            logging.info("Kullanıcı etik kullanım sözleşmesini kabul etti.")
        else:
            console.print("[bold red]Etik kullanım sözleşmesi kabul edilmedi. Program sonlandırılıyor.[/bold red]")
            exit(1)

def install_cmseek():
    """CMSeek'i GitHub'dan klonla ve bağımlılıklarını kur."""
    cmseek_path = os.path.join(os.getcwd(), "CMSeek")
    if not os.path.exists(cmseek_path):
        console.print("[bold yellow]CMSeek bulunamadı, GitHub'dan klonlanıyor...[/bold yellow]")
        try:
            subprocess.check_call(["git", "clone", "https://github.com/Tuhinshubhra/CMSeek.git"])
            console.print("[bold green]CMSeek başarıyla klonlandı.[/bold green]")
        except subprocess.CalledProcessError as e:
            console.print(f"[bold red]CMSeek klonlama başarısız: {e}[/bold red]")
            return False
    # CMSeek bağımlılıklarını kur
    requirements_path = os.path.join(cmseek_path, "requirements.txt")
    if os.path.exists(requirements_path):
        console.print("[bold yellow]CMSeek bağımlılıkları kuruluyor...[/bold yellow]")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", requirements_path])
            console.print("[bold green]CMSeek bağımlılıkları başarıyla kuruldu.[/bold green]")
        except subprocess.CalledProcessError as e:
            console.print(f"[bold red]CMSeek bağımlılıkları kurulumu başarısız: {e}[/bold red]")
            return False
    return True

def install_dependencies():
    """Bağımlılıkları kontrol et ve sanal ortamda kur."""
    console.print("[bold yellow]Bağımlılıklar kontrol ediliyor...[/bold yellow]")
    for dep in DEPENDENCIES:
        try:
            __import__(dep)
            console.print(f"[bold green]{dep} zaten yüklü.[/bold green]")
        except ImportError:
            console.print(f"[bold red]{dep} bulunamadı, sanal ortama kuruluyor...[/bold red]")
            try:
                subprocess.check_call([sys.executable, "-m", "pip", "install", dep])
                console.print(f"[bold green]{dep} başarıyla kuruldu.[/bold green]")
            except subprocess.CalledProcessError as e:
                console.print(f"[bold red]{dep} kurulumu başarısız: {e}[/bold red]")
                console.print(f"[yellow]Lütfen sanal ortamda olduğunuzdan emin olun: source venv/bin/activate[/yellow]")
                exit(1)
    # CMSeek'i ayrı kur
    if not install_cmseek():
        console.print("[bold red]CMSeek kurulumu başarısız. Lütfen manuel kurun: https://github.com/Tuhinshubhra/CMSeek[/bold red]")
    check_tools()

def check_tools():
    """Harici araçların kurulu olduğunu kontrol et."""
    console.print("[bold yellow]Harici araçlar kontrol ediliyor...[/bold yellow]")
    system = platform.system().lower()
    install_commands = {
        "nmap": "sudo apt-get install nmap",
        "nikto": "sudo apt-get install nikto",
        "hashcat": "sudo apt-get install hashcat",
        "wifite": "sudo apt-get install wifite",
        "metasploit-framework": "sudo apt-get install metasploit-framework",
        "sqlmap": "sudo apt-get install sqlmap",
        "aircrack-ng": "sudo apt-get install aircrack-ng",
        "recon-ng": "sudo apt-get install recon-ng",
        "spiderfoot": "sudo apt-get install spiderfoot",
        "wapiti": "sudo apt-get install wapiti",
        "kismet": "sudo apt-get install kismet",
        "cmseek": "git clone https://github.com/Tuhinshubhra/CMSeek.git && cd CMSeek && pip install -r requirements.txt",
        "socialbox": "git clone https://github.com/thelinuxchoice/socialbox-termux.git && cd socialbox-termux && chmod +x install.sh && ./install.sh",
        "phonesploit": "git clone https://github.com/metachar/PhoneSploit",
        "xsshunter": "git clone https://github.com/mandatoryprogrammer/XSSHunter",
        "autosploit": "git clone https://github.com/NullArray/AutoSploit",
        "evilginx2": "git clone https://github.com/kgretzky/evilginx2",
        "sniper": "git clone https://github.com/1N3/Sn1per"
    }
    for tool in TOOLS:
        try:
            if system == "windows":
                result = subprocess.run(["where", tool], capture_output=True, text=True, check=True)
                if not result.stdout.strip():
                    console.print(f"[bold red]{tool} bulunamadı. Lütfen kurun.[/bold red]")
                    console.print(f"[yellow]Not: {tool} Linux tabanlı bir araçtır. WSL2 veya Kali Linux sanal makinesi kullanın.[/yellow]")
                    console.print(f"[yellow]WSL2 Kurulumu: PowerShell'de 'wsl --install' komutunu çalıştırın.[/yellow]")
                    console.print(f"[yellow]Kali Linux: https://www.kali.org/get-kali/[/yellow]")
                else:
                    console.print(f"[bold green]{tool} kurulu: {result.stdout.strip()}[/bold green]")
            else:
                result = subprocess.run(["which", tool], capture_output=True, text=True, check=True)
                if not result.stdout.strip():
                    console.print(f"[bold red]{tool} bulunamadı. Lütfen kurun.[/bold red]")
                    console.print(f"[yellow]Kurulum komutu: {install_commands.get(tool, 'Manuel kurulum gerekli')}[/yellow]")
                else:
                    console.print(f"[bold green]{tool} kurulu: {result.stdout.strip()}[/bold green]")
        except subprocess.CalledProcessError:
            console.print(f"[bold red]{tool} bulunamadı. Lütfen kurun.[/bold red]")
            console.print(f"[yellow]Kurulum komutu: {install_commands.get(tool, 'Manuel kurulum gerekli')}[/yellow]")
            if system == "windows":
                console.print(f"[yellow]Not: {tool} Linux tabanlı bir araçtır. WSL2 veya Kali Linux sanal makinesi kullanın.[/yellow]")
                console.print(f"[yellow]WSL2 Kurulumu: PowerShell'de 'wsl --install' komutunu çalıştırın.[/yellow]")
                console.print(f"[yellow]Kali Linux: https://www.kali.org/get-kali/[/yellow]")

def display_banner():
    """Cyberpunk temalı banner göster."""
    banner = pyfiglet.figlet_format("KaliLiteX Ultimate security suite")
    console.print(f"[bold green]{banner}[/bold green]")
    console.print("[bold cyan]Sürüm: 4.5 | Geliştirici: ENESxAİs | 1337 Mod Aktif[/bold cyan]\n")

def generate_report(data: Dict, output_format: str = "pdf"):
    """Rapor oluştur (PDF, HTML, CSV)."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    if output_format == "pdf":
        filename = f"report_{timestamp}.pdf"
        c = canvas.Canvas(filename, pagesize=letter)
        c.drawString(100, 750, "KaliLiteX Ultimate Raporu")
        y = 700
        for key, value in data.items():
            c.drawString(100, y, f"{key}: {str(value)[:100]}")  # Uzun çıktıları kısalt
            y -= 20
        c.save()
        console.print(f"[bold green]PDF raporu oluşturuldu: {filename}[/bold green]")
    elif output_format == "html":
        filename = f"report_{timestamp}.html"
        with open(filename, "w") as f:
            f.write("<html><body><h1>KaliLiteX Ultimate Raporu</h1>")
            for key, value in data.items():
                f.write(f"<p><b>{key}</b>: {str(value)[:100]}</p>")
            f.write("</body></html>")
        console.print(f"[bold green]HTML raporu oluşturuldu: {filename}[/bold green]")
    elif output_format == "csv":
        filename = f"report_{timestamp}.csv"
        df = pd.DataFrame(list(data.items()), columns=["Anahtar", "Değer"])
        df.to_csv(filename, index=False)
        console.print(f"[bold green]CSV raporu oluşturuldu: {filename}[/bold green]")

def plot_results(data: Dict, title: str):
    """Sonuçları görselleştir."""
    keys = list(data.keys())
    values = [len(str(v)) for v in data.values()]
    plt.figure(figsize=(10, 6))
    plt.bar(keys, values)
    plt.title(title)
    plt.xlabel("Kategori")
    plt.ylabel("Veri Miktarı")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f"{title.lower().replace(' ', '_')}.png")
    console.print(f"[bold green]Grafik oluşturuldu: {title.lower().replace(' ', '_')}.png[/bold green]")

async def port_scan(target: str, ports: str = "1-1000") -> Dict:
    """Nmap ile port tarama."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    nm = nmap.PortScanner()
    console.print(f"[bold yellow]{target} üzerinde port tarama başlatılıyor...[/bold yellow]")
    try:
        nm.scan(target, ports)
        results = {}
        for host in nm.all_hosts():
            results[host] = nm[host].all_protocols()
        generate_report(results, "pdf")
        plot_results(results, "Port Tarama Sonuçları")
        return results
    except Exception as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        return {}

async def vuln_scan(target: str) -> Dict:
    """Nikto ile zafiyet tarama."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde zafiyet tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["nikto", "-h", target], text=True)
        results = {"Nikto Çıktısı": result}
        generate_report(results, "html")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Nikto'nun kurulu olduğundan emin olun: sudo apt-get install nikto[/yellow]")
        return {}

async def sms_bomber(phone: str, count: int = 10):
    """SMS bomber simülasyonu."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{phone} numarasına {count} SMS gönderiliyor (simülasyon)...[/bold yellow]")
    with Progress() as progress:
        task = progress.add_task("[cyan]SMS Gönderiliyor...", total=count)
        for _ in range(count):
            await asyncio.sleep(0.1)
            progress.update(task, advance=1)
    console.print("[bold green]SMS bomber simülasyonu tamamlandı.[/bold green]")
    generate_report({"Telefon": phone, "SMS Sayısı": count}, "csv")

async def call_bomber(phone: str, count: int = 5):
    """Call bomber simülasyonu."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{phone} numarasına {count} çağrı yapılıyor (simülasyon)...[/bold yellow]")
    with Progress() as progress:
        task = progress.add_task("[cyan]Çağrı Yapılıyor...", total=count)
        for _ in range(count):
            await asyncio.sleep(0.1)
            progress.update(task, advance=1)
    console.print("[bold green]Call bomber simülasyonu tamamlandı.[/bold green]")
    generate_report({"Telefon": phone, "Çağrı Sayısı": count}, "csv")

async def ddos_simulation(target: str, duration: int = 10):
    """DDoS simülasyonu."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde DDoS simülasyonu başlatılıyor ({duration} saniye)...[/bold yellow]")
    with Progress() as progress:
        task = progress.add_task("[cyan]DDoS Simülasyonu...", total=duration)
        for _ in range(duration):
            await asyncio.sleep(1)
            progress.update(task, advance=1)
    console.print(f"[bold green]DDoS simülasyonu tamamlandı.[/bold green]")
    generate_report({"Hedef": target, "Süre": f"{duration} saniye"}, "pdf")

async def dark_sorgu_query(query: str) -> Dict:
    """Dark sorgu simülasyonu."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]Dark sorgu: {query} için arama yapılıyor...[/bold yellow]")
    results = {"Sorgu": query, "Sonuç": f"Simüle edilmiş veri: {query} için örnek sonuçlar"}
    generate_report(results, "html")
    return results

async def social_media_profiler(username: str) -> Dict:
    """Sosyal medya profili analizi."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{username} için sosyal medya analizi yapılıyor...[/bold yellow]")
    results = {"Kullanıcı": username, "Sonuç": f"Simüle edilmiş profil verileri: {username}"}
    generate_report(results, "csv")
    return results

async def photon_osint(target: str) -> Dict:
    """Photon ile OSINT tarama."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde Photon OSINT tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["python3", "-m", "photon", "-u", target, "--stdout"], text=True)
        results = {"Photon Çıktısı": result}
        generate_report(results, "html")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Photon'un kurulu olduğundan emin olun: pip install photon[/yellow]")
        return {}

async def sn1per_scan(target: str) -> Dict:
    """Sn1per ile otomatik penetrasyon testi."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde Sn1per tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["sniper", "-t", target], text=True)
        results = {"Sn1per Çıktısı": result}
        generate_report(results, "pdf")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Sn1per'ın kurulu olduğundan emin olun: https://github.com/1N3/Sn1per[/yellow]")
        return {}

async def cmseek_scan(target: str) -> Dict:
    """CMSeek ile CMS zafiyet tarama."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde CMSeek tarama başlatılıyor...[/bold yellow]")
    cmseek_path = os.path.join(os.getcwd(), "CMSeek", "cmseek.py")
    if not os.path.exists(cmseek_path):
        console.print(f"[bold red]Hata: CMSeek kurulu değil.[/bold red]")
        console.print(f"[yellow]Lütfen CMSeek'i kurun: git clone https://github.com/Tuhinshubhra/CMSeek.git && cd CMSeek && pip install -r requirements.txt[/yellow]")
        return {}
    try:
        result = subprocess.check_output([sys.executable, cmseek_path, "-u", target], text=True)
        results = {"CMSeek Çıktısı": result}
        generate_report(results, "html")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]CMSeek'in kurulu olduğundan emin olun: https://github.com/Tuhinshubhra/CMSeek[/yellow]")
        return {}

async def socialbox_bruteforce(platform: str, username: str):
    """SocialBox ile sosyal medya brute-force."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{platform} üzerinde {username} için brute-force başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["socialbox"], text=True)
        results = {"SocialBox Çıktısı": result}
        generate_report(results, "csv")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]SocialBox'ın kurulu olduğundan emin olun: https://github.com/thelinuxchoice/socialbox-termux[/yellow]")
        return {}

async def wifite_scan():
    """Wifite ile Wi-Fi tarama ve saldırı."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    if platform.system().lower() == "windows":
        console.print(f"[bold red]Hata: Wifite Windows'ta desteklenmez. Lütfen WSL2 veya Kali Linux kullanın.[/bold red]")
        console.print(f"[yellow]WSL2 Kurulumu: PowerShell'de 'wsl --install' komutunu çalıştırın.[/yellow]")
        console.print(f"[yellow]Kali Linux: https://www.kali.org/get-kali/[/yellow]")
        return {}
    console.print(f"[bold yellow]Wifite ile Wi-Fi tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["wifite", "--scan"], text=True)
        results = {"Wifite Çıktısı": result}
        generate_report(results, "pdf")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Wifite'ın kurulu olduğundan emin olun: sudo apt-get install wifite[/yellow]")
        return {}

async def phonesploit_exploit(target: str):
    """PhoneSploit ile mobil cihaz istismarı."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde PhoneSploit başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["phonesploit"], text=True)
        results = {"PhoneSploit Çıktısı": result}
        generate_report(results, "html")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]PhoneSploit'in kurulu olduğundan emin olun: https://github.com/metachar/PhoneSploit[/yellow]")
        return {}

async def xss_hunter(target: str) -> Dict:
    """XSS Hunter ile XSS zafiyet tarama."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde XSS Hunter tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["xsshunter", target], text=True)
        results = {"XSS Hunter Çıktısı": result}
        generate_report(results, "csv")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]XSS Hunter'ın kurulu olduğundan emin olun: https://github.com/mandatoryprogrammer/XSSHunter[/yellow]")
        return {}

async def autosploit_scan(target: str) -> Dict:
    """AutoSploit ile otomatik istismar."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde AutoSploit tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["autosploit", "-t", target], text=True)
        results = {"AutoSploit Çıktısı": result}
        generate_report(results, "pdf")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]AutoSploit'in kurulu olduğundan emin olun: https://github.com/NullArray/AutoSploit[/yellow]")
        return {}

async def hashcat_crack(hash_file: str, wordlist: str):
    """Hashcat ile parola kırma."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{hash_file} üzerinde Hashcat parola kırma başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["hashcat", "-m", "0", hash_file, wordlist], text=True)
        results = {"Hashcat Çıktısı": result}
        generate_report(results, "csv")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Hashcat'in kurulu olduğundan emin olun: sudo apt-get install hashcat[/yellow]")
        return {}

async def evilginx_phish(target: str):
    """Evilginx2 ile phishing simülasyonu."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde Evilginx2 phishing başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["evilginx2"], text=True)
        results = {"Evilginx2 Çıktısı": result}
        generate_report(results, "html")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Evilginx2'nin kurulu olduğundan emin olun: https://github.com/kgretzky/evilginx2[/yellow]")
        return {}

async def recon_ng_scan(target: str) -> Dict:
    """Recon-ng ile OSINT tarama."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde Recon-ng tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["recon-ng", "-r", target], text=True)
        results = {"Recon-ng Çıktısı": result}
        generate_report(results, "pdf")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Recon-ng'nin kurulu olduğundan emin olun: sudo apt-get install recon-ng[/yellow]")
        return {}

async def sqlmap_scan(target: str) -> Dict:
    """SQLMap ile SQL injection testi."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde SQLMap tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["sqlmap", "-u", target, "--batch"], text=True)
        results = {"SQLMap Çıktısı": result}
        generate_report(results, "html")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]SQLMap'in kurulu olduğundan emin olun: sudo apt-get install sqlmap[/yellow]")
        return {}

async def aircrack_ng_scan():
    """Aircrack-ng ile Wi-Fi analizi."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    if platform.system().lower() == "windows":
        console.print(f"[bold red]Hata: Aircrack-ng Windows'ta desteklenmez. Lütfen WSL2 veya Kali Linux kullanın.[/bold red]")
        console.print(f"[yellow]WSL2 Kurulumu: PowerShell'de 'wsl --install' komutunu çalıştırın.[/yellow]")
        console.print(f"[yellow]Kali Linux: https://www.kali.org/get-kali/[/yellow]")
        return {}
    console.print(f"[bold yellow]Aircrack-ng ile Wi-Fi analizi başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["aircrack-ng"], text=True)
        results = {"Aircrack-ng Çıktısı": result}
        generate_report(results, "csv")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Aircrack-ng'nin kurulu olduğundan emin olun: sudo apt-get install aircrack-ng[/yellow]")
        return {}

async def spiderfoot_scan(target: str) -> Dict:
    """SpiderFoot ile OSINT ve tehdit istihbaratı."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde SpiderFoot tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["spiderfoot", "-s", target, "-m", "all"], text=True)
        results = {"SpiderFoot Çıktısı": result}
        generate_report(results, "pdf")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]SpiderFoot'un kurulu olduğundan emin olun: sudo apt-get install spiderfoot[/yellow]")
        return {}

async def wapiti_scan(target: str) -> Dict:
    """Wapiti ile web zafiyet tarama."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    console.print(f"[bold yellow]{target} üzerinde Wapiti tarama başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["wapiti", "-u", target], text=True)
        results = {"Wapiti Çıktısı": result}
        generate_report(results, "html")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Wapiti'nin kurulu olduğundan emin olun: sudo apt-get install wapiti[/yellow]")
        return {}

async def kismet_scan():
    """Kismet ile kablosuz ağ analizi."""
    console.print("[bold red]Etik Kullanım Uyarısı: Sadece yasal ve yetkili hedeflerle çalışın![/bold red]")
    if platform.system().lower() == "windows":
        console.print(f"[bold red]Hata: Kismet Windows'ta desteklenmez. Lütfen WSL2 veya Kali Linux kullanın.[/bold red]")
        console.print(f"[yellow]WSL2 Kurulumu: PowerShell'de 'wsl --install' komutunu çalıştırın.[/yellow]")
        console.print(f"[yellow]Kali Linux: https://www.kali.org/get-kali/[/yellow]")
        return {}
    console.print(f"[bold yellow]Kismet ile kablosuz ağ analizi başlatılıyor...[/bold yellow]")
    try:
        result = subprocess.check_output(["kismet", "--no-gui"], text=True)
        results = {"Kismet Çıktısı": result}
        generate_report(results, "csv")
        return results
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]Hata: {e}[/bold red]")
        console.print(f"[yellow]Kismet'in kurulu olduğundan emin olun: sudo apt-get install kismet[/yellow]")
        return {}

def easter_egg_1337():
    """1337 easter egg: Matrix efekti."""
    console.print("[bold green]1337 MOD AKTİF! MATRIX ETKİSİ BAŞLIYOR...[/bold green]")
    matrix_chars = "01"
    for _ in range(10):
        print("".join(random.choice(matrix_chars) for _ in range(50)))
        time.sleep(0.1)
    console.print("[bold cyan]Hacker modu tam gaz! 🚀[/bold cyan]")

async def main_menu():
    """Ana menü."""
    check_ethical_usage()
    install_dependencies()
    while True:
        display_banner()
        table = Table(title="KaliLiteX Ultimate Menüsü")
        table.add_column("Seçenek", style="cyan")
        table.add_column("Araç", style="green")
        table.add_row("1", "Port Tarama (Nmap)")
        table.add_row("2", "Zafiyet Tarama (Nikto)")
        table.add_row("3", "SMS Bomber (Simülasyon)")
        table.add_row("4", "Call Bomber (Simülasyon)")
        table.add_row("5", "DDoS Simülasyonu")
        table.add_row("6", "Dark Sorgu Paneli")
        table.add_row("7", "Sosyal Medya Profiler")
        table.add_row("8", "Photon OSINT Tarama")
        table.add_row("9", "Sn1per Otomatik Penetrasyon Testi")
        table.add_row("10", "CMSeek CMS Zafiyet Tarama")
        table.add_row("11", "SocialBox Sosyal Medya Brute-Force")
        table.add_row("12", "Wifite Wi-Fi Saldırı")
        table.add_row("13", "PhoneSploit Mobil İstismar")
        table.add_row("14", "XSS Hunter XSS Tarama")
        table.add_row("15", "AutoSploit Otomatik İstismar")
        table.add_row("16", "Hashcat Parola Kırma")
        table.add_row("17", "Evilginx2 Phishing Simülasyonu")
        table.add_row("18", "Recon-ng OSINT Tarama")
        table.add_row("19", "SQLMap SQL Injection Testi")
        table.add_row("20", "Aircrack-ng Wi-Fi Analizi")
        table.add_row("21", "SpiderFoot OSINT ve Tehdit İstihbaratı")
        table.add_row("22", "Wapiti Web Zafiyet Tarama")
        table.add_row("23", "Kismet Kablosuz Ağ Analizi")
        table.add_row("1337", "Hacker Modu (Easter Egg)")
        table.add_row("q", "Çıkış")
        console.print(table)

        choice = input("Seçiminizi yapın: ").strip()

        if choice == "1":
            target = input("Hedef IP/Alan Adı: ")
            ports = input("Taranacak portlar (örn: 1-1000): ") or "1-1000"
            await port_scan(target, ports)
        elif choice == "2":
            target = input("Hedef URL: ")
            await vuln_scan(target)
        elif choice == "3":
            phone = input("Hedef telefon numarası: ")
            count = int(input("SMS sayısı: ") or 10)
            await sms_bomber(phone, count)
        elif choice == "4":
            phone = input("Hedef telefon numarası: ")
            count = int(input("Çağrı sayısı: ") or 5)
            await call_bomber(phone, count)
        elif choice == "5":
            target = input("Hedef IP/Alan Adı: ")
            duration = int(input("Simülasyon süresi (saniye): ") or 10)
            await ddos_simulation(target, duration)
        elif choice == "6":
            query = input("Sorgu: ")
            await dark_sorgu_query(query)
        elif choice == "7":
            username = input("Hedef kullanıcı adı: ")
            await social_media_profiler(username)
        elif choice == "8":
            target = input("Hedef URL: ")
            await photon_osint(target)
        elif choice == "9":
            target = input("Hedef IP/Alan Adı: ")
            await sn1per_scan(target)
        elif choice == "10":
            target = input("Hedef URL: ")
            await cmseek_scan(target)
        elif choice == "11":
            platform = input("Platform (facebook/instagram/twitter): ")
            username = input("Hedef kullanıcı adı: ")
            await socialbox_bruteforce(platform, username)
        elif choice == "12":
            await wifite_scan()
        elif choice == "13":
            target = input("Hedef cihaz IP: ")
            await phonesploit_exploit(target)
        elif choice == "14":
            target = input("Hedef URL: ")
            await xss_hunter(target)
        elif choice == "15":
            target = input("Hedef IP/Alan Adı: ")
            await autosploit_scan(target)
        elif choice == "16":
            hash_file = input("Hash dosyası yolu: ")
            wordlist = input("Kelime listesi yolu: ")
            await hashcat_crack(hash_file, wordlist)
        elif choice == "17":
            target = input("Hedef URL: ")
            await evilginx_phish(target)
        elif choice == "18":
            target = input("Hedef IP/Alan Adı: ")
            await recon_ng_scan(target)
        elif choice == "19":
            target = input("Hedef URL: ")
            await sqlmap_scan(target)
        elif choice == "20":
            await aircrack_ng_scan()
        elif choice == "21":
            target = input("Hedef IP/Alan Adı: ")
            await spiderfoot_scan(target)
        elif choice == "22":
            target = input("Hedef URL: ")
            await wapiti_scan(target)
        elif choice == "23":
            await kismet_scan()
        elif choice == "1337":
            easter_egg_1337()
        elif choice.lower() == "q":
            console.print("[bold red]Program sonlandırılıyor...[/bold red]")
            break
        else:
            console.print("[bold red]Geçersiz seçim, tekrar deneyin.[/bold red]")

if __name__ == "__main__":
    asyncio.run(main_menu())
