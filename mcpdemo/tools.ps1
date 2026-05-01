# tools.ps1 — PowerShell backend for MCP tool calls
# Each function returns a hashtable that the Python MCP server serialises to JSON.

param(
    [Parameter(Mandatory)]
    [string]$Action,

    [string]$Path = ".",
    [string]$Query = ""
)

function List-Files {
    param([string]$TargetPath)
    if (-not (Test-Path $TargetPath)) {
        return @{ error = "Path not found: $TargetPath" }
    }
    $items = Get-ChildItem -Path $TargetPath -Force | Select-Object Name, Length,
        @{N='Type';E={if($_.PSIsContainer){'Directory'}else{'File'}}},
        LastWriteTime
    return @{ path = (Resolve-Path $TargetPath).Path; items = @($items) }
}

function Get-FileContent {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) {
        return @{ error = "File not found: $FilePath" }
    }
    if ((Get-Item $FilePath).PSIsContainer) {
        return @{ error = "Path is a directory, not a file: $FilePath" }
    }
    $size = (Get-Item $FilePath).Length
    if ($size -gt 1MB) {
        return @{ error = "File too large ($([math]::Round($size/1MB,2)) MB). Max 1 MB." }
    }
    $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
    return @{ file = (Resolve-Path $FilePath).Path; size = $size; content = $content }
}

function Get-OSData {
    $os   = Get-CimInstance Win32_OperatingSystem
    $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
            Select-Object DeviceID,
                @{N='SizeGB';E={[math]::Round($_.Size/1GB,1)}},
                @{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,1)}}

    return @{
        hostname     = $env:COMPUTERNAME
        os_name      = $os.Caption
        os_version   = $os.Version
        architecture = $os.OSArchitecture
        cpu          = $cpu.Name
        cores        = $cpu.NumberOfCores
        logical_cpus = $cpu.NumberOfLogicalProcessors
        total_ram_gb = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        free_ram_gb  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        disks        = @($disk)
        uptime       = ((Get-Date) - $os.LastBootUpTime).ToString()
    }
}

function Search-Files {
    param([string]$TargetPath, [string]$SearchQuery)
    if (-not (Test-Path $TargetPath)) {
        return @{ error = "Path not found: $TargetPath" }
    }
    $results = Get-ChildItem -Path $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*$SearchQuery*" } |
        Select-Object -First 50 FullName, Length, LastWriteTime
    return @{ query = $SearchQuery; root = (Resolve-Path $TargetPath).Path; matches = @($results) }
}

function Get-TopProcesses {
    param([int]$Top = 15)
    # Snapshot CPU usage by sampling twice, 1 second apart
    $sample1 = Get-Process | Select-Object Id, Name, CPU, WorkingSet64
    Start-Sleep -Milliseconds 800
    $sample2 = Get-Process | Select-Object Id, Name, CPU, WorkingSet64

    $s1Map = @{}
    foreach ($p in $sample1) { $s1Map[$p.Id] = $p.CPU }

    $results = $sample2 | ForEach-Object {
        $delta = if ($s1Map.ContainsKey($_.Id)) { [math]::Round(($_.CPU - $s1Map[$_.Id]) / 0.8 * 100) / 100 } else { 0 }
        [PSCustomObject]@{
            pid        = $_.Id
            name       = $_.Name
            cpu_delta  = $delta
            ram_mb     = [math]::Round($_.WorkingSet64 / 1MB, 1)
        }
    } | Sort-Object ram_mb -Descending | Select-Object -First $Top

    return @{ top = $Top; snapshot_interval_sec = 0.8; processes = @($results) }
}

function Get-NetworkInfo {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
        $adap = $_
        $ip = Get-NetIPAddress -InterfaceIndex $adap.InterfaceIndex -ErrorAction SilentlyContinue |
              Where-Object { $_.AddressFamily -in 'IPv4','IPv6' } |
              Select-Object AddressFamily, IPAddress, PrefixLength
        $gw = (Get-NetRoute -InterfaceIndex $adap.InterfaceIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
               Select-Object -First 1).NextHop
        $dns = (Get-DnsClientServerAddress -InterfaceIndex $adap.InterfaceIndex -ErrorAction SilentlyContinue |
                Where-Object { $_.ServerAddresses.Count -gt 0 } | Select-Object -First 1).ServerAddresses
        [PSCustomObject]@{
            name        = $adap.Name
            description = $adap.InterfaceDescription
            mac         = $adap.MacAddress
            speed_mbps  = [math]::Round($adap.LinkSpeed.ToString() -replace '[^0-9]','')
            addresses   = @($ip)
            gateway     = $gw
            dns_servers = @($dns)
        }
    }
    return @{ adapters = @($adapters) }
}

function Get-RunningServices {
    param([string]$StateFilter = "Running")
    $services = Get-Service |
        Where-Object { $StateFilter -eq "All" -or $_.Status -eq $StateFilter } |
        Select-Object Name, DisplayName, Status, StartType |
        Sort-Object DisplayName
    return @{ filter = $StateFilter; count = @($services).Count; services = @($services) }
}

