# APEX SHOP V3 - Main (UI + License) - No Network
# Tweaks loaded from tweaks_extra.ps1

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
# GLOBALS & COLORS
# ==========================================
$script:LicenseServer = "http://localhost:8090"
$script:LicenseCacheFile = "$env:APPDATA\ApexShop\license_cache.json"
$script:CacheDays = 7
$script:HeartbeatTimer = $null
$script:LicenseRevoked = $false
$script:HeartbeatBusy = $false
$script:HeartbeatFails = 0
$script:MainForm = $null
$script:ServerSecret = "APEX-SHOP-SERVER-KEY-7f3a9b2c4d8e1f6a-2026-CHANGE-ME"

$colBgDark = [System.Drawing.Color]::FromArgb(12, 12, 12)
$colBgPanel = [System.Drawing.Color]::FromArgb(22, 22, 22)
$colBgList = [System.Drawing.Color]::FromArgb(18, 18, 18)
$colGreen = [System.Drawing.Color]::FromArgb(0, 255, 100)
$colGreenDark = [System.Drawing.Color]::FromArgb(0, 180, 70)
$colRed = [System.Drawing.Color]::FromArgb(255, 80, 80)
$colTextGray = [System.Drawing.Color]::FromArgb(160, 160, 160)
$colYellow = [System.Drawing.Color]::FromArgb(255, 200, 0)

# ==========================================
# LICENSE FUNCTIONS
# ==========================================
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
        if (([DateTime]::Now - $cachedTime).TotalDays -gt $script:CacheDays) { return $null }
        if ($cache.hwid -ne (Get-HWID)) { return $null }
        return $cache
    } catch { return $null }
}

function Save-LicenseCache {
    param($Key, $DaysLeft)
    $dir = Split-Path $script:LicenseCacheFile -Parent
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
    @{ key = $Key; hwid = (Get-HWID); days_left = $DaysLeft; timestamp = [DateTime]::Now.ToString("o") } | ConvertTo-Json | Set-Content $script:LicenseCacheFile -Encoding UTF8
}

function Test-TimeSkew {
    param([long]$ServerTime)
    $clientTime = [long]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
    $diff = [Math]::Abs($clientTime - $ServerTime)
    Write-Host "[TimeSkew] Diff: $diff" -ForegroundColor DarkGray
    return ($diff -gt 86400)
}

function Test-ResponseSignature {
    param($Data, $Signature)
    $validStr = if ($Data.valid -eq $true -or "$($Data.valid)" -eq "True" -or "$($Data.valid)" -eq "1") { "1" } else { "0" }
    $daysStr = [string][int]$Data.days_left
    $noteStr = if ($null -eq $Data.note) { "" } else { [string]$Data.note }
    $nonceStr = [string]$Data.nonce
    $timeStr = [string][long]$Data.server_time
    $msg = "$validStr|$daysStr|$noteStr|$nonceStr|$timeStr"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($script:ServerSecret)
    $hash = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($msg))
    $expected = [System.BitConverter]::ToString($hash).Replace("-","").ToLower()
    Write-Host "[Signature] Match: $($expected -eq $Signature)" -ForegroundColor $(if ($expected -eq $Signature) { "Green" } else { "Red" })
    return $expected -eq $Signature
}

function Test-LicenseKey {
    param([string]$Key, [string]$HWID)
    try {
        $clientTime = [long]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
        $body = @{ license_key = $Key; hwid = $HWID; client_time = $clientTime } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$script:LicenseServer/api/validate" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
        if (-not $response.data -or -not $response.sig) { return @{ valid = $false; reason = "Malformed response" } }
        if (-not (Test-ResponseSignature -Data $response.data -Signature $response.sig)) { return @{ valid = $false; reason = "Invalid signature" } }
        if ($response.data.server_time -and (Test-TimeSkew -ServerTime $response.data.server_time)) { return @{ valid = $false; reason = "Time mismatch" } }
        return @{ valid = $response.data.valid; days_left = $response.data.days_left; note = $response.data.note }
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

    $script:keyInput.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { $btnOk.PerformClick() } })
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

