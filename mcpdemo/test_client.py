"""
test_client.py — Quick MCP client that connects to the local server
and calls each tool once to prove it works.

Usage:
    1. Start the server:  python mcp_server.py
    2. In another terminal: python test_client.py
"""

import asyncio
import json

from mcp.client.streamable_http import streamablehttp_client
from mcp import ClientSession

SERVER_URL = "http://localhost:8000/mcp"


async def main():
    print("Connecting to MCP server at", SERVER_URL, "...\n")

    async with streamablehttp_client(SERVER_URL) as (read, write, _):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # Show available tools
            tools = await session.list_tools()
            print("=" * 60)
            print("Available tools:")
            print("=" * 60)
            for t in tools.tools:
                print(f"  - {t.name}: {t.description[:80]}")
            print()

            # --- Demo 1: Get OS data ---
            print("-" * 60)
            print("DEMO 1  >>  get_os_data()")
            print("-" * 60)
            result = await session.call_tool("get_os_data", {})
            _pretty(result)

            # --- Demo 2: List files in the current directory ---
            print("-" * 60)
            print("DEMO 2  >>  list_files(path='.')")
            print("-" * 60)
            result = await session.call_tool("list_files", {"path": "."})
            _pretty(result)

            # --- Demo 3: Read this script's own source ---
            print("-" * 60)
            print("DEMO 3  >>  get_file_content(path='test_client.py')")
            print("-" * 60)
            result = await session.call_tool("get_file_content", {"path": "test_client.py"})
            _pretty(result)

            # --- Demo 4: Search for .py files ---
            print("-" * 60)
            print("DEMO 4  >>  search_files(path='.', query='.py')")
            print("-" * 60)
            result = await session.call_tool("search_files", {"path": ".", "query": ".py"})
            _pretty(result)

    print("\n✓ All demos complete!")


def _pretty(result):
    """Print MCP tool result content nicely."""
    for block in result.content:
        try:
            obj = json.loads(block.text)
            print(json.dumps(obj, indent=2, default=str))
        except (json.JSONDecodeError, AttributeError):
            print(block.text)
    print()


if __name__ == "__main__":
    asyncio.run(main())
