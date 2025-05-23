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
    echo -e "${BLUE}Checking tools...${NC}"
    local tools=("nmap" "whois" "theHarvester" "nikto" "dirb" "sublist3r" "sherlock" "dnsrecon" "fierce" "whatweb" "curl" "dig" "host" "timeout")
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
        echo -e "\n${YELLOW}Install missing:${NC}"
        echo "brew install nmap nikto dirb whatweb fierce dnsrecon coreutils"
        echo "pip3 install theHarvester sublist3r sherlock-project"
        sleep 3
    fi
}

show_menu() {
    clear
    echo -e "${BLUE}=== Security Toolkit ===${NC}"
    echo -e "${PURPLE}Network:${NC}"
    echo "1)  Port Scan"
    echo "2)  Subdomain Enum"
    echo "3)  DNS Recon"
    echo "4)  Network Discovery"
    
    echo -e "\n${PURPLE}Web Testing:${NC}"
    echo "5)  Web Vuln Scan"
    echo "6)  Directory Brute"
    echo "7)  Web Tech Detection"
    echo "8)  HTTP Headers"
    
    echo -e "\n${PURPLE}OSINT:${NC}"
    echo "9)  Email Harvest"
    echo "10) Username Search"
    echo "11) Domain Info"
    echo "12) Google Dorks"
    
    echo -e "\n${PURPLE}Advanced:${NC}"
    echo "13) Full Assessment"
    echo "14) Social Engineering"
    echo "15) Custom Command"
    echo "16) Exit"
    echo -n "Select [1-16]: "
}

port_scan() {
    echo -n "Target: "
    read -r target
    echo "1) Quick  2) Full TCP  3) UDP  4) Stealth  5) Aggressive"
    echo -n "Type [1-5]: "
    read -r scan_type
    
    echo -e "${YELLOW}Scanning $target...${NC}"
    case $scan_type in
        1) nmap -T4 -F "$target" ;;
        2) nmap -T4 -p- "$target" ;;
        3) nmap -sU --top-ports 100 "$target" ;;
        4) nmap -sS -T4 -F "$target" ;;
        5) nmap -A -T4 -F "$target" ;;
        *) nmap -T4 -F "$target" ;;
    esac
}

subdomain_enum() {
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}Finding subdomains for $domain...${NC}"
    if check_tool "sublist3r"; then
        python3 -m sublist3r -d "$domain" -t 20
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
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}DNS recon for $domain...${NC}"
    if check_tool "dnsrecon"; then
        dnsrecon -d "$domain" -t std
    else
        echo -e "${CYAN}A Records:${NC}"
        dig "$domain" A +short
        echo -e "${CYAN}MX Records:${NC}"
        dig "$domain" MX +short
        echo -e "${CYAN}NS Records:${NC}"
        dig "$domain" NS +short
        echo -e "${CYAN}TXT Records:${NC}"
        dig "$domain" TXT +short
        echo -e "${CYAN}CNAME Records:${NC}"
        dig "$domain" CNAME +short
    fi
}

network_discovery() {
    echo -n "Network (e.g., 192.168.1.0/24): "
    read -r network
    
    echo -e "${YELLOW}Discovering $network...${NC}"
    nmap -sn "$network" | grep -E "Nmap scan report|MAC Address"
}

web_vuln_scan() {
    echo -n "URL: "
    read -r url
    
    echo -e "${YELLOW}Scanning $url...${NC}"
    if check_tool "nikto"; then
        nikto -h "$url" -C all
    else
        echo -e "${RED}nikto not found${NC}"
        curl -I "$url" 2>/dev/null
    fi
}

dir_bruteforce() {
    echo -n "URL: "
    read -r url
    
    echo -e "${YELLOW}Directory brute on $url...${NC}"
    if check_tool "dirb"; then
        dirb "$url" -w -S
    else
        dirs=("admin" "login" "portal" "api" "wp-admin" "phpmyadmin" "dashboard" "panel" "manager" "config")
        for dir in "${dirs[@]}"; do
            code=$(curl -s -o /dev/null -w "%{http_code}" "$url/$dir" 2>/dev/null || echo "000")
            [ "$code" != "404" ] && [ "$code" != "000" ] && echo -e "${GREEN}$url/$dir -> $code${NC}"
        done
    fi
}

