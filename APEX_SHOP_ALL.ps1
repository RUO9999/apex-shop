# APEX SHOP V3 - All-in-One (iex Ready, No External Files)
# Contains: Auto-Elevate + License Check + HWID Lock + Heartbeat + 150 Tweaks UI

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================================
# AUTO ELEVATE
# ==========================================
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $BaseUrl = "https://raw.githubusercontent.com/RUO9999/apex-shop/main/APEX_SHOP_ALL.ps1"
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"iwr -useb $BaseUrl | iex`"" -Verb RunAs
    exit
}

# ==========================================
# LICENSE MODULE (from license_check.ps1)
# ==========================================
$script:LicenseServer = "http://localhost:8090"
$script:LicenseCacheFile = "$env:APPDATA\ApexShop\license_cache.json"
$script:CacheDays = 7
$script:HeartbeatTimer = $null
$script:LicenseRevoked = $false

$colBgDark = [System.Drawing.Color]::FromArgb(12, 12, 12)
$colBgPanel = [System.Drawing.Color]::FromArgb(22, 22, 22)
$colBgList = [System.Drawing.Color]::FromArgb(18, 18, 18)
$colGreen = [System.Drawing.Color]::FromArgb(0, 255, 100)
$colGreenDark = [System.Drawing.Color]::FromArgb(0, 180, 70)
$colRed = [System.Drawing.Color]::FromArgb(255, 80, 80)
$colTextGray = [System.Drawing.Color]::FromArgb(160, 160, 160)
$colYellow = [System.Drawing.Color]::FromArgb(255, 200, 0)

function Get-HWID {
    try {
        $bb = (Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue).SerialNumber
        $bios = (Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue).SerialNumber
        $cpu = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue).ProcessorId
        $disk = (Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue | Select-Object -First 1).SerialNumber
        $raw = "$bb|$bios|$cpu|$disk"
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $hash = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($raw))
        return [System.BitConverter]::ToString($hash).Replace("-","").Substring(0,32)
    } catch { return "UNKNOWN-HWID" }
}

function Get-CachedLicense {
    if (-not (Test-Path $script:LicenseCacheFile)) { return $null }
    try {
        $cache = Get-Content $script:LicenseCacheFile -Raw | ConvertFrom-Json
        $cachedTime = [DateTime]::Parse($cache.timestamp)
        $daysOld = ([DateTime]::Now - $cachedTime).TotalDays
        if ($daysOld -gt $script:CacheDays) { return $null }
        if ($cache.hwid -ne (Get-HWID)) { return $null }
        return $cache
    } catch { return $null }
}

function Save-LicenseCache {
    param($Key, $DaysLeft)
    $dir = Split-Path $script:LicenseCacheFile -Parent
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
    $data = @{ key = $Key; hwid = (Get-HWID); days_left = $DaysLeft; timestamp = [DateTime]::Now.ToString("o") }
    $data | ConvertTo-Json | Set-Content -Path $script:LicenseCacheFile -Encoding UTF8
}

