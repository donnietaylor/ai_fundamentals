# setup.ps1 — One-shot setup for the MCP demo
# Run: .\setup.ps1
# Requires: Internet access, admin not required (installs Python per-user)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "`n=== MMSMOA 2026 — Zero to MCP in 5 Minutes ===" -ForegroundColor Cyan
Write-Host "Setting up the demo environment...`n" -ForegroundColor Cyan

# -----------------------------------------------------------------------
# 1. Check / Install Python
# -----------------------------------------------------------------------
$python = $null

# Try python then python3
foreach ($cmd in @("python", "python3")) {
    try {
        $ver = & $cmd --version 2>&1
        if ($ver -match "Python\s+3\.(\d+)") {
            $minor = [int]$Matches[1]
            if ($minor -ge 10) {
                $python = $cmd
                Write-Host "[OK] Found $ver ($cmd)" -ForegroundColor Green
                break
            }
        }
    } catch { }
}

if (-not $python) {
    Write-Host "[..] Python 3.10+ not found. Installing via winget..." -ForegroundColor Yellow
    try {
        winget install --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                     [System.Environment]::GetEnvironmentVariable("Path","User")
        $python = "python"
        Write-Host "[OK] Python installed." -ForegroundColor Green
    } catch {
        Write-Host "[!!] winget install failed. Please install Python 3.10+ manually:" -ForegroundColor Red
        Write-Host "     https://www.python.org/downloads/" -ForegroundColor Red
        exit 1
    }
}

# -----------------------------------------------------------------------
# 2. Create virtual environment
# -----------------------------------------------------------------------
if (-not (Test-Path ".\venv")) {
    Write-Host "[..] Creating virtual environment..." -ForegroundColor Yellow
    & $python -m venv venv
    Write-Host "[OK] Virtual environment created." -ForegroundColor Green
} else {
    Write-Host "[OK] Virtual environment already exists." -ForegroundColor Green
}

# Activate
. .\venv\Scripts\Activate.ps1

# -----------------------------------------------------------------------
# 3. Install dependencies
# -----------------------------------------------------------------------
Write-Host "[..] Installing Python packages..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
Write-Host "[OK] Packages installed." -ForegroundColor Green

# -----------------------------------------------------------------------
# 4. Verify
# -----------------------------------------------------------------------
Write-Host "`n--- Verification ---" -ForegroundColor Cyan
Write-Host "Python : $(python --version)"
Write-Host "Pip    : $(pip --version)"
Write-Host "MCP SDK:" 
pip show mcp | Select-String "^(Name|Version)"

Write-Host "`n=== Setup complete! ===" -ForegroundColor Green
Write-Host @"

  To start the MCP server:
    .\venv\Scripts\Activate.ps1
    python mcp_server.py

  To test with the client:
    python test_client.py

"@ -ForegroundColor White
