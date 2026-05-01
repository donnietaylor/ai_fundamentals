"""
mcp_server.py — A minimal MCP (Model Context Protocol) server.

Exposes Windows system tools (list files, read files, OS info, search)
by shelling out to tools.ps1.  Speaks MCP over streamable HTTP (SSE).
"""

import asyncio
import json
import os
import sys
from pathlib import Path

from mcp.server.fastmcp import FastMCP

# ---------------------------------------------------------------------------
# Ensure CWD is the script's own directory (so relative paths work)
# ---------------------------------------------------------------------------
os.chdir(Path(__file__).parent)

# ---------------------------------------------------------------------------
# Initialise the MCP server
# ---------------------------------------------------------------------------
mcp = FastMCP(
    "Windows Tools Demo",
    instructions="MMSMOA 2026 — Zero to MCP in 5 minutes. Exposes Windows system tools.",
)

TOOLS_SCRIPT = str(Path(__file__).parent / "tools.ps1")

# ---------------------------------------------------------------------------
# Helper: call the PowerShell script and return parsed JSON
# ---------------------------------------------------------------------------
async def _call_ps(action: str, path: str = ".", query: str = "") -> dict:
    """Run tools.ps1 with the given action and return the JSON result."""
    cmd = [
        "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
        "-File", TOOLS_SCRIPT,
        "-Action", action,
        "-Path", path,
        "-Query", query,
    ]
    proc = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await proc.communicate()
    if proc.returncode != 0:
        return {"error": stderr.decode(errors="replace").strip()}
    try:
        return json.loads(stdout.decode(errors="replace"))
    except json.JSONDecodeError:
        return {"raw_output": stdout.decode(errors="replace").strip()}


# ---------------------------------------------------------------------------
# MCP Tools  (each one becomes a callable tool in the protocol)
# ---------------------------------------------------------------------------

@mcp.tool()
async def list_files(path: str = ".") -> str:
    """List files and folders at the given path.

    Args:
        path: Directory path to list (default: current directory)
    """
    result = await _call_ps("list_files", path=path)
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_file_content(path: str) -> str:
    """Read and return the text content of a file (max 1 MB).

    Args:
        path: Full or relative path to the file to read
    """
    result = await _call_ps("get_file_content", path=path)
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_os_data() -> str:
    """Return detailed information about the Windows operating system,
    CPU, RAM, and disk usage."""
    result = await _call_ps("get_os_data")
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def search_files(path: str = ".", query: str = "") -> str:
    """Search for files whose name contains the query string.

    Args:
        path: Root directory to search under
        query: Substring to match in file names
    """
    result = await _call_ps("search_files", path=path, query=query)
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_top_processes(top: int = 15) -> str:
    """Return the top Windows processes ranked by RAM usage, with a CPU delta sample.

    Args:
        top: Number of processes to return (default: 15)
    """
    result = await _call_ps("get_top_processes", query=str(top))
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_network_info() -> str:
    """Return details for all active network adapters: IP addresses, MAC,
    link speed, default gateway, and configured DNS servers."""
    result = await _call_ps("get_network_info")
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_running_services(state: str = "Running") -> str:
    """List Windows services filtered by state.

    Args:
        state: Service state to filter on — Running, Stopped, or All (default: Running)
    """
    result = await _call_ps("get_running_services", query=state)
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_event_log(hours: int = 24) -> str:
    """Return recent Critical, Error, and Warning entries from the Windows
    System and Application event logs.

    Args:
        hours: How many hours back to search (default: 24)
    """
    result = await _call_ps("get_event_log", query=str(hours))
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_security_status() -> str:
    """Return Windows Defender antivirus status (real-time protection, definition
    version, last scan times), firewall profile states, and UAC configuration."""
    result = await _call_ps("get_security_status")
    return json.dumps(result, indent=2, default=str)


@mcp.tool()
async def get_windows_updates(days: int = 30) -> str:
    """Return recently installed Windows updates and any pending updates.

    Args:
        days: How many days back to check for installed updates (default: 30)
    """
    result = await _call_ps("get_windows_updates", query=str(days))
    return json.dumps(result, indent=2, default=str)


# ---------------------------------------------------------------------------
# Entry-point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    print("Starting MCP server — Windows Tools Demo …")
    mcp.run(transport="streamable-http")