web_tech_detect() {
    echo -n "URL: "
    read -r url
    
    echo -e "${YELLOW}Detecting tech for $url...${NC}"
    if check_tool "whatweb"; then
        whatweb "$url" -v
    else
        headers=$(curl -I "$url" 2>/dev/null)
        echo "$headers" | grep -i "server:\|x-powered-by:\|x-generator:"
    fi
}

http_header_analysis() {
    echo -n "URL: "
    read -r url
    
    echo -e "${YELLOW}Analyzing headers for $url...${NC}"
    headers=$(curl -I "$url" 2>/dev/null)
    echo "$headers" | while IFS= read -r line; do
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

email_harvest() {
    echo -n "Domain: "
    read -r domain
    echo -n "Source [google/bing/yahoo/all]: "
    read -r source
    echo -n "Limit [100]: "
    read -r limit
    
    echo -e "${YELLOW}Harvesting emails for $domain...${NC}"
    if check_tool "theHarvester"; then
        theHarvester -d "$domain" -b "${source:-google}" -l "${limit:-100}"
    else
        echo -e "${RED}theHarvester not found${NC}"
    fi
}

username_search() {
    echo -n "Username: "
    read -r username
    
    echo -e "${YELLOW}Searching $username...${NC}"
    if check_tool "sherlock"; then
        python3 -m sherlock "$username" --timeout 10
    else
        echo -e "${CYAN}Manual check:${NC}"
        echo "Twitter: https://twitter.com/$username"
        echo "GitHub: https://github.com/$username"
        echo "Instagram: https://instagram.com/$username"
        echo "LinkedIn: https://linkedin.com/in/$username"
        echo "Reddit: https://reddit.com/user/$username"
    fi
}

domain_info() {
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}Info for $domain...${NC}"
    echo -e "\n${CYAN}WHOIS:${NC}"
    whois "$domain" | head -25
    
    echo -e "\n${CYAN}DNS:${NC}"
    dig "$domain" ANY +short | head -10
    
    echo -e "\n${CYAN}Reverse DNS:${NC}"
    host "$domain" 2>/dev/null | head -5
}

google_dorking() {
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}Google dorks for $domain:${NC}"
    dorks=(
        "site:$domain filetype:pdf"
        "site:$domain inurl:admin"
        "site:$domain inurl:login"
        "site:$domain intitle:\"index of\""
        "site:$domain ext:sql OR ext:dbf OR ext:mdb"
        "site:$domain inurl:wp-content"
        "site:$domain inurl:config"
        "\"$domain\" filetype:xls OR filetype:csv"
        "site:$domain intext:password"
        "site:$domain inurl:backup"
    )
    
    for dork in "${dorks[@]}"; do
        echo -e "${GREEN}$dork${NC}"
    done
}

full_assessment() {
    echo -n "Target: "
    read -r target
    
    echo -e "${GREEN}=== Full Assessment: $target ===${NC}"
    
    echo -e "\n${YELLOW}[1/8] WHOIS${NC}"
    whois "$target" 2>/dev/null | head -10
    
    echo -e "\n${YELLOW}[2/8] DNS${NC}"
    dig "$target" ANY +short 2>/dev/null | head -5
    
    echo -e "\n${YELLOW}[3/8] Subdomains${NC}"
    if check_tool "sublist3r"; then
        timeout 60 python3 -m sublist3r -d "$target" -t 10 2>/dev/null | tail -10
    fi
    
    echo -e "\n${YELLOW}[4/8] Ports${NC}"
    nmap -T4 -F "$target" 2>/dev/null | grep "open"
    
    echo -e "\n${YELLOW}[5/8] Web Tech${NC}"
    if check_tool "whatweb"; then
        whatweb "http://$target" 2>/dev/null | head -3
    fi
    
    echo -e "\n${YELLOW}[6/8] Headers${NC}"
    curl -I "http://$target" 2>/dev/null | head -5
    
    echo -e "\n${YELLOW}[7/8] Emails${NC}"
    if check_tool "theHarvester"; then
        timeout 30 theHarvester -d "$target" -b google -l 5 2>/dev/null | grep "@"
    fi
    
    echo -e "\n${YELLOW}[8/8] Directories${NC}"
    if check_tool "dirb"; then
        timeout 60 dirb "http://$target" -w -S 2>/dev/null | grep "CODE:200"
    fi
}