function Test-LicenseKey {
    param([string]$Key, [string]$HWID)
    try {
        $clientTime = [long][double]::Parse((Get-Date -UFormat %s))
        $body = @{
            license_key = $Key
            hwid = $HWID
            client_time = $clientTime
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$script:LicenseServer/api/validate" `
            -Method POST -Body $body -ContentType "application/json" -TimeoutSec 3 -ErrorAction Stop
        
        # ตรวจสอบ Response Structure
        if (-not $response.data -or -not $response.sig) {
            return @{ valid = $false; reason = "Malformed response" }
        }
        
        # ตรวจสอบ Signature (ป้องกัน Response ปลอม)
        if (-not (Test-ResponseSignature -Data $response.data -Signature $response.sig)) {
            return @{ valid = $false; reason = "Invalid signature" }
        }
        
        # ตรวจสอบ Time Skew
        if ($response.data.server_time -and (Test-TimeSkew -ServerTime $response.data.server_time)) {
            return @{ valid = $false; reason = "Time mismatch" }
        }
        
        # คืนค่า data จริง
        return @{
            valid = $response.data.valid
            days_left = $response.data.days_left
            note = $response.data.note
        }
    } catch {
        return @{ valid = $false; reason = "Server unreachable" }
    }
}

function Show-LicenseLogin {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "APEX SHOP - License Verification"
    $form.Size = New-Object System.Drawing.Size(500, 280)
    $form.BackColor = $colBgDark
    $form.ForeColor = $colGreen
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "APEX SHOP V3"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = $colGreen
    $title.Size = New-Object System.Drawing.Size(460, 40)
    $title.Location = New-Object System.Drawing.Point(20, 15)
    $title.TextAlign = "MiddleCenter"
    $form.Controls.Add($title)

    $sub = New-Object System.Windows.Forms.Label
    $sub.Text = "Please enter your License Key"
    $sub.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $sub.ForeColor = $colTextGray
    $sub.Size = New-Object System.Drawing.Size(460, 25)
    $sub.Location = New-Object System.Drawing.Point(20, 60)
    $sub.TextAlign = "MiddleCenter"
    $form.Controls.Add($sub)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "License Key:"
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lbl.ForeColor = $colGreen
    $lbl.Size = New-Object System.Drawing.Size(460, 20)
    $lbl.Location = New-Object System.Drawing.Point(20, 100)
    $form.Controls.Add($lbl)

    $script:keyInput = New-Object System.Windows.Forms.TextBox
    $script:keyInput.Font = New-Object System.Drawing.Font("Consolas", 14)
    $script:keyInput.BackColor = $colBgPanel
    $script:keyInput.ForeColor = $colGreen
    $script:keyInput.Size = New-Object System.Drawing.Size(440, 35)
    $script:keyInput.Location = New-Object System.Drawing.Point(20, 125)
    $script:keyInput.BorderStyle = "FixedSingle"
    $script:keyInput.CharacterCasing = "Upper"
    $script:keyInput.TextAlign = "Center"
    $form.Controls.Add($script:keyInput)

    $status = New-Object System.Windows.Forms.Label
    $status.Text = ""
    $status.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $status.ForeColor = $colRed
    $status.Size = New-Object System.Drawing.Size(460, 25)
    $status.Location = New-Object System.Drawing.Point(20, 170)
    $status.TextAlign = "MiddleCenter"
    $form.Controls.Add($status)

    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "ACTIVATE"
    $btnOk.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $btnOk.BackColor = $colGreen
    $btnOk.ForeColor = $colBgDark
    $btnOk.FlatStyle = "Flat"
    $btnOk.FlatAppearance.BorderSize = 0
    $btnOk.Size = New-Object System.Drawing.Size(210, 45)
    $btnOk.Location = New-Object System.Drawing.Point(20, 205)
    $form.Controls.Add($btnOk)

    $btnExit = New-Object System.Windows.Forms.Button
    $btnExit.Text = "EXIT"
    $btnExit.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $btnExit.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    $btnExit.ForeColor = $colRed
    $btnExit.FlatStyle = "Flat"
    $btnExit.FlatAppearance.BorderSize = 0
    $btnExit.Size = New-Object System.Drawing.Size(210, 45)
    $btnExit.Location = New-Object System.Drawing.Point(250, 205)
    $form.Controls.Add($btnExit)

    $script:LicenseValid = $false

    $btnOk.Add_Click({
        $key = $script:keyInput.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($key)) {
            $status.Text = "Please enter a License Key"
            $status.ForeColor = $colRed
            return
        }
        $status.Text = "Checking..."
        $status.ForeColor = $colYellow
        $btnOk.Enabled = $false
        [System.Windows.Forms.Application]::DoEvents()

        $result = Test-LicenseKey -Key $key -HWID (Get-HWID)
        if ($result.valid) {
            $status.Text = "Success! $($result.days_left) days remaining"
            $status.ForeColor = $colGreen
            Save-LicenseCache -Key $key -DaysLeft $result.days_left
            $script:LicenseValid = $true
            Start-Sleep -Milliseconds 800
            $form.Close()
        } else {
            $status.Text = "Failed: $($result.reason)"
            $status.ForeColor = $colRed
            $btnOk.Enabled = $true
        }
    })

    $script:keyInput.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") { $btnOk.PerformClick() }
    })

    $btnExit.Add_Click({ $form.Close() })

    $form.Add_Shown({
        $form.Activate()
        $form.BringToFront()
        $form.TopMost = $true
        $form.TopMost = $false
        $script:keyInput.Select()
        $script:keyInput.Focus() | Out-Null
    })

    [void]$form.ShowDialog()
    return $script:LicenseValid
}

function Confirm-License {
    $cache = Get-CachedLicense
    if ($cache) {
        Write-Host "[License] Checking API..." -ForegroundColor Cyan
        $result = Test-LicenseKey -Key $cache.key -HWID (Get-HWID)
        if ($result.valid) {
            Write-Host "[License] OK - $($result.days_left) days left" -ForegroundColor Green
            Save-LicenseCache -Key $cache.key -DaysLeft $result.days_left
            return $true
        }
        if ($result.reason -eq "Server unreachable") {
            Write-Host "[License] Server offline - using cache" -ForegroundColor Yellow
            return $true
        }
        Write-Host "[License] $($result.reason)" -ForegroundColor Red
        return Show-LicenseLogin
    }
    Write-Host "[License] Please verify." -ForegroundColor Yellow
    return Show-LicenseLogin
}

function Start-LicenseHeartbeat {
    param([int]$IntervalMs = 1000)
    if ($script:HeartbeatTimer) { $script:HeartbeatTimer.Stop(); $script:HeartbeatTimer.Dispose() }
    $script:HeartbeatTimer = New-Object System.Windows.Forms.Timer
    $script:HeartbeatTimer.Interval = $IntervalMs
    $script:HeartbeatTimer.Add_Tick({
        if ($script:LicenseRevoked) { return }
        $cache = Get-CachedLicense
        if (-not $cache) { return }
        $result = Test-LicenseKey -Key $cache.key -HWID (Get-HWID)
        if (-not $result.valid -and $result.reason -ne "Server unreachable") {
            $script:LicenseRevoked = $true
            $script:HeartbeatTimer.Stop()
            Write-Host "[License] REVOKED" -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show("License revoked: $($result.reason)", "APEX SHOP V3", "OK", "Error") | Out-Null
            [System.Windows.Forms.Application]::Exit()
        }
    })
    $script:HeartbeatTimer.Start()
    Write-Host "[License] Heartbeat ON" -ForegroundColor Green
}

