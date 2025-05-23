#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

check_tool() {
    command -v "$1" >/dev/null 2>&1
}

check_deps() {
    echo -e "${BLUE}Checking required tools...${NC}"
    local tools=("nmap" "whois" "nikto" "dirb" "sublist3r" "sherlock" "dnsrecon" "fierce" "whatweb" "curl" "dig" "host" "timeout" "sqlmap" "wifite" "aircrack-ng" "hashcat" "recon-ng" "wapiti" "kismet")
    local missing=()
    
    for tool in "${tools[@]}"; do
        if check_tool "$tool"; then
            echo -e "${GREEN}✓${NC} $tool"
        else
            echo -e "${RED}✗${NC} $tool"
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "\n${YELLOW}Install missing tools:${NC}"
        echo "sudo apt-get update && sudo apt-get install -y nmap nikto dirb whatweb fierce dnsrecon coreutils sqlmap wifite aircrack-ng hashcat recon-ng wapiti kismet"
        echo "pip3 install theHarvester sublist3r sherlock-project photon-osint"
        echo "git clone https://github.com/Tuhinshubhra/CMSeek.git && cd CMSeek && pip3 install -r requirements.txt"
        sleep 3
    fi
}

show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Linux Security Toolkit    ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════╝${NC}"
    
    echo -e "\n${PURPLE}Network & Port Scanning:${NC}"
    echo "1)  Port Scan (Nmap)"
    echo "2)  Network Discovery"
    echo "3)  Advanced Port Scan"
    
    echo -e "\n${PURPLE}Web Application Testing:${NC}"
    echo "4)  Web Vulnerability Scan (Nikto)"
    echo "5)  Directory Bruteforce (Dirb)"
    echo "6)  Web Technology Detection"
    echo "7)  HTTP Headers Analysis"
    echo "8)  SQL Injection Test (SQLMap)"
    echo "9)  Web Vulnerability Scanner (Wapiti)"
    
    echo -e "\n${PURPLE}Reconnaissance & OSINT:${NC}"
    echo "10) Subdomain Enumeration"
    echo "11) DNS Reconnaissance"
    echo "12) Email Harvesting (theHarvester)"
    echo "13) Username Search (Sherlock)"
    echo "14) Domain Information"
    echo "15) OSINT Recon (Recon-ng)"
    echo "16) Photon OSINT Crawler"
    
    echo -e "\n${PURPLE}Wireless Security:${NC}"
    echo "17) WiFi Attack (Wifite)"
    echo "18) Aircrack-ng WiFi Analysis"
    echo "19) Kismet Wireless Analysis"
    
    echo -e "\n${PURPLE}Password & Hash Cracking:${NC}"
    echo "20) Hash Cracking (Hashcat)"
    echo "21) Password Pattern Generator"
    
    echo -e "\n${PURPLE}CMS & Social Engineering:${NC}"
    echo "22) CMS Detection & Scanning"
    echo "23) Social Media Intelligence"
    echo "24) Employee Enumeration"
    
    echo -e "\n${PURPLE}Advanced Operations:${NC}"
    echo "25) Full Target Assessment"
    echo "26) Google Dorking Patterns"
    echo "27) Custom Command Execution"
    echo "28) Generate Security Report"
    echo "29) Exit"
    
    echo -n -e "${CYAN}Select option [1-29]: ${NC}"
}

port_scan() {
    echo -n "Target IP/Domain: "
    read -r target
    echo "1) Quick Scan  2) Full TCP  3) UDP Scan  4) Stealth  5) Aggressive  6) Service Detection"
    echo -n "Scan type [1-6]: "
    read -r scan_type
    
    echo -e "${YELLOW}Scanning $target...${NC}"
    case $scan_type in
        1) nmap -T4 -F "$target" ;;
        2) nmap -T4 -p- "$target" ;;
        3) nmap -sU --top-ports 1000 "$target" ;;
        4) nmap -sS -T4 -F "$target" ;;
        5) nmap -A -T4 -F "$target" ;;
        6) nmap -sV -sC -O "$target" ;;
        *) nmap -T4 -F "$target" ;;
    esac
}