social_eng_toolkit() {
    clear
    echo -e "${PURPLE}=== Social Engineering ===${NC}"
    echo "1) Email Validation"
    echo "2) Social Media Hunt"
    echo "3) Employee Enum"
    echo "4) Phishing Check"
    echo "5) Password Patterns"
    echo "6) Back"
    echo -n "Select [1-6]: "
    read -r se_choice
    
    case $se_choice in
        1) email_validation ;;
        2) username_search ;;
        3) employee_enum ;;
        4) phishing_check ;;
        5) password_patterns ;;
        6) return ;;
    esac
}

email_validation() {
    echo -n "Email: "
    read -r email
    domain=${email##*@}
    
    echo -e "${YELLOW}Validating $email...${NC}"
    echo -e "${CYAN}MX Record:${NC}"
    dig "$domain" MX +short
    
    echo -e "${CYAN}SMTP Test:${NC}"
    nc -zv "${domain}" 25 2>&1 | grep -q "succeeded" && echo "SMTP Open" || echo "SMTP Closed"
}

employee_enum() {
    echo -n "Company: "
    read -r company
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}Employee enum for $company...${NC}"
    echo -e "${CYAN}Search patterns:${NC}"
    echo "site:linkedin.com \"$company\""
    echo "site:github.com \"$company\""
    echo "\"@$domain\" site:linkedin.com"
    
    echo -e "${CYAN}Email patterns:${NC}"
    echo "firstname.lastname@$domain"
    echo "f.lastname@$domain"
    echo "firstname@$domain"
    echo "flastname@$domain"
}

phishing_check() {
    echo -n "Domain: "
    read -r domain
    
    echo -e "${YELLOW}Phishing check for $domain...${NC}"
    
    creation=$(whois "$domain" 2>/dev/null | grep -i "creation\|created" | head -1)
    registrar=$(whois "$domain" 2>/dev/null | grep -i "registrar" | head -1)
    
    echo -e "${CYAN}Creation:${NC} $creation"
    echo -e "${CYAN}Registrar:${NC} $registrar"
    
    echo -e "${CYAN}SSL Check:${NC}"
    echo | timeout 10 openssl s_client -connect "$domain:443" 2>/dev/null | openssl x509 -noout -subject -dates 2>/dev/null || echo "SSL check failed"
}

password_patterns() {
    echo -n "Company: "
    read -r company
    echo -n "Year [2024]: "
    read -r year
    year=${year:-2024}
    
    echo -e "${YELLOW}Password patterns for $company:${NC}"
    patterns=(
        "$company$year"
        "$company$year!"
        "$company123"
        "$company@$year"
        "${company}Password"
        "${company}Pass"
        "$company#$year"
    )
    
    for pattern in "${patterns[@]}"; do
        echo -e "${GREEN}$pattern${NC}"
    done
}

custom_tool() {
    echo -e "${CYAN}Available tools:${NC}"
    echo "nmap, whois, theHarvester, nikto, dirb, sublist3r, sherlock, dnsrecon, whatweb, curl, dig"
    echo -n "Command: "
    read -r command
    
    echo -e "${YELLOW}Executing: $command${NC}"
    eval "$command"
}

main() {
    check_deps
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) port_scan ;;
            2) subdomain_enum ;;
            3) dns_recon ;;
            4) network_discovery ;;
            5) web_vuln_scan ;;
            6) dir_bruteforce ;;
            7) web_tech_detect ;;
            8) http_header_analysis ;;
            9) email_harvest ;;
            10) username_search ;;
            11) domain_info ;;
            12) google_dorking ;;
            13) full_assessment ;;
            14) social_eng_toolkit ;;
            15) custom_tool ;;
            16) echo -e "${GREEN}Exit${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid${NC}" ;;
        esac
        
        echo -e "\n${BLUE}Press Enter...${NC}"
        read -r
    done
}

main "$@"