function Stop-LicenseHeartbeat {
    if ($script:HeartbeatTimer) { $script:HeartbeatTimer.Stop(); $script:HeartbeatTimer.Dispose(); $script:HeartbeatTimer = $null }
}
# ==========================================
# ANTI-CRACK LAYER
# ==========================================

$script:ServerSecret = "APEX-SHOP-SERVER-KEY-7f3a9b2c4d8e1f6a-2026-CHANGE-ME"
$script:StartTime = [System.Diagnostics.Stopwatch]::StartNew()

function Test-DebuggerPresent {
    $suspicious = @("x64dbg","ollydbg","ida","ida64","windbg","dnspy","cheatengine","processhacker","fiddler","charles","httpdebugger","wireshark")
    try {
        $running = Get-Process -ErrorAction SilentlyContinue | Where-Object { $suspicious -contains $_.ProcessName.ToLower() }
        return ($running | Measure-Object).Count -gt 0
    } catch { return $false }
}

function Test-VM {
    try {
        $vmSigs = @("VMware","VBOX","VirtualBox","QEMU","Xen","Virtual","Parallels")
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
        $bios = Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue
        foreach ($sig in $vmSigs) {
            if ($cs.Manufacturer -like "*$sig*" -or $cs.Model -like "*$sig*") { return $true }
            if ($bios.Manufacturer -like "*$sig*") { return $true }
        }
        return $false
    } catch { return $false }
}

function Test-TimeSkew {
    param([long]$ServerTime)
    
    # ใช้เวลา UTC ของ Server เป็นหลัก
    # Server ส่ง UTC timestamp → Client คำนวณ UTC เช่นกัน
    $epoch = [datetime]::new(1970, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
    $clientTime = [long](([datetime]::UtcNow - $epoch).TotalSeconds)
    
    $diff = [Math]::Abs($clientTime - $ServerTime)
    
    Write-Host "[TimeSkew] Client UTC: $clientTime | Server: $ServerTime | Diff: $diff" -ForegroundColor DarkGray
    
    # ยอมรับความต่างได้ 24 ชั่วโมง (86400 วินาที) เพื่อรองรับ timezone
    return ($diff -gt 86400)
}



# ==========================================
# RUN LICENSE CHECK
# ==========================================
if (-not (Confirm-License)) {
    [System.Windows.Forms.MessageBox]::Show("Invalid License", "APEX SHOP V3", "OK", "Error")
    exit
}
Start-LicenseHeartbeat -IntervalMs 1000

# ==========================================
# APEX SHOP - TWEAK DATABASE (150 Tweaks)
# ==========================================
function Set-Reg {
    param([string]$Path,[string]$Name,$Value,[string]$Type="DWord")
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction SilentlyContinue
}

$script:AllTweaks = @()
function Add-Tweak {
    param($Name, $Category, $Action)
    $script:AllTweaks += [PSCustomObject]@{ Name = $Name; Category = $Category; Action = $Action; Checked = $false }
}

# ---- GAMING (30) ----
Add-Tweak "Disable Game DVR" "GAMING" { Set-Reg "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0; Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 0 }
Add-Tweak "Disable Game Bar" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 0 }
Add-Tweak "Enable Game Mode" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1; Set-Reg "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 1 }
Add-Tweak "Disable Fullscreen Opt" "GAMING" { Set-Reg "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2 }
Add-Tweak "Set GPU Priority High" "GAMING" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "GPU Priority" 8 }
Add-Tweak "Set GPU Task Priority" "GAMING" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Priority" 6 }
Add-Tweak "Set CPU Scheduling" "GAMING" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Scheduling Category" "High" }
Add-Tweak "Set SFIO Priority" "GAMING" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "SFIO Priority" "High" }
Add-Tweak "Disable Xbox Auth" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\XblAuthManager" "Start" 4 }
Add-Tweak "Disable Xbox Save" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\XblGameSave" "Start" 4 }
Add-Tweak "Disable Xbox Net API" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" "Start" 4 }
Add-Tweak "Disable Xbox GIP" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\XboxGipSvc" "Start" 4 }
Add-Tweak "Disable DVR Policy" "GAMING" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 0 }
Add-Tweak "Disable Game Bar Tips" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\GameBar" "ShowStartupPanel" 0 }
Add-Tweak "Disable Game Input" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\GameInput" "Start" 4 }
Add-Tweak "Disable Gaming Services" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\GamingServices" "Start" 4 }
Add-Tweak "Disable Gaming Services Net" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\GamingServicesNet" "Start" 4 }
Add-Tweak "Disable HW GPU Scheduling" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 0 }
Add-Tweak "Set GPU Scheduling" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "Scheduling" 1 }
Add-Tweak "Disable GPU Throttling" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "DisableThrottling" 1 }
Add-Tweak "Disable GPU Power Mgmt" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "DisablePowerManagement" 1 }
Add-Tweak "Disable GPU Energy Saving" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "DisableEnergySaving" 1 }
Add-Tweak "Disable DX VSync" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" "DirectXUserGlobalSettings" "SwapEffectUpgradeEnable=0;" "String" }
Add-Tweak "Disable Game Bar Overlay" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "OverlayEnabled" 0 }
Add-Tweak "Disable Game Bar Presence" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "PresenceEnabled" 0 }
Add-Tweak "Disable Game Bar Controller" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "ControllerEnabled" 0 }
Add-Tweak "Disable Game Bar Mic" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "MicrophoneEnabled" 0 }
Add-Tweak "Disable Game Bar Webcam" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "WebcamEnabled" 0 }
Add-Tweak "Disable Game Bar Chat" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "ChatEnabled" 0 }
Add-Tweak "Disable Game Bar Capture" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "CaptureEnabled" 0 }

