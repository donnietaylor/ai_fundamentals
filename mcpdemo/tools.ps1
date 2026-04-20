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

# --- Dispatch ---
$result = switch ($Action) {
    "list_files"       { List-Files -TargetPath $Path }
    "get_file_content" { Get-FileContent -FilePath $Path }
    "get_os_data"      { Get-OSData }
    "search_files"     { Search-Files -TargetPath $Path -SearchQuery $Query }
    default            { @{ error = "Unknown action: $Action" } }
}

# Output as JSON
$result | ConvertTo-Json -Depth 5 -Compress