network_discovery() {
    echo -n "Network range (e.g., 192.168.1.0/24): "
    read -r network
    
    echo -e "${YELLOW}Discovering hosts in $network...${NC}"
    nmap -sn "$network" | grep -E "Nmap scan report|MAC Address"
    
    echo -e "\n${CYAN}Active hosts with open ports:${NC}"
    nmap -T4 --top-ports 100 "$network" | grep -A 2 "Nmap scan report"
}

advanced_port_scan() {
    echo -n "Target: "
    read -r target
    echo -n "Custom ports (e.g., 21,22,80,443,3389): "
    read -r ports
    
    echo -e "${YELLOW}Advanced scanning $target...${NC}"
    nmap -sS -sV -O -A --script=vuln,default -p "${ports:-21,22,80,443,3389,8080,8443}" "$target"
}

web_vuln_scan() {
    echo -n "Target URL: "
    read -r url
    
    echo -e "${YELLOW}Vulnerability scanning $url...${NC}"
    if check_tool "nikto"; then
        nikto -h "$url" -C all -Tuning x
    else
        echo -e "${RED}Nikto not installed${NC}"
    fi
}

dir_bruteforce() {
    echo -n "Target URL: "
    read -r url
    echo -n "Wordlist (leave empty for default): "
    read -r wordlist
    
    echo -e "${YELLOW}Directory bruteforcing $url...${NC}"
    if check_tool "dirb"; then
        if [ -n "$wordlist" ]; then
            dirb "$url" "$wordlist" -w -S
        else
            dirb "$url" -w -S
        fi
    else
        echo -e "${RED}Dirb not installed${NC}"
    fi
}

web_tech_detect() {
    echo -n "Target URL: "
    read -r url
    
    echo -e "${YELLOW}Detecting technologies for $url...${NC}"
    if check_tool "whatweb"; then
        whatweb "$url" -v -a 3
    else
        curl -I "$url" 2>/dev/null | grep -i "server:\|x-powered-by:\|x-generator:"
    fi
}

http_headers() {
    echo -n "Target URL: "
    read -r url
    
    echo -e "${YELLOW}Analyzing headers for $url...${NC}"
    curl -I "$url" 2>/dev/null | while IFS= read -r line; do
        case "$line" in
            *"Server:"*) echo -e "${GREEN}$line${NC}" ;;
            *"X-Powered-By:"*) echo -e "${YELLOW}$line${NC}" ;;
            *"Set-Cookie:"*) echo -e "${CYAN}$line${NC}" ;;
            *"X-Frame-Options:"*) echo -e "${PURPLE}$line${NC}" ;;
            *"Content-Security-Policy:"*) echo -e "${PURPLE}$line${NC}" ;;
            *) echo "$line" ;;
        esac
    done
}

sql_injection_test() {
    echo -n "Target URL: "
    read -r url
    echo -n "Additional parameters (optional): "
    read -r params
    
    echo -e "${YELLOW}Testing SQL injection on $url...${NC}"
    if check_tool "sqlmap"; then
        sqlmap -u "$url" --batch --level=3 --risk=2 $params
    else
        echo -e "${RED}SQLMap not installed${NC}"
    fi
}

wapiti_scan() {
    echo -n "Target URL: "
    read -r url
    
    echo -e "${YELLOW}Wapiti vulnerability scan on $url...${NC}"
    if check_tool "wapiti"; then
        wapiti -u "$url" --flush-session -f txt -o /tmp/wapiti_report
        cat /tmp/wapiti_report
    else
        echo -e "${RED}Wapiti not installed${NC}"
    fi
}