function Get-EventLogErrors {
    param([int]$Hours = 24, [int]$MaxEntries = 30)
    $since = (Get-Date).AddHours(-$Hours)
    $entries = Get-WinEvent -FilterHashtable @{
        LogName   = 'System','Application'
        Level     = 1,2,3   # Critical, Error, Warning
        StartTime = $since
    } -MaxEvents $MaxEntries -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, LevelDisplayName, ProviderName, Id, Message |
    ForEach-Object {
        [PSCustomObject]@{
            time     = $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            level    = $_.LevelDisplayName
            source   = $_.ProviderName
            event_id = $_.Id
            message  = ($_.Message -replace "`r`n|`n", " " | Select-Object -First 1)
        }
    }
    return @{ hours_back = $Hours; count = @($entries).Count; events = @($entries) }
}

function Get-SecurityStatus {
    # Windows Defender / antivirus status
    $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
    $avStatus = if ($defender) {
        $defsUpdated = if ($defender.AntivirusSignatureLastUpdated) { $defender.AntivirusSignatureLastUpdated.ToString("yyyy-MM-dd") } else { "unknown" }
        $quickScan   = if ($defender.QuickScanEndTime -and $defender.QuickScanEndTime -gt [datetime]::MinValue) { $defender.QuickScanEndTime.ToString("yyyy-MM-dd HH:mm") } else { "never" }
        $fullScan    = if ($defender.FullScanEndTime  -and $defender.FullScanEndTime  -gt [datetime]::MinValue) { $defender.FullScanEndTime.ToString("yyyy-MM-dd HH:mm") }  else { "never" }
        @{
            enabled              = $defender.AntivirusEnabled
            realtime_protection  = $defender.RealTimeProtectionEnabled
            definitions_updated  = $defsUpdated
            definitions_version  = $defender.AntivirusSignatureVersion
            quick_scan_last      = $quickScan
            full_scan_last       = $fullScan
        }
    } else { @{ error = "Windows Defender status unavailable" } }

    # Firewall profiles
    $fw = Get-NetFirewallProfile -ErrorAction SilentlyContinue |
          Select-Object Name, Enabled

    # UAC status
    $uac = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ErrorAction SilentlyContinue).EnableLUA

    return @{
        windows_defender  = $avStatus
        firewall_profiles = @($fw)
        uac_enabled       = ($uac -eq 1)
    }
}

function Get-WindowsUpdates {
    param([int]$Days = 30)

    # Recently installed updates via CIM (Get-HotFix can hang on some systems)
    $installed = Get-CimInstance -ClassName Win32_QuickFixEngineering -ErrorAction SilentlyContinue |
        ForEach-Object {
            $installedOn = $null
            if ($_.InstalledOn) {
                try { $installedOn = ([datetime]$_.InstalledOn).ToString("yyyy-MM-dd") } catch { $installedOn = $_.InstalledOn.ToString() }
            }
            [PSCustomObject]@{
                kb          = $_.HotFixID
                description = $_.Description
                installed_on = $installedOn
                installed_by = $_.InstalledBy
            }
        } | Where-Object {
            if ($_.installed_on) {
                try { ([datetime]$_.installed_on) -ge (Get-Date).AddDays(-$Days) } catch { $true }
            } else { $true }
        } | Sort-Object installed_on -Descending | Select-Object -First 20

    # Pending updates via COM (works without admin)
    $pending = @()
    try {
        $session  = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $result   = $searcher.Search("IsInstalled=0 and IsHidden=0")
        $pending  = $result.Updates | ForEach-Object {
            [PSCustomObject]@{
                title    = $_.Title
                severity = $_.MsrcSeverity
                kb       = ($_.KBArticleIDs -join ', ')
            }
        }
    } catch { }

    return @{
        days_back           = $Days
        recently_installed  = @($installed)
        pending_count       = @($pending).Count
        pending_updates     = @($pending)
    }
}

# --- Dispatch ---
$result = switch ($Action) {
    "list_files"           { List-Files -TargetPath $Path }
    "get_file_content"     { Get-FileContent -FilePath $Path }
    "get_os_data"          { Get-OSData }
    "search_files"         { Search-Files -TargetPath $Path -SearchQuery $Query }
    "get_top_processes"    { $n = if ($Query -match '^\d+$') { [int]$Query } else { 15 }
                             Get-TopProcesses -Top $n }
    "get_network_info"     { Get-NetworkInfo }
    "get_running_services" { $f = if ($Query) { $Query } else { "Running" }
                             Get-RunningServices -StateFilter $f }
    "get_event_log"        { $h = if ($Query -match '^\d+$') { [int]$Query } else { 24 }
                             Get-EventLogErrors -Hours $h }
    "get_security_status"  { Get-SecurityStatus }
    "get_windows_updates"  { $d = if ($Query -match '^\d+$') { [int]$Query } else { 30 }
                             Get-WindowsUpdates -Days $d }
    default                { @{ error = "Unknown action: $Action" } }
}

# Output as JSON
$result | ConvertTo-Json -Depth 5 -Compress
