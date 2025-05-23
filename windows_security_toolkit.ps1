param([string]$Action)

$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Blue"
$CYAN = "Cyan"

function Write-ColorText($Text, $Color) {
    Write-Host $Text -ForegroundColor $Color
}

function Test-Tool($toolName) {
    $null = Get-Command $toolName -ErrorAction SilentlyContinue
    return $?
}

function Check-Dependencies {
    Write-ColorText "Checking required tools..." $BLUE
    $tools = @("nmap", "whois", "nikto", "dirb", "sqlmap", "curl", "dig", "hashcat")
    $missing = @()
    
    foreach ($tool in $tools) {
        if (Test-Tool $tool) {
            Write-Host "✓ $tool" -ForegroundColor $GREEN
        } else {
            Write-Host "✗ $tool" -ForegroundColor $RED
            $missing += $tool
        }
    }
    
    if ($missing.Count -gt 0) {
        Write-ColorText "Install missing tools using chocolatey:" $YELLOW
        Write-Host "choco install nmap nikto sqlmap curl hashcat"
        Write-Host "pip install theHarvester sublist3r sherlock-project"
        Start-Sleep 3
    }
}

function Show-Menu {
    Clear-Host
    Write-ColorText "╔═══════════════════════════════╗" $BLUE
    Write-ColorText "║   Windows Security Toolkit   ║" $BLUE
    Write-ColorText "╚═══════════════════════════════╝" $BLUE
    
    Write-ColorText "`nNetwork Scanning:" "Magenta"
    Write-Host "1)  Port Scan (Nmap)"
    Write-Host "2)  Network Discovery"
    Write-Host "3)  Service Detection"
    
    Write-ColorText "`nWeb Testing:" "Magenta"
    Write-Host "4)  Web Vulnerability Scan"
    Write-Host "5)  Directory Bruteforce"
    Write-Host "6)  SQL Injection Test"
    Write-Host "7)  HTTP Headers"
    
    Write-ColorText "`nReconnaissance:" "Magenta"
    Write-Host "8)  Subdomain Enumeration"
    Write-Host "9)  DNS Reconnaissance"
    Write-Host "10) Email Harvesting"
    Write-Host "11) Username Search"
    Write-Host "12) Domain Information"
    
    Write-ColorText "`nPassword & Hash:" "Magenta"
    Write-Host "13) Hash Cracking"
    Write-Host "14) Password Patterns"
    
    Write-ColorText "`nAdvanced:" "Magenta"
    Write-Host "15) Full Assessment"
    Write-Host "16) Google Dorking"
    Write-Host "17) Generate Report"
    Write-Host "18) Exit"
    
    $choice = Read-Host "`nSelect option [1-18]"
    return $choice
}

function Port-Scan {
    $target = Read-Host "Target IP/Domain"
    Write-Host "1) Quick  2) Full TCP  3) Stealth  4) Aggressive"
    $scanType = Read-Host "Scan type [1-4]"
    
    Write-ColorText "Scanning $target..." $YELLOW
    switch ($scanType) {
        1 { nmap -T4 -F $target }
        2 { nmap -T4 -p- $target }
        3 { nmap -sS -T4 -F $target }
        4 { nmap -A -T4 -F $target }
        default { nmap -T4 -F $target }
    }
}

function Network-Discovery {
    $network = Read-Host "Network range (e.g., 192.168.1.0/24)"
    Write-ColorText "Discovering hosts in $network..." $YELLOW
    nmap -sn $network
}

function Service-Detection {
    $target = Read-Host "Target"
    Write-ColorText "Detecting services on $target..." $YELLOW
    nmap -sV -sC $target
}

function Web-VulnScan {
    $url = Read-Host "Target URL"
    Write-ColorText "Vulnerability scanning $url..." $YELLOW
    if (Test-Tool "nikto") {
        nikto -h $url
    } else {
        Write-ColorText "Nikto not installed" $RED
    }
}

function Dir-Bruteforce {
    $url = Read-Host "Target URL"
    Write-ColorText "Directory bruteforcing $url..." $YELLOW
    if (Test-Tool "dirb") {
        dirb $url
    } else {
        Write-ColorText "Dirb not installed" $RED
    }
}

function SQL-InjectionTest {
    $url = Read-Host "Target URL"
    Write-ColorText "Testing SQL injection on $url..." $YELLOW
    if (Test-Tool "sqlmap") {
        sqlmap -u $url --batch --level=2
    } else {
        Write-ColorText "SQLMap not installed" $RED
    }
}

function HTTP-Headers {
    $url = Read-Host "Target URL"
    Write-ColorText "Analyzing headers for $url..." $YELLOW
    curl -I $url
}

function Subdomain-Enum {
    $domain = Read-Host "Target domain"
    Write-ColorText "Enumerating subdomains for $domain..." $YELLOW
    if (Test-Tool "python") {
        python -m sublist3r -d $domain
    } else {
        Write-ColorText "Sublist3r not installed" $RED
    }
}

function DNS-Recon {
    $domain = Read-Host "Target domain"
    Write-ColorText "DNS reconnaissance for $domain..." $YELLOW
    if (Test-Tool "dig") {
        dig $domain A
        dig $domain MX
        dig $domain NS
    } else {
        nslookup $domain
    }
}