subdomain_enum() {
    echo -n "Target domain: "
    read -r domain
    
    echo -e "${YELLOW}Enumerating subdomains for $domain...${NC}"
    if check_tool "sublist3r"; then
        python3 -m sublist3r -d "$domain" -t 50 -v
    elif check_tool "fierce"; then
        fierce --domain "$domain"
    else
        echo -e "${CYAN}Manual enumeration:${NC}"
        for sub in www mail ftp admin blog shop api dev test staging app portal; do
            ip=$(dig +short "$sub.$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
            [ -n "$ip" ] && echo -e "${GREEN}$sub.$domain -> $ip${NC}"
        done
    fi
}

dns_recon() {
    echo -n "Target domain: "
    read -r domain
    
    echo -e "${YELLOW}DNS reconnaissance for $domain...${NC}"
    if check_tool "dnsrecon"; then
        dnsrecon -d "$domain" -t std,brt,srv,axfr
    else
        echo -e "${CYAN}A Records:${NC}"
        dig "$domain" A +short
        echo -e "${CYAN}MX Records:${NC}"
        dig "$domain" MX +short
        echo -e "${CYAN}NS Records:${NC}"
        dig "$domain" NS +short
        echo -e "${CYAN}TXT Records:${NC}"
        dig "$domain" TXT +short
    fi
}

email_harvest() {
    echo -n "Target domain: "
    read -r domain
    echo -n "Search engine [google/bing/yahoo/all]: "
    read -r source
    echo -n "Limit [100]: "
    read -r limit
    
    echo -e "${YELLOW}Harvesting emails for $domain...${NC}"
    if check_tool "theHarvester"; then
        theHarvester -d "$domain" -b "${source:-all}" -l "${limit:-100}"
    else
        echo -e "${RED}theHarvester not installed${NC}"
    fi
}

username_search() {
    echo -n "Username to search: "
    read -r username
    
    echo -e "${YELLOW}Searching for $username across platforms...${NC}"
    if check_tool "sherlock"; then
        python3 -m sherlock "$username" --timeout 20
    else
        echo -e "${RED}Sherlock not installed${NC}"
    fi
}

domain_info() {
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}Gathering information for $domain...${NC}"
    echo -e "\n${CYAN}WHOIS Information:${NC}"
    whois "$domain" | head -30
    
    echo -e "\n${CYAN}DNS Records:${NC}"
    dig "$domain" ANY +short
    
    echo -e "\n${CYAN}Reverse DNS:${NC}"
    host "$domain" 2>/dev/null
}

recon_ng_scan() {
    echo -n "Target domain: "
    read -r domain
    
    echo -e "${YELLOW}Running Recon-ng on $domain...${NC}"
    if check_tool "recon-ng"; then
        echo "use recon/domains-hosts/hackertarget" > /tmp/recon_commands
        echo "set SOURCE $domain" >> /tmp/recon_commands
        echo "run" >> /tmp/recon_commands
        echo "exit" >> /tmp/recon_commands
        recon-ng -r /tmp/recon_commands
    else
        echo -e "${RED}Recon-ng not installed${NC}"
    fi
}

photon_osint() {
    echo -n "Target URL: "
    read -r url
    
    echo -e "${YELLOW}Running Photon OSINT crawler on $url...${NC}"
    if check_tool "photon"; then
        python3 -m photon -u "$url" -l 2 -t 50 --stdout
    else
        echo -e "${RED}Photon not installed. Install with: pip3 install photon-osint${NC}"
    fi
}

wifi_attack() {
    echo -e "${YELLOW}Starting WiFi attack with Wifite...${NC}"
    if check_tool "wifite"; then
        sudo wifite --kill
    else
        echo -e "${RED}Wifite not installed${NC}"
    fi
}

aircrack_analysis() {
    echo -e "${YELLOW}Starting Aircrack-ng WiFi analysis...${NC}"
    if check_tool "airmon-ng"; then
        echo "Available interfaces:"
        airmon-ng
        echo -n "Interface to use: "
        read -r interface
        echo "Starting monitor mode on $interface..."
        sudo airmon-ng start "$interface"
        echo "Scanning for networks..."
        sudo airodump-ng "${interface}mon"
    else
        echo -e "${RED}Aircrack-ng suite not installed${NC}"
    fi
}

kismet_analysis() {
    echo -e "${YELLOW}Starting Kismet wireless analysis...${NC}"
    if check_tool "kismet"; then
        sudo kismet --no-gui
    else
        echo -e "${RED}Kismet not installed${NC}"
    fi
}