# ---- CPU & RAM (40) ----
Add-Tweak "Win32PrioritySeparation" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 38 }
Add-Tweak "Disable Memory Compression" "CPU & RAM" { Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue }
Add-Tweak "Large System Cache" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache" 1 }
Add-Tweak "Disable Paging Executive" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1 }
Add-Tweak "Clear Page File" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "ClearPageFileAtShutdown" 1 }
Add-Tweak "IoPageLockLimit" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "IoPageLockLimit" 0x10000 }
Add-Tweak "Second Level Cache" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SecondLevelDataCache" 1024 }
Add-Tweak "Disable Boot Optimize" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "BootOptimizeFunction" 0 }
Add-Tweak "Disable Superfetch" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0 }
Add-Tweak "Disable Prefetch" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnablePrefetcher" 0 }
Add-Tweak "Disable SysMain" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SysMain" "Start" 4 }
Add-Tweak "Disable NTFS Last Access" "CPU & RAM" { fsutil behavior set disablelastaccess 1 | Out-Null }
Add-Tweak "Disable 8.3 Names" "CPU & RAM" { fsutil behavior set disable8dot3 1 | Out-Null }
Add-Tweak "NTFS Memory Usage" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "NtfsMemoryUsage" 2 }
Add-Tweak "MFT Zone" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "NtfsMftZoneReservation" 2 }
Add-Tweak "Memory Priority" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "MemoryPriority" 5 }
Add-Tweak "Disable CPU Throttling" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" "ValueMax" 0 }
Add-Tweak "Disable CPU Core Parking" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" "ValueMin" 100 }
Add-Tweak "Disable CPU Migration" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" "AdditionalCriticalWorkerThreads" 0 }
Add-Tweak "Disable CPU Idle" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\5d76a2ca-e8c0-402f-a133-2158492d58ad" "ValueMax" 0 }
Add-Tweak "Set CPU Performance" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" "ValueMax" 100 }
Add-Tweak "Disable CPU C-States" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" "ValueMin" 0 }
Add-Tweak "Set CPU Turbo" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" "ValueMax" 100 }
Add-Tweak "Disable CPU Thermal" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" "ValueMin" 100 }
Add-Tweak "Set CPU Affinity" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" "AdditionalDelayedWorkerThreads" 0 }
Add-Tweak "Disable CPU Frequency Scaling" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" "ValueMax" 100 }
Add-Tweak "Disable CPU Limits" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Executive" "AdditionalCriticalWorkerThreads" 0 }
Add-Tweak "Disable CPU Branch Prediction" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1 }
Add-Tweak "Disable Kernel Paging" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1 }
Add-Tweak "Disable Driver Paging" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1 }
Add-Tweak "Disable Heap Decompression" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1 }
Add-Tweak "Set System Cache" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache" 1 }
Add-Tweak "Disable Prefetch 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnablePrefetcher" 0 }
Add-Tweak "Disable Superfetch 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0 }
Add-Tweak "Disable Boot Optimize 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "BootOptimizeFunction" 0 }
Add-Tweak "Set CPU Cache" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SecondLevelDataCache" 1024 }
Add-Tweak "Disable CPU Parking" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" "ValueMin" 100 }
Add-Tweak "Set CPU Boost" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" "ValueMax" 100 }

