# tweaks_extra.ps1 - Additional Tweaks (No Network)
# GAMING 20 + CPU/RAM 10 + VISUAL 10 + SERVICES 12 = 52

# ---- GAMING EXTRA (20) ----
Add-Tweak "Disable Xbox Monitoring" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\XboxGipSvc" "Start" 4 }
Add-Tweak "Disable Xbox Live Auth 2" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\XblAuthManager" "Start" 4 }
Add-Tweak "Disable Game Bar Widgets" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "WidgetsEnabled" 0 }
Add-Tweak "Disable Game Bar Screenshot" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "ScreenshotEnabled" 0 }
Add-Tweak "Disable Game Bar Record 2" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "RecordingEnabled" 0 }
Add-Tweak "Disable Game Bar Broadcast 2" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "BroadcastEnabled" 0 }
Add-Tweak "Disable Game Bar Stream 2" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "StreamingEnabled" 0 }
Add-Tweak "Disable Game Bar Social 2" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "SocialEnabled" 0 }
Add-Tweak "Disable Game Bar Gallery" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "GalleryEnabled" 0 }
Add-Tweak "Disable Game Bar Home" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "HomeEnabled" 0 }
Add-Tweak "Disable Game Bar Tour" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "TourEnabled" 0 }
Add-Tweak "Disable Game Bar Tips 2" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "TipsEnabled" 0 }
Add-Tweak "Disable Game Bar Updates" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "UpdatesEnabled" 0 }
Add-Tweak "Disable Game Bar Audio 2" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AudioCaptureEnabled" 0 }
Add-Tweak "Set GPU Priority Max" "GAMING" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "GPU Priority" 8 }
Add-Tweak "Set Scheduling Category 2" "GAMING" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "Scheduling Category" "High" }
Add-Tweak "Set HwSchMode On" "GAMING" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 1 }
Add-Tweak "Set DirectX User Settings" "GAMING" { Set-Reg "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" "DirectXUserGlobalSettings" "VRROptimizeEnable=0;SwapEffectUpgradeEnable=0;" "String" }
Add-Tweak "Disable FSE Behavior" "GAMING" { Set-Reg "HKCU:\System\GameConfigStore" "GameDVR_FSEBehaviorMode" 2 }
Add-Tweak "Disable DXGI FSE" "GAMING" { Set-Reg "HKCU:\System\GameConfigStore" "GameDVR_DXGIHonorFSEWindowsCompatible" 1 }

# ---- CPU & RAM EXTRA (10) ----
Add-Tweak "Set Large System Cache 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache" 1 }
Add-Tweak "Set IoPageLockLimit 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "IoPageLockLimit" 0x10000 }
Add-Tweak "Disable Heap Decomp 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1 }
Add-Tweak "Set Second Level Cache 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SecondLevelDataCache" 1024 }
Add-Tweak "Set Memory Priority 5" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "MemoryPriority" 5 }
Add-Tweak "Disable NTFS Last Access 2" "CPU & RAM" { fsutil behavior set disablelastaccess 1 | Out-Null }
Add-Tweak "Set MFT Zone Reservation" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "NtfsMftZoneReservation" 2 }
Add-Tweak "Disable 8.3 Names 2" "CPU & RAM" { fsutil behavior set disable8dot3 1 | Out-Null }
Add-Tweak "Set NTFS Memory Usage 2" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "NtfsMemoryUsage" 2 }
Add-Tweak "Set Session Pool" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "SessionPoolSize" 32 }

# ---- VISUAL EXTRA (10) ----
Add-Tweak "Disable Taskbar Transparency 2" "VISUAL" { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 }
Add-Tweak "Disable Start Web Search" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0 }
Add-Tweak "Disable Cortana Consent" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "CortanaConsent" 0 }
Add-Tweak "Disable Taskbar News" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2 }
Add-Tweak "Disable Window Snapping 2" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "WindowArrangementActive" "0" "String" }
Add-Tweak "Disable Snap Assist 2" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssist" 0 }
Add-Tweak "Disable Snap Assist Corner" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssistCorner" 0 }
Add-Tweak "Disable Snap Assist DND" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssistDoNotDisturb" 0 }
Add-Tweak "Disable Last Access Time" "VISUAL" { fsutil behavior set disablelastaccess 1 | Out-Null }
Add-Tweak "Disable Ink Workspace" "VISUAL" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowWindowsInkWorkspace" 0 }

# ---- SERVICES EXTRA (12) ----
Add-Tweak "Disable WMPNetworkSvc 2" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" "Start" 4 }
Add-Tweak "Disable WinRM" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WinRM" "Start" 4 }
Add-Tweak "Disable icssvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\icssvc" "Start" 4 }
Add-Tweak "Disable TapiSrv" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\TapiSrv" "Start" 4 }
Add-Tweak "Disable RpcLocator" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\RpcLocator" "Start" 4 }
Add-Tweak "Disable seclogon" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\seclogon" "Start" 4 }
Add-Tweak "Disable SNMPTRAP" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SNMPTRAP" "Start" 4 }
Add-Tweak "Disable smphost" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\smphost" "Start" 4 }
Add-Tweak "Disable stisvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\stisvc" "Start" 4 }
Add-Tweak "Disable wuauserv" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\wuauserv" "Start" 4 }
Add-Tweak "Disable BITS" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\BITS" "Start" 4 }
Add-Tweak "Disable CryptSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\CryptSvc" "Start" 4 }