hash_cracking() {
    echo -n "Hash file path: "
    read -r hashfile
    echo -n "Wordlist path: "
    read -r wordlist
    echo -n "Hash type (0=MD5, 1000=NTLM, 1400=SHA256): "
    read -r hashtype
    
    echo -e "${YELLOW}Cracking hashes with Hashcat...${NC}"
    if check_tool "hashcat"; then
        hashcat -m "${hashtype:-0}" "$hashfile" "$wordlist" --show
    else
        echo -e "${RED}Hashcat not installed${NC}"
    fi
}

password_patterns() {
    echo -n "Company/Organization name: "
    read -r company
    echo -n "Year [2024]: "
    read -r year
    year=${year:-2024}
    
    echo -e "${YELLOW}Generating password patterns for $company:${NC}"
    patterns=(
        "$company$year" "$company$year!" "$company123" "$company@$year"
        "${company}Password" "${company}Pass" "$company#$year"
        "${company,,}$year" "${company^^}$year" "$company$((year-1))"
    )
    
    for pattern in "${patterns[@]}"; do
        echo -e "${GREEN}$pattern${NC}"
    done
}

cms_detection() {
    echo -n "Target URL: "
    read -r url
    
    echo -e "${YELLOW}CMS detection and scanning for $url...${NC}"
    if [ -d "CMSeek" ]; then
        python3 CMSeek/cmseek.py -u "$url"
    else
        echo -e "${RED}CMSeek not found. Clone from: https://github.com/Tuhinshubhra/CMSeek.git${NC}"
    fi
}

social_media_intel() {
    echo -n "Target username: "
    read -r username
    
    echo -e "${YELLOW}Social media intelligence for $username...${NC}"
    platforms=("twitter.com" "facebook.com" "instagram.com" "linkedin.com/in" "github.com" "reddit.com/user")
    
    for platform in "${platforms[@]}"; do
        url="https://$platform/$username"
        status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
        if [ "$status" = "200" ]; then
            echo -e "${GREEN}Found: $url${NC}"
        fi
    done
}

employee_enum() {
    echo -n "Company name: "
    read -r company
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}Employee enumeration for $company...${NC}"
    echo -e "${CYAN}LinkedIn search patterns:${NC}"
    echo "site:linkedin.com \"$company\""
    echo "site:linkedin.com \"at $company\""
    
    echo -e "${CYAN}Email patterns to try:${NC}"
    echo "firstname.lastname@$domain"
    echo "f.lastname@$domain"
    echo "firstname@$domain"
    echo "flastname@$domain"
}

full_assessment() {
    echo -n "Target (IP/Domain): "
    read -r target
    
    echo -e "${GREEN}=== Full Security Assessment: $target ===${NC}"
    
    echo -e "\n${YELLOW}[1/10] WHOIS Lookup${NC}"
    whois "$target" 2>/dev/null | head -15
    
    echo -e "\n${YELLOW}[2/10] DNS Records${NC}"
    dig "$target" ANY +short 2>/dev/null | head -10
    
    echo -e "\n${YELLOW}[3/10] Subdomain Enumeration${NC}"
    if check_tool "sublist3r"; then
        timeout 120 python3 -m sublist3r -d "$target" -t 20 2>/dev/null | tail -15
    fi
    
    echo -e "\n${YELLOW}[4/10] Port Scanning${NC}"
    nmap -T4 --top-ports 1000 "$target" 2>/dev/null | grep "open"
    
    echo -e "\n${YELLOW}[5/10] Service Detection${NC}"
    nmap -sV --top-ports 100 "$target" 2>/dev/null | grep -E "open|service"
    
    echo -e "\n${YELLOW}[6/10] Web Technology Detection${NC}"
    if check_tool "whatweb"; then
        whatweb "http://$target" 2>/dev/null | head -5
    fi
    
    echo -e "\n${YELLOW}[7/10] HTTP Headers${NC}"
    curl -I "http://$target" 2>/dev/null | head -10
    
    echo -e "\n${YELLOW}[8/10] Email Harvesting${NC}"
    if check_tool "theHarvester"; then
        timeout 60 theHarvester -d "$target" -b google -l 10 2>/dev/null | grep "@"
    fi
    
    echo -e "\n${YELLOW}[9/10] Directory Scanning${NC}"
    if check_tool "dirb"; then
        timeout 120 dirb "http://$target" -w -S 2>/dev/null | grep "CODE:200" | head -10
    fi
    
    echo -e "\n${YELLOW}[10/10] Vulnerability Check${NC}"
    if check_tool "nikto"; then
        timeout 180 nikto -h "http://$target" 2>/dev/null | grep -E "OSVDB|CVE" | head -5
    fi
}

