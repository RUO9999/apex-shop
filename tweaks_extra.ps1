# tweaks.ps1 - 250 Tweaks for APEX SHOP V3

# ---- GAMING (50) ----
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

# ---- CPU & RAM (50) ----
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
Add-Tweak "Disable Paging Executive 3" "CPU & RAM" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" 1 }

# ---- VISUAL (50) ----
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
Add-Tweak "Disable Taskbar Transparency 2" "VISUAL" { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 }
Add-Tweak "Disable Start Web Search" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0 }
Add-Tweak "Disable Cortana Consent" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "CortanaConsent" 0 }
Add-Tweak "Disable Taskbar News" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2 }
Add-Tweak "Disable Window Snapping 2" "VISUAL" { Set-Reg "HKCU:\Control Panel\Desktop" "WindowArrangementActive" "0" "String" }
Add-Tweak "Disable Snap Assist 2" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssist" 0 }
Add-Tweak "Disable Snap Assist Corner" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssistCorner" 0 }
Add-Tweak "Disable Snap Assist DND" "VISUAL" { Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssistDoNotDisturb" 0 }
Add-Tweak "Disable Ink Workspace" "VISUAL" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowWindowsInkWorkspace" 0 }

# ---- NETWORK (50) ----
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
Add-Tweak "Set TcpAckFrequency Global" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpAckFrequency" 1 }
Add-Tweak "Set TCPNoDelay Global" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TCPNoDelay" 1 }
Add-Tweak "Set TcpDelAckTicks Global" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpDelAckTicks" 0 }
Add-Tweak "Disable Auto Tuning 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableAutoTuning" 1 }
Add-Tweak "Disable Network Bridge 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\BridgeMP" "Start" 4 }
Add-Tweak "Disable IPv6 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0xff }
Add-Tweak "Disable Net Discovery 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" "NewNetworkWindowOff" 1 }
Add-Tweak "Disable SSDP" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SSDPSRV" "Start" 4 }
Add-Tweak "Disable UPnP" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\upnphost" "Start" 4 }
Add-Tweak "Disable WebDAV" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WebClient" "Start" 4 }
Add-Tweak "Disable NetBIOS" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT" "Start" 4 }
Add-Tweak "Disable TCP Chimney" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableTaskOffload" 1 }
Add-Tweak "Disable RSS" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableRSS" 0 }
Add-Tweak "Disable ECN" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableTCPA" 0 }
Add-Tweak "Disable IPv4 Src Route" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableIPSourceRouting" 2 }
Add-Tweak "Disable TCP Timestamps" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "Tcp1323Opts" 0 }
Add-Tweak "Disable Net Throttling 2" "NETWORK" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff }
Add-Tweak "Set Sys Responsiveness 2" "NETWORK" { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 0 }
Add-Tweak "Disable Nagle 2" "NETWORK" { $i=Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"; foreach($x in $i){ Set-Reg $x.PSPath "TcpAckFrequency" 1; Set-Reg $x.PSPath "TCPNoDelay" 1; Set-Reg $x.PSPath "TcpDelAckTicks" 0 } }
Add-Tweak "Disable QoS Reserved 2" "NETWORK" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" "NonBestEffortLimit" 0 }
Add-Tweak "Set Max User Port" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "MaxUserPort" 65534 }
Add-Tweak "Set Tcp Timed Wait" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpTimedWaitDelay" 30 }
Add-Tweak "Disable File Sharing 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer" "Start" 4 }
Add-Tweak "Disable Media Sharing 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" "Start" 4 }
Add-Tweak "Disable ICS 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess" "Start" 4 }
Add-Tweak "Disable iphlpsvc 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\iphlpsvc" "Start" 4 }
Add-Tweak "Disable Dnscache 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache" "Start" 4 }
Add-Tweak "Disable Netlogon 2" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" "Start" 4 }
Add-Tweak "Disable SMB Direct" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SmbDirect" "Start" 4 }
Add-Tweak "Disable LLDP" "NETWORK" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\lltdsvc" "Start" 4 }

# ---- SERVICES (50) ----
Add-Tweak "Disable DiagTrack" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack" "Start" 4 }
Add-Tweak "Disable dmwappush" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" "Start" 4 }
Add-Tweak "Disable Fax" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Fax" "Start" 4 }
Add-Tweak "Disable RemoteRegistry" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\RemoteRegistry" "Start" 4 }
Add-Tweak "Disable RetailDemo" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\RetailDemo" "Start" 4 }
Add-Tweak "Disable MapsBroker" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\MapsBroker" "Start" 4 }
Add-Tweak "Disable WSearch" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" "Start" 4 }
Add-Tweak "Disable PrintSpooler" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\PrintSpooler" "Start" 4 }
Add-Tweak "Disable WerSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WerSvc" "Start" 4 }
Add-Tweak "Disable PcaSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\PcaSvc" "Start" 4 }
Add-Tweak "Disable WdiServiceHost" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WdiServiceHost" "Start" 4 }
Add-Tweak "Disable WdiSystemHost" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WdiSystemHost" "Start" 4 }
Add-Tweak "Disable TrkWks" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\TrkWks" "Start" 4 }
Add-Tweak "Disable WpnService" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WpnService" "Start" 4 }
Add-Tweak "Disable WpnUserService" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WpnUserService" "Start" 4 }
Add-Tweak "Disable lfsvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc" "Start" 4 }
Add-Tweak "Disable PhoneSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\PhoneSvc" "Start" 4 }
Add-Tweak "Disable SensorService" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SensorService" "Start" 4 }
Add-Tweak "Disable SensrSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SensrSvc" "Start" 4 }
Add-Tweak "Disable SSDPSRV" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SSDPSRV" "Start" 4 }
Add-Tweak "Disable WMPNetworkSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WMPNetworkSvc" "Start" 4 }
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
Add-Tweak "Disable msiserver" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\msiserver" "Start" 4 }
Add-Tweak "Disable VSS" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\VSS" "Start" 4 }
Add-Tweak "Disable swprv" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\swprv" "Start" 4 }
Add-Tweak "Disable defragsvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\defragsvc" "Start" 4 }
Add-Tweak "Disable WbioSrvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WbioSrvc" "Start" 4 }
Add-Tweak "Disable wcncsvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\wcncsvc" "Start" 4 }
Add-Tweak "Disable WpcMonSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WpcMonSvc" "Start" 4 }
Add-Tweak "Disable WPDBusEnum" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\WPDBusEnum" "Start" 4 }
Add-Tweak "Disable COMSysApp" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\COMSysApp" "Start" 4 }
Add-Tweak "Disable SDRSVC" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SDRSVC" "Start" 4 }
Add-Tweak "Disable Wbengine" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Wbengine" "Start" 4 }
Add-Tweak "Disable SstpSvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SstpSvc" "Start" 4 }
Add-Tweak "Disable wudfsvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\wudfsvc" "Start" 4 }
Add-Tweak "Disable SCPolicySvc" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SCPolicySvc" "Start" 4 }
Add-Tweak "Disable Themes" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Themes" "Start" 4 }
Add-Tweak "Disable FontCache" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\FontCache" "Start" 4 }
Add-Tweak "Disable Bluetooth" "SERVICES" { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters" "DisableBluetooth" 1 }
Add-Tweak "Disable Defender" "SERVICES" { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" 1 }