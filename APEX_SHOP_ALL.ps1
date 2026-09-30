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
# GLOBALS & COLORS
# ==========================================
$script:LicenseServer = "http://localhost:8090"
$script:LicenseCacheFile = "$env:APPDATA\ApexShop\license_cache.json"
$script:CacheDays = 7
$script:HeartbeatTimer = $null
$script:LicenseRevoked = $false
$script:HeartbeatBusy = $false
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
    Write-Host "[TimeSkew] Client: $clientTime | Server: $ServerTime | Diff: $diff" -ForegroundColor DarkGray
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
    
    Write-Host "[Signature] Match: $($expected -eq $Signature) | Msg: $msg" -ForegroundColor $(if ($expected -eq $Signature) { "Green" } else { "Red" })
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

function Start-LicenseHeartbeat {
    param([int]$IntervalMs = 10000)
    if ($script:HeartbeatTimer) { $script:HeartbeatTimer.Dispose() }
    
    $script:HeartbeatTimer = New-Object System.Threading.Timer(
        [System.Threading.TimerCallback]{
            param($state)
            if ($script:LicenseRevoked -or $script:HeartbeatBusy) { return }
            $script:HeartbeatBusy = $true
            try {
                $cache = Get-CachedLicense
                if (-not $cache) { return }
                $result = Test-LicenseKey -Key $cache.key -HWID (Get-HWID)
                if (-not $result.valid -and $result.reason -ne "Server unreachable") {
                    $script:LicenseRevoked = $true
                    Write-Host "[License] REVOKED: $($result.reason)" -ForegroundColor Red
                    if ($script:MainForm -and $script:MainForm.IsHandleCreated) {
                        try {
                            $script:MainForm.Invoke([Action]{
                                [System.Windows.Forms.MessageBox]::Show("License revoked: $($result.reason)", "APEX SHOP V3", "OK", "Error") | Out-Null
                                [System.Windows.Forms.Application]::Exit()
                            })
                        } catch { }
                    }
                }
            } catch { } finally { $script:HeartbeatBusy = $false }
        },
        $null, $IntervalMs, $IntervalMs
    )
    Write-Host "[License] Heartbeat ON (background, ${IntervalMs}ms)" -ForegroundColor Green
}

function Stop-LicenseHeartbeat {
    if ($script:HeartbeatTimer) { $script:HeartbeatTimer.Dispose(); $script:HeartbeatTimer = $null }
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
    Write-Host "[Security] Debugger detected" -ForegroundColor Red
    exit
}

# ==========================================
# RUN LICENSE CHECK
# ==========================================
if (-not (Confirm-License)) {
    [System.Windows.Forms.MessageBox]::Show("Invalid License", "APEX SHOP V3", "OK", "Error")
    exit
}
Start-LicenseHeartbeat -IntervalMs 10000

# ==========================================
# TWEAK DATABASE
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