google_dorking() {
    echo -n "Target domain: "
    read -r domain
    
    echo -e "${YELLOW}Google dorking patterns for $domain:${NC}"
    dorks=(
        "site:$domain filetype:pdf"
        "site:$domain inurl:admin"
        "site:$domain inurl:login"
        "site:$domain intitle:\"index of\""
        "site:$domain ext:sql OR ext:dbf OR ext:mdb"
        "site:$domain inurl:wp-content"
        "site:$domain inurl:config"
        "\"$domain\" filetype:xls OR filetype:csv"
        "site:$domain intext:password OR intext:passwd"
        "site:$domain inurl:backup OR inurl:bak"
        "site:$domain ext:log"
        "site:$domain intext:\"mysql_connect\""
    )
    
    for dork in "${dorks[@]}"; do
        echo -e "${GREEN}$dork${NC}"
    done
}

custom_command() {
    echo -e "${CYAN}Available security tools:${NC}"
    echo "nmap, whois, theHarvester, nikto, dirb, sublist3r, sherlock, dnsrecon, whatweb"
    echo "sqlmap, wifite, aircrack-ng, hashcat, recon-ng, wapiti, kismet"
    echo -n "Enter your custom command: "
    read -r command
    
    echo -e "${YELLOW}Executing: $command${NC}"
    eval "$command"
}

generate_report() {
    echo -n "Target for report: "
    read -r target
    report_file="/tmp/security_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${YELLOW}Generating security report for $target...${NC}"
    {
        echo "Security Assessment Report"
        echo "========================="
        echo "Target: $target"
        echo "Date: $(date)"
        echo "Generated by: Linux Security Toolkit"
        echo ""
        echo "WHOIS Information:"
        whois "$target" 2>/dev/null | head -20
        echo ""
        echo "DNS Records:"
        dig "$target" ANY +short 2>/dev/null
        echo ""
        echo "Open Ports:"
        nmap -T4 --top-ports 1000 "$target" 2>/dev/null | grep "open"
        echo ""
        echo "Web Technologies:"
        whatweb "http://$target" 2>/dev/null
    } > "$report_file"
    
    echo -e "${GREEN}Report saved to: $report_file${NC}"
}

main() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}Note: Some tools require root privileges. Run with sudo for full functionality.${NC}"
        sleep 2
    fi
    
    check_deps
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) port_scan ;;
            2) network_discovery ;;
            3) advanced_port_scan ;;
            4) web_vuln_scan ;;
            5) dir_bruteforce ;;
            6) web_tech_detect ;;
            7) http_headers ;;
            8) sql_injection_test ;;
            9) wapiti_scan ;;
            10) subdomain_enum ;;
            11) dns_recon ;;
            12) email_harvest ;;
            13) username_search ;;
            14) domain_info ;;
            15) recon_ng_scan ;;
            16) photon_osint ;;
            17) wifi_attack ;;
            18) aircrack_analysis ;;
            19) kismet_analysis ;;
            20) hash_cracking ;;
            21) password_patterns ;;
            22) cms_detection ;;
            23) social_media_intel ;;
            24) employee_enum ;;
            25) full_assessment ;;
            26) google_dorking ;;
            27) custom_command ;;
            28) generate_report ;;
            29) echo -e "${GREEN}Exiting Linux Security Toolkit${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
        
        echo -e "\n${BLUE}Press Enter to continue...${NC}"
        read -r
    done
}

main "$@"