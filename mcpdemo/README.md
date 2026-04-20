# Zero to MCP in 5 Minutes

**MMSMOA 2026 Demo** — Stand up a Model Context Protocol server on Windows that exposes real system tools (list files, read files, OS info, search) backed by PowerShell.

---

## What's in the box?

| File | Purpose |
|---|---|
| `setup.ps1` | One-shot installer — gets Python, creates a venv, installs dependencies |
| `mcp_server.py` | Python MCP server (streamable-HTTP transport) |
| `tools.ps1` | PowerShell script that does the actual work (file ops, OS data) |
| `test_client.py` | Python MCP client that calls every tool to prove it works |
| `requirements.txt` | Python dependencies (`mcp[cli]`) |

---

## Architecture (30-second version)

```
┌──────────────┐   HTTP/SSE    ┌──────────────────┐   subprocess   ┌────────────┐
│  MCP Client  │ ───────────── │  mcp_server.py   │ ──────────────│ tools.ps1  │
│  (or AI app) │   (JSON-RPC)  │  (Python FastMCP) │   (pwsh)      │ (PowerShell)│
└──────────────┘               └──────────────────┘               └────────────┘
```

- **MCP Client** sends JSON-RPC tool calls over HTTP.
- **mcp_server.py** receives them, dispatches to `tools.ps1` via PowerShell subprocess.
- **tools.ps1** runs native Windows commands (`Get-ChildItem`, `Get-CimInstance`, etc.) and returns JSON.

---

## Step 0 — Prerequisites

- **Windows 10/11** or **Windows Server 2019+**
- **PowerShell 5.1+** (ships with Windows)
- **Internet access** (to install Python & pip packages)
- Python 3.10+ *or* `winget` (the setup script will auto-install Python if missing)

---

## Step 1 — Run Setup (~60 seconds)

Open a PowerShell terminal in this folder and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```

This will:
1. Check for Python 3.10+ — install via `winget` if missing
2. Create a virtual environment (`venv/`)
3. Install the MCP SDK (`mcp[cli]`)

---

## Step 2 — Start the MCP Server

```powershell
.\venv\Scripts\Activate.ps1
python mcp_server.py
```

You should see:

```
Starting MCP server — Windows Tools Demo …
```

The server listens on **http://localhost:8000/mcp** (streamable-HTTP transport).

---

## Step 3 — Test It! (new terminal)

Open a **second** PowerShell terminal:

```powershell
cd mcpdemo
.\venv\Scripts\Activate.ps1
python test_client.py
```

You'll see output for each tool:

- **`get_os_data`** — hostname, OS version, CPU, RAM, disks
- **`list_files`** — directory listing
- **`get_file_content`** — reads a file and returns its contents
- **`search_files`** — finds files by name pattern

---

## Step 4 — Use from VS Code / Copilot (optional)

Add this to your VS Code `settings.json` (or `.vscode/mcp.json`):

```json
{
  "mcp": {
    "servers": {
      "windows-tools": {
        "type": "streamableHttp",
        "url": "http://localhost:8000/mcp"
      }
    }
  }
}
```

Now Copilot (or any MCP-aware AI) can call `list_files`, `get_file_content`, `get_os_data`, and `search_files` directly.

---

## Tools Exposed

| Tool | Description | Parameters |
|---|---|---|
| `list_files` | List files & folders at a path | `path` (default `.`) |
| `get_file_content` | Read a file's text content (≤ 1 MB) | `path` |
| `get_os_data` | Windows OS, CPU, RAM, disk info | *(none)* |
| `search_files` | Find files by name substring | `path`, `query` |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `python` not found after install | Close & reopen PowerShell so PATH refreshes |
| `winget` not available | Install Python manually from https://www.python.org/downloads/ |
| Port 8000 in use | The MCP SDK default is 8000; stop the other process or set `--port` |
| Execution policy error | Run `Set-ExecutionPolicy -Scope Process Bypass` |

---

## Cleanup

```powershell
# Remove the virtual environment
Remove-Item -Recurse -Force .\venv
```

---

*Built for MMSMOA 2026 — AI Fundamentals session*