# ---- VISUAL (40) ----
Add-Tweak "Disable Animations" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "0" "String" }
Add-Tweak "Disable Transparency" "VISUAL" { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 }
Add-Tweak "Menu Delay Zero" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0" "String" }
Add-Tweak "Disable Mouse Accel" "VISUAL" { Set-Reg "HKCU:\Control Panel\Mouse" "MouseSpeed" "0" "String"; Set-Reg "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0" "String"; Set-Reg "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0" "String" }
Add-Tweak "Disable Sticky Keys" "VISUAL" { Set-Reg "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" "String" }
Add-Tweak "Disable Filter Keys" "VISUAL" { Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122" "String" }
Add-Tweak "Disable Toggle Keys" "VISUAL" { Set-Reg "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58" "String" }
Add-Tweak "Disable Lock Screen" "VISUAL" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreen" 1 }
Add-Tweak "Disable Screensaver" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "ScreenSaveActive" "0" "String" }
Add-Tweak "Disable Aero Shake" "VISUAL" { Set-Reg "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "NoWindowMinimizingShortcuts" 1 }
Add-Tweak "Disable Aero Snap" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "WindowArrangementActive" "0" "String" }
Add-Tweak "Disable Aero Peek" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" 0 }
Add-Tweak "Disable Jump Lists" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" 0 }
Add-Tweak "Disable Recent Files" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" 0 }
Add-Tweak "Disable Background Apps" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1 }
Add-Tweak "Disable Taskbar Anim" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" 0 }
Add-Tweak "Disable Font Smoothing" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "FontSmoothing" "0" "String" }
Add-Tweak "Disable ClearType" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "FontSmoothingType" 0 }
Add-Tweak "Disable Thumbnails" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "IconsOnly" 1 }
Add-Tweak "Disable List Shadow" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" 0 }
Add-Tweak "Disable List Watermark" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewWatermark" 0 }
Add-Tweak "Disable Start Menu Anim" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "UserPreferencesMask" ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) "Binary" }
Add-Tweak "Disable Fade Anim" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "UserPreferencesMask" ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) "Binary" }
Add-Tweak "Disable DWM Comp" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\DWM" "Composition" 0 }
Add-Tweak "Disable Theme Service" "VISUAL" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Themes" "Start" 4 }
Add-Tweak "Disable Visual Effects" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 2 }
Add-Tweak "Disable Shadow Effects" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" 0 }
Add-Tweak "Disable Cursor Shadow" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "CursorShadow" 0 }
Add-Tweak "Disable Icon Cache" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "Max Cached Icons" "2048" "String" }
Add-Tweak "Disable Font Cache" "VISUAL" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\FontCache" "Start" 4 }
Add-Tweak "Disable High Contrast" "VISUAL" { Set-Reg "HKCU:\Control Panel\Accessibility\HighContrast" "Flags" "126" "String" }
Add-Tweak "Disable Narrator" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Narrator\NoRoam" "RunningState" 0 }
Add-Tweak "Disable Magnifier" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\ScreenMagnifier" "RunningState" 0 }
Add-Tweak "Disable On-Screen KB" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Osk" "RunningState" 0 }
Add-Tweak "Disable Touch KB" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\TabletTip\1.7" "EnableDesktopModeAutoInvoke" 0 }
Add-Tweak "Disable Handwriting" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" 1 }
Add-Tweak "Disable Start Recs" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_IrisRecommendations" 0 }
Add-Tweak "Disable Taskbar Widgets" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0 }
Add-Tweak "Disable Taskbar Chat" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 0 }
Add-Tweak "Disable Taskbar Search" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SearchboxTaskbarMode" 0 }
Add-Tweak "Disable Taskbar View" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1 }

# ---- NETWORK (20) ----
Add-Tweak "Disable Network Throttling" "NETWORK" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff }
Add-Tweak "System Responsiveness" "NETWORK" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 0 }
Add-Tweak "Disable Nagle" "NETWORK" { $i=Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"; foreach($x in $i){ Set-Reg $x.PSPath "TcpAckFrequency" 1; Set-Reg $x.PSPath "TCPNoDelay" 1; Set-Reg $x.PSPath "TcpDelAckTicks" 0 } }
Add-Tweak "Disable QoS Reserved" "NETWORK" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" "NonBestEffortLimit" 0 }
Add-Tweak "TcpAckFrequency" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpAckFrequency" 1 }
Add-Tweak "TCPNoDelay" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TCPNoDelay" 1 }
Add-Tweak "TcpDelAckTicks" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpDelAckTicks" 0 }
Add-Tweak "Disable TCP Auto-Tuning" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableAutoTuning" 1 }
Add-Tweak "MaxUserPort" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "MaxUserPort" 65534 }
Add-Tweak "TcpTimedWaitDelay" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpTimedWaitDelay" 30 }
Add-Tweak "Disable IPv6" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0xff }
Add-Tweak "Disable Net Discovery" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" "NewNetworkWindowOff" 1 }
Add-Tweak "Disable File Sharing" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer" "Start" 4 }
Add-Tweak "Disable Net Bridge" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\BridgeMP" "Start" 4 }
Add-Tweak "Disable Media Sharing" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" "Start" 4 }
Add-Tweak "Disable ICS" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess" "Start" 4 }
Add-Tweak "Disable WebClient" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WebClient" "Start" 4 }
Add-Tweak "Disable iphlpsvc" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\iphlpsvc" "Start" 4 }
Add-Tweak "Disable Dnscache" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache" "Start" 4 }
Add-Tweak "Disable Netlogon" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" "Start" 4 }