function Email-Harvest {
    $domain = Read-Host "Target domain"
    $source = Read-Host "Search engine [google/bing/all]"
    Write-ColorText "Harvesting emails for $domain..." $YELLOW
    if (Test-Tool "python") {
        python -m theHarvester -d $domain -b $source
    } else {
        Write-ColorText "theHarvester not installed" $RED
    }
}

function Username-Search {
    $username = Read-Host "Username to search"
    Write-ColorText "Searching for $username..." $YELLOW
    if (Test-Tool "python") {
        python -m sherlock $username
    } else {
        Write-ColorText "Sherlock not installed" $RED
    }
}

function Domain-Info {
    $domain = Read-Host "Domain"
    Write-ColorText "Gathering information for $domain..." $YELLOW
    whois $domain
    nslookup $domain
}

function Hash-Cracking {
    $hashfile = Read-Host "Hash file path"
    $wordlist = Read-Host "Wordlist path"
    $hashtype = Read-Host "Hash type (0=MD5, 1000=NTLM, 1400=SHA256)"
    Write-ColorText "Cracking hashes..." $YELLOW
    if (Test-Tool "hashcat") {
        hashcat -m $hashtype $hashfile $wordlist
    } else {
        Write-ColorText "Hashcat not installed" $RED
    }
}

function Password-Patterns {
    $company = Read-Host "Company name"
    $year = Read-Host "Year [2024]"
    if (-not $year) { $year = "2024" }
    
    Write-ColorText "Password patterns for $company" $YELLOW
    $patterns = @(
        "$company$year", "$company$year!", "$company" + "123",
        "$company" + "Password", "$company" + "Pass", 
        $company.ToLower() + $year, $company.ToUpper() + $year
    )
    
    foreach ($pattern in $patterns) {
        Write-ColorText $pattern $GREEN
    }
}

function Full-Assessment {
    $target = Read-Host "Target (IP/Domain)"
    Write-ColorText "=== Full Security Assessment: $target ===" $GREEN
    
    Write-ColorText "[1/8] WHOIS Lookup" $YELLOW
    whois $target
    
    Write-ColorText "[2/8] DNS Records" $YELLOW
    nslookup $target
    
    Write-ColorText "[3/8] Port Scanning" $YELLOW
    nmap -T4 --top-ports 1000 $target
    
    Write-ColorText "[4/8] Service Detection" $YELLOW
    nmap -sV --top-ports 100 $target
    
    Write-ColorText "[5/8] HTTP Headers" $YELLOW
    curl -I "http://$target"
    
    Write-ColorText "[6/8] Directory Scanning" $YELLOW
    if (Test-Tool "dirb") {
        dirb "http://$target"
    }
    
    Write-ColorText "[7/8] Subdomain Enumeration" $YELLOW
    if (Test-Tool "python") {
        python -m sublist3r -d $target
    }
    
    Write-ColorText "[8/8] Vulnerability Check" $YELLOW
    if (Test-Tool "nikto") {
        nikto -h "http://$target"
    }
}

function Google-Dorking {
    $domain = Read-Host "Target domain"
    Write-ColorText "Google dorking patterns for $domain" $YELLOW
    $dorks = @(
        "site:$domain filetype:pdf",
        "site:$domain inurl:admin",
        "site:$domain inurl:login",
        "site:$domain intitle:`"index of`"",
        "site:$domain ext:sql OR ext:dbf",
        "site:$domain inurl:config",
        "`"$domain`" filetype:xls OR filetype:csv",
        "site:$domain intext:password",
        "site:$domain inurl:backup"
    )
    
    foreach ($dork in $dorks) {
        Write-ColorText $dork $GREEN
    }
}

function Generate-Report {
    $target = Read-Host "Target for report"
    $reportFile = "security_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    
    Write-ColorText "Generating security report for $target..." $YELLOW
    
    @"
Security Assessment Report
=========================
Target: $target
Date: $(Get-Date)
Generated by: Windows Security Toolkit

WHOIS Information:
$(whois $target)

DNS Records:
$(nslookup $target)

Open Ports:
$(nmap -T4 --top-ports 1000 $target)
"@ | Out-File -FilePath $reportFile
    
    Write-ColorText "Report saved to: $reportFile" $GREEN
}

function Main {
    Check-Dependencies
    
    while ($true) {
        $choice = Show-Menu
        
        switch ($choice) {
            1 { Port-Scan }
            2 { Network-Discovery }
            3 { Service-Detection }
            4 { Web-VulnScan }
            5 { Dir-Bruteforce }
            6 { SQL-InjectionTest }
            7 { HTTP-Headers }
            8 { Subdomain-Enum }
            9 { DNS-Recon }
            10 { Email-Harvest }
            11 { Username-Search }
            12 { Domain-Info }
            13 { Hash-Cracking }
            14 { Password-Patterns }
            15 { Full-Assessment }
            16 { Google-Dorking }
            17 { Generate-Report }
            18 { 
                Write-ColorText "Exiting Windows Security Toolkit" $GREEN
                exit 0 
            }
            default { Write-ColorText "Invalid option. Please try again." $RED }
        }
        
        Write-ColorText "`nPress Enter to continue..." $BLUE
        Read-Host
    }
}

Main
