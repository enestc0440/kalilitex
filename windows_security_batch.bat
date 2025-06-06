@echo off
setlocal enabledelayedexpansion
color 0F

:check_deps
echo Checking required tools...
set "tools=nmap whois nikto dirb sqlmap curl hashcat python"
for %%t in (%tools%) do (
    where %%t >nul 2>&1
    if !errorlevel! equ 0 (
        echo [92m✓[0m %%t
    ) else (
        echo [91m✗[0m %%t
    )
)
echo.
echo Install missing tools:
echo choco install nmap nikto sqlmap curl hashcat python
echo pip install theHarvester sublist3r sherlock-project
timeout /t 3 >nul

:main_menu
cls
echo [94m╔═══════════════════════════════╗[0m
echo [94m║   Windows Security Toolkit   ║[0m
echo [94m╚═══════════════════════════════╝[0m
echo.
echo [95mNetwork Scanning:[0m
echo 1^)  Port Scan ^(Nmap^)
echo 2^)  Network Discovery
echo 3^)  Service Detection
echo.
echo [95mWeb Testing:[0m
echo 4^)  Web Vulnerability Scan
echo 5^)  Directory Bruteforce
echo 6^)  SQL Injection Test
echo 7^)  HTTP Headers
echo.
echo [95mReconnaissance:[0m
echo 8^)  Subdomain Enumeration
echo 9^)  DNS Reconnaissance
echo 10^) Email Harvesting
echo 11^) Username Search
echo 12^) Domain Information
echo.
echo [95mPassword ^& Hash:[0m
echo 13^) Hash Cracking
echo 14^) Password Patterns
echo.
echo [95mAdvanced:[0m
echo 15^) Full Assessment
echo 16^) Google Dorking
echo 17^) Generate Report
echo 18^) Exit
echo.
set /p choice="[96mSelect option [1-18]: [0m"

if "%choice%"=="1" goto port_scan
if "%choice%"=="2" goto network_discovery
if "%choice%"=="3" goto service_detection
if "%choice%"=="4" goto web_vuln_scan
if "%choice%"=="5" goto dir_bruteforce
if "%choice%"=="6" goto sql_injection_test
if "%choice%"=="7" goto http_headers
if "%choice%"=="8" goto subdomain_enum
if "%choice%"=="9" goto dns_recon
if "%choice%"=="10" goto email_harvest
if "%choice%"=="11" goto username_search
if "%choice%"=="12" goto domain_info
if "%choice%"=="13" goto hash_cracking
if "%choice%"=="14" goto password_patterns
if "%choice%"=="15" goto full_assessment
if "%choice%"=="16" goto google_dorking
if "%choice%"=="17" goto generate_report
if "%choice%"=="18" goto exit_program
echo [91mInvalid option. Please try again.[0m
pause
goto main_menu

:port_scan
set /p target="Target IP/Domain: "
echo 1^) Quick  2^) Full TCP  3^) Stealth  4^) Aggressive
set /p scan_type="Scan type [1-4]: "
echo [93mScanning %target%...[0m
if "%scan_type%"=="1" nmap -T4 -F %target%
if "%scan_type%"=="2" nmap -T4 -p- %target%
if "%scan_type%"=="3" nmap -sS -T4 -F %target%
if "%scan_type%"=="4" nmap -A -T4 -F %target%
if "%scan_type%"=="" nmap -T4 -F %target%
goto continue

:network_discovery
set /p network="Network range (e.g., 192.168.1.0/24): "
echo [93mDiscovering hosts in %network%...[0m
nmap -sn %network%
goto continue

:service_detection
set /p target="Target: "
echo [93mDetecting services on %target%...[0m
nmap -sV -sC %target%
goto continue

:web_vuln_scan
set /p url="Target URL: "
echo [93mVulnerability scanning %url%...[0m
where nikto >nul 2>&1
if %errorlevel% equ 0 (
    nikto -h %url%
) else (
    echo [91mNikto not installed[0m
)
goto continue

:dir_bruteforce
set /p url="Target URL: "
echo [93mDirectory bruteforcing %url%...[0m
where dirb >nul 2>&1
if %errorlevel% equ 0 (
    dirb %url%
) else (
    echo [91mDirb not installed[0m
)
goto continue

:sql_injection_test
set /p url="Target URL: "
echo [93mTesting SQL injection on %url%...[0m
where sqlmap >nul 2>&1
if %errorlevel% equ 0 (
    sqlmap -u %url% --batch --level=2
) else (
    echo [91mSQLMap not installed[0m
)
goto continue

:http_headers
set /p url="Target URL: "
echo [93mAnalyzing headers for %url%...[0m
curl -I %url%
goto continue

:subdomain_enum
set /p domain="Target domain: "
echo [93mEnumerating subdomains for %domain%...[0m
where python >nul 2>&1
if %errorlevel% equ 0 (
    python -m sublist3r -d %domain%
) else (
    echo [91mSublist3r not installed[0m
)
goto continue

:dns_recon
set /p domain="Target domain: "
echo [93mDNS reconnaissance for %domain%...[0m
where dig >nul 2>&1
if %errorlevel% equ 0 (
    dig %domain% A
    dig %domain% MX
    dig %domain% NS
) else (
    nslookup %domain%
)
goto continue

:email_harvest
set /p domain="Target domain: "
set /p source="Search engine [google/bing/all]: "
echo [93mHarvesting emails for %domain%...[0m
where python >nul 2>&1
if %errorlevel% equ 0 (
    python -m theHarvester -d %domain% -b %source%
) else (
    echo [91mtheHarvester not installed[0m
)
goto continue

:username_search
set /p username="Username to search: "
echo [93mSearching for %username%...[0m
where python >nul 2>&1
if %errorlevel% equ 0 (
    python -m sherlock %username%
) else (
    echo [91mSherlock not installed[0m
)
goto continue

:domain_info
set /p domain="Domain: "
echo [93mGathering information for %domain%...[0m
whois %domain%
nslookup %domain%
goto continue

:hash_cracking
set /p hashfile="Hash file path: "
set /p wordlist="Wordlist path: "
set /p hashtype="Hash type (0=MD5, 1000=NTLM, 1400=SHA256): "
echo [93mCracking hashes...[0m
where hashcat >nul 2>&1
if %errorlevel% equ 0 (
    hashcat -m %hashtype% %hashfile% %wordlist%
) else (
    echo [91mHashcat not installed[0m
)
goto continue

:password_patterns
set /p company="Company name: "
set /p year="Year [2024]: "
if "%year%"=="" set year=2024
echo [93mPassword patterns for %company%:[0m
echo [92m%company%%year%[0m
echo [92m%company%%year%![0m
echo [92m%company%123[0m
echo [92m%company%Password[0m
echo [92m%company%Pass[0m
goto continue

:full_assessment
set /p target="Target (IP/Domain): "
echo [92m=== Full Security Assessment: %target% ===[0m
echo.
echo [93m[1/6] WHOIS Lookup[0m
whois %target%
echo.
echo [93m[2/6] DNS Records[0m
nslookup %target%
echo.
echo [93m[3/6] Port Scanning[0m
nmap -T4 --top-ports 1000 %target%
echo.
echo [93m[4/6] Service Detection[0m
nmap -sV --top-ports 100 %target%
echo.
echo [93m[5/6] HTTP Headers[0m
curl -I http://%target%
echo.
echo [93m[6/6] Directory Scanning[0m
where dirb >nul 2>&1
if %errorlevel% equ 0 (
    dirb http://%target%
)
goto continue

:google_dorking
set /p domain="Target domain: "
echo [93mGoogle dorking patterns for %domain%:[0m
echo [92msite:%domain% filetype:pdf[0m
echo [92msite:%domain% inurl:admin[0m
echo [92msite:%domain% inurl:login[0m
echo [92msite:%domain% intitle:"index of"[0m
echo [92msite:%domain% ext:sql OR ext:dbf[0m
echo [92msite:%domain% inurl:config[0m
echo [92m"%domain%" filetype:xls OR filetype:csv[0m
echo [92msite:%domain% intext:password[0m
echo [92msite:%domain% inurl:backup[0m
goto continue

:generate_report
set /p target="Target for report: "
set report_file=security_report_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt
echo [93mGenerating security report for %target%...[0m
(
echo Security Assessment Report
echo =========================
echo Target: %target%
echo Date: %date% %time%
echo Generated by: Windows Security Toolkit
echo.
echo WHOIS Information:
whois %target%
echo.
echo DNS Records:
nslookup %target%
echo.
echo Open Ports:
nmap -T4 --top-ports 1000 %target%
) > %report_file%
echo [92mReport saved to: %report_file%[0m
goto continue

:continue
echo.
echo [94mPress any key to continue...[0m
pause >nul
goto main_menu

:exit_program
echo [92mExiting Windows Security Toolkit[0m
exit /b 0