# ==========================================
# SAFE HEARTBEAT (No-Kill Mode)
# ==========================================
function Start-LicenseHeartbeat {
    param([int]$IntervalMs = 60000)
    if ($script:HeartbeatTimer) { $script:HeartbeatTimer.Dispose() }
    $script:HeartbeatTimer = New-Object System.Threading.Timer(
        [System.Threading.TimerCallback]{
            param($state)
            try {
                if ($script:HeartbeatBusy) { return }
                $script:HeartbeatBusy = $true
                try {
                    $cache = Get-CachedLicense
                    if (-not $cache) { return }
                    $result = Test-LicenseKey -Key $cache.key -HWID (Get-HWID)
                    if (-not $result.valid -and $result.reason -ne "Server unreachable") {
                        Write-Host "[License] Warning: $($result.reason)" -ForegroundColor Yellow
                    }
                } catch { }
                finally { $script:HeartbeatBusy = $false }
            } catch { }
        },
        $null, $IntervalMs, $IntervalMs
    )
    Write-Host "[License] Heartbeat ON (${IntervalMs}ms, no-kill)" -ForegroundColor Green
}

function Stop-LicenseHeartbeat {
    try {
        if ($script:HeartbeatTimer) {
            $script:HeartbeatTimer.Dispose()
            $script:HeartbeatTimer = $null
            Write-Host "[License] Heartbeat stopped" -ForegroundColor Gray
        }
    } catch { }
}

# ==========================================
# ANTI-CRACK
# ==========================================
function Test-DebuggerPresent {
    $suspicious = @("x64dbg","ollydbg","ida","ida64","windbg","dnspy","cheatengine","processhacker","fiddler","charles","httpdebugger")
    try {
        $running = Get-Process -ErrorAction SilentlyContinue | Where-Object { $suspicious -contains $_.ProcessName.ToLower() }
        return ($running | Measure-Object).Count -gt 0
    } catch { return $false }
}

if (Test-DebuggerPresent) {
    Write-Host "[Security] Debugger detected - continuing anyway" -ForegroundColor Yellow
}

# ==========================================
# SET-REG & ADD-TWEAK
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

# ==========================================
# RUN LICENSE CHECK
# ==========================================
$licenseOk = $false
try { $licenseOk = Confirm-License } catch {
    Write-Host "[License] Error: $($_.Exception.Message)" -ForegroundColor Red
}
if (-not $licenseOk) {
    Write-Host "[License] Failed - Showing login" -ForegroundColor Yellow
    try { Show-LicenseLogin | Out-Null } catch { }
}
Start-LicenseHeartbeat -IntervalMs 60000

# ==========================================
# LOAD TWEAKS FROM GITHUB
# ==========================================
Write-Host "[Tweaks] Loading tweaks_extra.ps1 from GitHub..." -ForegroundColor Cyan
try {
    $tweaksUrl = "https://raw.githubusercontent.com/RUO9999/apex-shop/main/tweaks_extra.ps1?t=$(Get-Random)"
    $tweaksCode = (iwr -useb $tweaksUrl -TimeoutSec 15).Content
    Invoke-Expression $tweaksCode
    Write-Host "[Tweaks] Loaded: $($script:AllTweaks.Count) tweaks" -ForegroundColor Green
} catch {
    Write-Host "[Tweaks] FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[Tweaks] Continuing with empty list..." -ForegroundColor Yellow
    [System.Windows.Forms.MessageBox]::Show("Warning: Failed to load tweaks. Program will continue with empty list.", "APEX SHOP V3", "OK", "Warning") | Out-Null
}

$totalTweaks = $script:AllTweaks.Count

# ==========================================
# SYSTEM INFO
# ==========================================
$cpu = (Get-CimInstance Win32_Processor).Name
$cpuSpeed = "{0:N2} GHz" -f ((Get-CimInstance Win32_Processor).MaxClockSpeed / 1000)
$gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$ram = "{0:N2} GB" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$os = (Get-CimInstance Win32_OperatingSystem).Caption -replace "Microsoft ", ""

# ==========================================
# MAIN UI
# ==========================================
$form = New-Object System.Windows.Forms.Form
$script:MainForm = $form
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

# ⭐ ไม่มี NETWORK
$categories = @("GAMING", "CPU & RAM", "VISUAL", "SERVICES")
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
