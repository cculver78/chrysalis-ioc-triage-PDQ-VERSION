#Requires -Version 5.1
<#
.SYNOPSIS
  Checks the local Windows system for Chrysalis / Lotus Blossom IoCs.

.DESCRIPTION
  Uses IoCs from Rapid7's Chrysalis backdoor write-up:
  https://www.rapid7.com/blog/post/tr-chrysalis-backdoor-dive-into-lotus-blossoms-toolkit/

  Checks: file hashes, suspicious paths, mutex, Run keys, and services.
  Designed for deployment via PDQ Connect (self-contained, no external files).
#>

function Main {

    $ErrorActionPreference = 'Stop'
    $Findings = [System.Collections.ArrayList]::new()

    # ---- Embedded IoCs ----
    $fileHashes = @(
        'a511be5164dc1122fb5a7daa3eef9467e43d8458425b15a640235796006590c9'
        '8ea8b83645fba6e23d48075a0d3fc73ad2ba515b4536710cda4f1f232718f53e'
        '2da00de67720f5f13b17e9d985fe70f10f153da60c9ab1086fe58f069a156924'
        '77bfea78def679aa1117f569a35e8fd1542df21f7e00e27f192c907e61d63a2e'
        '3bdc4c0637591533f1d4198a72a33426c01f69bd2e15ceee547866f65e26b7ad'
        '9276594e73cda1c69b7d265b3f08dc8fa84bf2d6599086b9acc0bb3745146600'
        'f4d829739f2d6ba7e3ede83dad428a0ced1a703ec582fc73a4eee3df3704629a'
        '4a52570eeaf9d27722377865df312e295a7a23c3b6eb991944c2ecd707cc9906'
        '831e1ea13a1bd405f5bda2b9d8f2265f7b1db6c668dd2165ccc8a9c4c15ea7dd'
        '0a9b8df968df41920b6ff07785cbfebe8bda29e6b512c94a3b2a83d10014d2fd'
        '4c2ea8193f4a5db63b897a2d3ce127cc5d89687f380b97a1d91e0c8db542e4f8'
        'e7cd605568c38bd6e0aba31045e1633205d0598c607a855e2e1bca4cca1c6eda'
        '078a9e5c6c787e5532a7e728720cbafee9021bfec4a30e3c2be110748d7c43c5'
        'b4169a831292e245ebdffedd5820584d73b129411546e7d3eccf4663d5fc5be3'
        '7add554a98d3a99b319f2127688356c1283ed073a084805f14e33b4f6a6126fd'
        'fcc2765305bcd213b7558025b2039df2265c3e0b6401e4833123c461df2de51a'
    )

    $knownPaths = @(
        '%AppData%\Bluetooth'
        '%AppData%\Bluetooth\BluetoothService.exe'
        '%AppData%\Bluetooth\BluetoothService'
        '%AppData%\Bluetooth\log.dll'
    )

    $hashOnlyPaths = @(
        '%ProgramData%\USOShared'
        '%ProgramData%\USOShared\svchost.exe'
        '%ProgramData%\USOShared\conf.c'
        '%ProgramData%\USOShared\libtcc.dll'
    )

    $mutexes = @(
        'Global\Jdhfv_1.0.1'
    )

    $registryRunPaths = @(
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Run'
        'HKLM\Software\Microsoft\Windows\CurrentVersion\Run'
        'HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
    )

    # ---- Build hash lookup ----
    $hashSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($h in $fileHashes) { [void] $hashSet.Add($h) }

    # ---- Helpers ----
    function Expand-PathEnv {
        param([string]$p)
        $p = $p -replace '%AppData%', $env:APPDATA
        $p = $p -replace '%ProgramData%', $env:ProgramData
        $p = $p -replace '%TEMP%', $env:TEMP
        $p = $p -replace '%TMP%', $env:TMP
        return $p
    }

    function Get-FileSha256 {
        param([string]$Path)
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
        try {
            $bytes = [System.IO.File]::ReadAllBytes($Path)
            $sha   = [System.Security.Cryptography.SHA256]::Create()
            $hash  = $sha.ComputeHash($bytes)
            $sha.Dispose()
            return ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
        } catch {
            return $null
        }
    }

    # ---- 1) Known paths ----
    Write-Host '[*] Checking known paths...' -ForegroundColor Cyan
    foreach ($rel in $knownPaths) {
        $full = Expand-PathEnv $rel
        if (Test-Path -LiteralPath $full) {
            [void] $Findings.Add([PSCustomObject]@{
                Category = 'Path'; Detail = "Path exists: $full"; Severity = 'High'
                Time = (Get-Date).ToString('o')
            })
            Write-Host "  [FOUND] $full" -ForegroundColor Red
        }
    }

    # Hidden Bluetooth folder (Chrysalis-specific)
    $bluetoothDir = Expand-PathEnv '%AppData%\Bluetooth'
    if (Test-Path -LiteralPath $bluetoothDir) {
        $item = Get-Item -LiteralPath $bluetoothDir -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [System.IO.FileAttributes]::Hidden)) {
            [void] $Findings.Add([PSCustomObject]@{
                Category = 'Path'; Detail = "Hidden directory (Chrysalis install): $bluetoothDir"; Severity = 'High'
                Time = (Get-Date).ToString('o')
            })
            Write-Host "  [FOUND] Hidden dir: $bluetoothDir" -ForegroundColor Red
        }
    }

    # ---- 2) File hashes in known directories ----
    Write-Host '[*] Checking file hashes in known directories...' -ForegroundColor Cyan
    $pathsToHash = @($bluetoothDir, (Expand-PathEnv '%ProgramData%\USOShared'))
    foreach ($dir in $pathsToHash) {
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        Get-ChildItem -LiteralPath $dir -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $hash = Get-FileSha256 -Path $_.FullName
            if ($hash -and $hashSet.Contains($hash)) {
                [void] $Findings.Add([PSCustomObject]@{
                    Category = 'FileHash'; Detail = "Known malicious hash: $($_.FullName) (SHA256: $hash)"; Severity = 'Critical'
                    Time = (Get-Date).ToString('o')
                })
                Write-Host "  [MATCH] $($_.FullName) => $hash" -ForegroundColor Red
            }
        }
    }

    # ---- 3) Mutex ----
    Write-Host '[*] Checking mutexes...' -ForegroundColor Cyan
    foreach ($mutexName in $mutexes) {
        try {
            $m = [Threading.Mutex]::OpenExisting($mutexName)
            $m.Dispose()
            [void] $Findings.Add([PSCustomObject]@{
                Category = 'Mutex'; Detail = "Chrysalis mutex present (possible live implant): $mutexName"; Severity = 'Critical'
                Time = (Get-Date).ToString('o')
            })
            Write-Host "  [FOUND] $mutexName" -ForegroundColor Red
        } catch {
            # Mutex does not exist - expected on clean system
        }
    }

    # ---- 4) Registry Run keys ----
    Write-Host '[*] Checking Run keys...' -ForegroundColor Cyan
    foreach ($regPath in $registryRunPaths) {
        $base = if ($regPath -match '^HKCU') { 'HKCU:' } else { 'HKLM:' }
        $path = $base + '\' + ($regPath -replace '^(HKCU|HKLM)\\', '')
        if (-not (Test-Path -LiteralPath $path)) { continue }
        try {
            $props = Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue
            if (-not $props) { continue }
            $props.PSObject.Properties | Where-Object {
                $_.Name -notmatch '^(PSPath|PSParentPath|PSChildName|PSDrive|PSProvider)$'
            } | ForEach-Object {
                $valStr = if ($null -eq $_.Value) { '' } else { $_.Value.ToString() }
                if (-not $valStr) { return }
                if ($valStr -match 'Bluetooth\\BluetoothService\.exe' -or
                   ($valStr -match 'AppData[\\/].*Bluetooth' -and $valStr -match '\s-[ik]\s')) {
                    [void] $Findings.Add([PSCustomObject]@{
                        Category = 'Registry'; Detail = "Run key (Chrysalis-like): $path -> $($_.Name) = $valStr"; Severity = 'High'
                        Time = (Get-Date).ToString('o')
                    })
                    Write-Host "  [SUSPICIOUS] $path | $($_.Name) = $valStr" -ForegroundColor Yellow
                }
            }
        } catch { }
    }

    # ---- 5) Services ----
    Write-Host '[*] Checking services...' -ForegroundColor Cyan
    Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -eq 'BluetoothService' -or
        ($_.PathName -match 'AppData[\\/].*Bluetooth[\\/]BluetoothService\.exe')
    } | ForEach-Object {
        [void] $Findings.Add([PSCustomObject]@{
            Category = 'Service'; Detail = "Service (Chrysalis-like): $($_.Name) | Path: $($_.PathName)"; Severity = 'High'
            Time = (Get-Date).ToString('o')
        })
        Write-Host "  [SUSPICIOUS] $($_.Name) => $($_.PathName)" -ForegroundColor Yellow
    }

    # ---- Report ----
    Write-Host "`n========== Summary ==========" -ForegroundColor Cyan
    $critical = @($Findings | Where-Object { $_.Severity -eq 'Critical' })
    $high     = @($Findings | Where-Object { $_.Severity -eq 'High' })
    if ($critical.Count -gt 0) {
        Write-Host "CRITICAL: $($critical.Count) finding(s)" -ForegroundColor Red
    }
    if ($high.Count -gt 0) {
        Write-Host "HIGH:     $($high.Count) finding(s)" -ForegroundColor Yellow
    }
    if ($Findings.Count -eq 0) {
        Write-Host 'No Chrysalis IoCs detected in checked locations.' -ForegroundColor Green
    }

    # Save JSON report to a predictable location
    $reportDir = Join-Path $env:ProgramData 'ChrysalisScan'
    if (-not (Test-Path -LiteralPath $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    $reportPath = Join-Path $reportDir "chrysalis-scan-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $Findings | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath -Encoding UTF8
    Write-Host "Report saved: $reportPath" -ForegroundColor Gray

    if ($Findings.Count -gt 0) { exit 1 } else { exit 0 }
}

Main