# ---- SERVICES (20) ----
$svcList = @("DiagTrack","dmwappushservice","Fax","RemoteRegistry","RetailDemo","MapsBroker","WSearch","PrintSpooler","WerSvc","PcaSvc","WdiServiceHost","WdiSystemHost","TrkWks","WpnService","WpnUserService","lfsvc","PhoneSvc","SensorService","SensrSvc","SSDPSRV")
foreach ($svc in $svcList) {
    $svcLocal = $svc
    $action = {
        $s = Get-Service -Name $svcLocal -ErrorAction SilentlyContinue
        if ($s) { Stop-Service -Name $svcLocal -Force -ErrorAction SilentlyContinue; Set-Service -Name $svcLocal -StartupType Disabled -ErrorAction SilentlyContinue }
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\$svcLocal" "Start" 4
    }.GetNewClosure()
    Add-Tweak "Disable Svc: $svcLocal" "SERVICES" $action
}

Add-Tweak "Disable Telemetry" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0 }
Add-Tweak "Disable Cortana" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0 }
Add-Tweak "Disable Web Search" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1 }
Add-Tweak "Disable Advertising ID" "SERVICES" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0 }
Add-Tweak "Disable Feedback" "SERVICES" { Set-Reg "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0 }
Add-Tweak "Disable Diagnostics" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\Performance" "Disabled" 1 }
Add-Tweak "Disable Error Reporting" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" 1 }
Add-Tweak "Disable CEIP" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Microsoft\SQMClient\Windows" "CEIPEnable" 0 }
Add-Tweak "Disable Activity History" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0 }
Add-Tweak "Disable Timeline" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0 }
Add-Tweak "Disable Clipboard Sync" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowClipboardHistory" 0 }
Add-Tweak "Disable Cloud Sync" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" "DisableSettingSync" 2 }
Add-Tweak "Disable Location" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny" "String" }
Add-Tweak "Disable Camera" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" "Value" "Deny" "String" }
Add-Tweak "Disable Microphone" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" "Value" "Deny" "String" }
Add-Tweak "Disable Bluetooth" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters" "DisableBluetooth" 1 }
Add-Tweak "Disable Hyper-V" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\vmcompute" "Start" 4 }
Add-Tweak "Disable WSL" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LxssManager" "Start" 4 }
Add-Tweak "Disable Sandbox" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\Sandbox" "AllowSandbox" 0 }
Add-Tweak "Disable Defender" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" 1 }

# ==========================================
# SYSTEM INFO
# ==========================================
$cpu = (Get-CimInstance Win32_Processor).Name
$cpuSpeed = "{0:N2} GHz" -f ((Get-CimInstance Win32_Processor).MaxClockSpeed / 1000)
$gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$ram = "{0:N2} GB" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$os = (Get-CimInstance Win32_OperatingSystem).Caption -replace "Microsoft ", ""
$totalTweaks = $script:AllTweaks.Count

# ==========================================
# UI
# ==========================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "APEX SHOP V3"
$form.Size = New-Object System.Drawing.Size(1300, 800)
$form.MinimumSize = New-Object System.Drawing.Size(1100, 700)
$form.BackColor = $colBgDark
$form.ForeColor = $colGreen
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Sizable"
$form.MaximizeBox = $true

$header = New-Object System.Windows.Forms.Label
$header.Text = "APEX SHOP V3"
$header.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = $colGreen
$header.BackColor = $colBgDark
$header.Size = New-Object System.Drawing.Size(400, 60)
$header.Location = New-Object System.Drawing.Point(20, 10)
$header.Anchor = "Top, Left"
$form.Controls.Add($header)

$infoPanel = New-Object System.Windows.Forms.Panel
$infoPanel.BackColor = $colBgPanel
$infoPanel.Size = New-Object System.Drawing.Size(840, 80)
$infoPanel.Location = New-Object System.Drawing.Point(440, 10)
$infoPanel.Anchor = "Top, Right"
$form.Controls.Add($infoPanel)

$lblInfo = New-Object System.Windows.Forms.Label
$lblInfo.Text = "CPU: $cpu`nCPU Speed: $cpuSpeed`nGPU: $gpu`nRAM: $ram | OS: $os"
$lblInfo.Font = New-Object System.Drawing.Font("Consolas", 10)
$lblInfo.ForeColor = $colTextGray
$lblInfo.BackColor = $colBgPanel
$lblInfo.Size = New-Object System.Drawing.Size(820, 75)
$lblInfo.Location = New-Object System.Drawing.Point(10, 5)
$lblInfo.Anchor = "Top, Left, Right"
$infoPanel.Controls.Add($lblInfo)

$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.BackColor = $colBgPanel
$sidebar.Size = New-Object System.Drawing.Size(200, 600)
$sidebar.Location = New-Object System.Drawing.Point(20, 90)
$sidebar.Anchor = "Top, Left, Bottom"
$form.Controls.Add($sidebar)

$categories = @("GAMING", "CPU & RAM", "VISUAL", "NETWORK", "SERVICES")
$catButtons = @()
$y = 10
foreach ($cat in $categories) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $cat
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $btn.ForeColor = $colTextGray
    $btn.BackColor = $colBgPanel
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.Size = New-Object System.Drawing.Size(180, 50)
    $btn.Location = New-Object System.Drawing.Point(10, $y)
    $btn.TextAlign = "MiddleLeft"
    $btn.Padding = New-Object System.Windows.Forms.Padding(15, 0, 0, 0)
    $btn.Tag = $cat
    $sidebar.Controls.Add($btn)
    $catButtons += $btn
    $y += 60
}

$list = New-Object System.Windows.Forms.CheckedListBox
$list.BackColor = $colBgList
$list.ForeColor = $colGreen
$list.Font = New-Object System.Drawing.Font("Consolas", 10)
$list.CheckOnClick = $true
$list.Size = New-Object System.Drawing.Size(1040, 600)
$list.Location = New-Object System.Drawing.Point(240, 90)
$list.BorderStyle = "FixedSingle"
$list.Anchor = "Top, Bottom, Left, Right"
$form.Controls.Add($list)

$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.BackColor = $colBgDark
$bottomPanel.Size = New-Object System.Drawing.Size(1260, 70)
$bottomPanel.Location = New-Object System.Drawing.Point(20, 700)
$bottomPanel.Anchor = "Bottom, Left, Right"
$form.Controls.Add($bottomPanel)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Total Tweaks: $totalTweaks | Selected: 0"
$status.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$status.ForeColor = $colGreen
$status.BackColor = $colBgDark
$status.Size = New-Object System.Drawing.Size(400, 30)
$status.Location = New-Object System.Drawing.Point(10, 20)
$status.Anchor = "Left"
$bottomPanel.Controls.Add($status)

function Add-HoverEffect {
    param($Button, $NormalColor, $HoverColor)
    $Button.Add_MouseEnter({ $this.BackColor = $HoverColor }.GetNewClosure())
    $Button.Add_MouseLeave({ $this.BackColor = $NormalColor }.GetNewClosure())
}

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = "APPLY"
$btnApply.BackColor = $colGreen
$btnApply.ForeColor = $colBgDark
$btnApply.FlatStyle = "Flat"
$btnApply.FlatAppearance.BorderSize = 0
$btnApply.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnApply.Size = New-Object System.Drawing.Size(120, 45)
$btnApply.Location = New-Object System.Drawing.Point(1130, 12)
$btnApply.Anchor = "Right"
$bottomPanel.Controls.Add($btnApply)
Add-HoverEffect -Button $btnApply -NormalColor $colGreen -HoverColor $colGreenDark

$btnReset = New-Object System.Windows.Forms.Button
$btnReset.Text = "RESET"
$btnReset.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$btnReset.ForeColor = $colRed
$btnReset.FlatStyle = "Flat"
$btnReset.FlatAppearance.BorderSize = 0
$btnReset.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnReset.Size = New-Object System.Drawing.Size(80, 45)
$btnReset.Location = New-Object System.Drawing.Point(1040, 12)
$btnReset.Anchor = "Right"
$bottomPanel.Controls.Add($btnReset)
Add-HoverEffect -Button $btnReset -NormalColor ([System.Drawing.Color]::FromArgb(40, 40, 40)) -HoverColor ([System.Drawing.Color]::FromArgb(60, 20, 20))

$btnRestore = New-Object System.Windows.Forms.Button
$btnRestore.Text = "RESTORE POINT"
$btnRestore.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$btnRestore.ForeColor = $colTextGray
$btnRestore.FlatStyle = "Flat"
$btnRestore.FlatAppearance.BorderSize = 0
$btnRestore.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnRestore.Size = New-Object System.Drawing.Size(140, 45)
$btnRestore.Location = New-Object System.Drawing.Point(890, 12)
$btnRestore.Anchor = "Right"
$bottomPanel.Controls.Add($btnRestore)
Add-HoverEffect -Button $btnRestore -NormalColor ([System.Drawing.Color]::FromArgb(40, 40, 40)) -HoverColor ([System.Drawing.Color]::FromArgb(60, 60, 60))

$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Text = "SELECT ALL"
$btnSelectAll.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$btnSelectAll.ForeColor = $colGreen
$btnSelectAll.FlatStyle = "Flat"
$btnSelectAll.FlatAppearance.BorderSize = 0
$btnSelectAll.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnSelectAll.Size = New-Object System.Drawing.Size(140, 45)
$btnSelectAll.Location = New-Object System.Drawing.Point(740, 12)
$btnSelectAll.Anchor = "Right"
$bottomPanel.Controls.Add($btnSelectAll)
Add-HoverEffect -Button $btnSelectAll -NormalColor ([System.Drawing.Color]::FromArgb(40, 40, 40)) -HoverColor ([System.Drawing.Color]::FromArgb(60, 60, 60))

$btnDeselectAll = New-Object System.Windows.Forms.Button
$btnDeselectAll.Text = "DESELECT ALL"
$btnDeselectAll.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$btnDeselectAll.ForeColor = $colGreen
$btnDeselectAll.FlatStyle = "Flat"
$btnDeselectAll.FlatAppearance.BorderSize = 0
$btnDeselectAll.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnDeselectAll.Size = New-Object System.Drawing.Size(150, 45)
$btnDeselectAll.Location = New-Object System.Drawing.Point(580, 12)
$btnDeselectAll.Anchor = "Right"
$bottomPanel.Controls.Add($btnDeselectAll)
Add-HoverEffect -Button $btnDeselectAll -NormalColor ([System.Drawing.Color]::FromArgb(40, 40, 40)) -HoverColor ([System.Drawing.Color]::FromArgb(60, 60, 60))

# UI Logic
$script:CurrentCategory = ""

function Update-Status {
    $checkedCount = ($script:AllTweaks | Where-Object { $_.Checked -eq $true }).Count
    $status.Text = "Total Tweaks: $totalTweaks | Selected: $checkedCount"
}

function Load-Category {
    param($cat)
    for ($i = 0; $i -lt $list.Items.Count; $i++) {
        $itemText = $list.Items[$i].ToString()
        $isChecked = $list.GetItemChecked($i)
        $tweak = $script:AllTweaks | Where-Object { $_.Name -eq $itemText -and $_.Category -eq $script:CurrentCategory } | Select-Object -First 1
        if ($tweak) { $tweak.Checked = $isChecked }
    }
    $list.Items.Clear()
    foreach ($t in $script:AllTweaks) {
        if ($t.Category -eq $cat) { [void]$list.Items.Add($t.Name, $t.Checked) }
    }
    $script:CurrentCategory = $cat
    foreach ($btn in $catButtons) {
        if ($btn.Tag -eq $cat) { $btn.ForeColor = $colGreen; $btn.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35) }
        else { $btn.ForeColor = $colTextGray; $btn.BackColor = $colBgPanel }
    }
    Update-Status
}

foreach ($btn in $catButtons) { $btn.Add_Click({ Load-Category $this.Tag }) }

$list.Add_ItemCheck({
    Start-Sleep -Milliseconds 10
    if ($list.SelectedIndex -ge 0) {
        $script:AllTweaks | Where-Object { $_.Name -eq $list.Items[$list.SelectedIndex].ToString() -and $_.Category -eq $script:CurrentCategory } | ForEach-Object { $_.Checked = $list.GetItemChecked($list.SelectedIndex) }
    }
    Update-Status
})

$btnSelectAll.Add_Click({
    $script:AllTweaks | ForEach-Object { $_.Checked = $true }
    for ($i = 0; $i -lt $list.Items.Count; $i++) { $list.SetItemChecked($i, $true) }
    Update-Status
})

$btnDeselectAll.Add_Click({
    $script:AllTweaks | ForEach-Object { $_.Checked = $false }
    for ($i = 0; $i -lt $list.Items.Count; $i++) { $list.SetItemChecked($i, $false) }
    Update-Status
})

$btnReset.Add_Click({
    $script:AllTweaks | ForEach-Object { $_.Checked = $false }
    for ($i = 0; $i -lt $list.Items.Count; $i++) { $list.SetItemChecked($i, $false) }
    Update-Status
})

$btnRestore.Add_Click({
    try {
        Enable-ComputerRestore -Drive "C:\"
        Checkpoint-Computer -Description "APEX SHOP V3" -RestorePointType "MODIFY_SETTINGS"
        [System.Windows.Forms.MessageBox]::Show("Restore Point created", "APEX SHOP V3", "OK", "Information")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed: $($_.Exception.Message)", "APEX SHOP V3", "OK", "Error")
    }
})

$btnApply.Add_Click({
    $checked = $script:AllTweaks | Where-Object { $_.Checked -eq $true }
    if ($checked.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No tweaks selected", "APEX SHOP V3", "OK", "Information")
        return
    }
    $confirm = [System.Windows.Forms.MessageBox]::Show("Apply $($checked.Count) tweaks?", "APEX SHOP V3", "YesNo", "Warning")
    if ($confirm -ne "Yes") { return }
    
    $log = New-Object System.Text.StringBuilder
    [void]$log.AppendLine("Applying $($checked.Count) tweaks...")
    foreach ($t in $checked) {
        try { & $t.Action; [void]$log.AppendLine("OK: $($t.Name)") }
        catch { [void]$log.AppendLine("FAIL: $($t.Name)") }
    }
    [void]$log.AppendLine("Done. Reboot recommended.")
    [System.Windows.Forms.MessageBox]::Show($log.ToString(), "APEX SHOP V3", "OK", "Information")
})

Load-Category "GAMING"

$form.Add_Shown({ $form.Activate() })
$form.Add_FormClosing({ Stop-LicenseHeartbeat })
[void]$form.ShowDialog()

# ---- ตรวจสอบ Execution Time ----
$script:StartTime.Stop()
if ($script:StartTime.ElapsedMilliseconds -gt 60000) {
    Write-Host "[Security] Abnormal execution time" -ForegroundColor Red
}


