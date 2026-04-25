# AI Fundamentals — MMS MOA 2026

Hands-on demos and reference materials for the **AI Fundamentals** session at [MMS MOA 2026](https://mms365.com) (Midwest Management Summit, Mall of America, Bloomington MN — May 2026).

---

## Repository Contents

### [`llm_comparison/`](llm_comparison/)

Ready-to-run prompts designed to be sent **verbatim** to multiple LLMs (GPT-4o, Claude, Gemini, Llama, Mistral, Phi-4, etc.) so the audience can see real differences in instruction-following, personality, guardrails, and hallucination behaviour.

| File | Description |
|---|---|
| `llm_comparison_prompts.md` | Three curated prompts — a constraint gauntlet, a hot-take opinion test, and a hallucination trap — with detailed notes on what to watch for in each model's response |

---

### [`mcpdemo/`](mcpdemo/)

**Zero to MCP in 5 Minutes** — stand up a [Model Context Protocol](https://modelcontextprotocol.io) server on Windows that exposes real system tools backed by PowerShell, then connect any MCP-aware AI (e.g. GitHub Copilot) to it.

| File | Description |
|---|---|
| `setup.ps1` | One-shot installer — checks for Python, creates a venv, installs dependencies |
| `mcp_server.py` | Python MCP server (streamable-HTTP transport, FastMCP) |
| `tools.ps1` | PowerShell script that does the real work (`Get-ChildItem`, `Get-CimInstance`, etc.) |
| `test_client.py` | Python MCP client that calls every tool to verify the server works |
| `requirements.txt` | Python dependencies (`mcp[cli]`) |

See [`mcpdemo/README.md`](mcpdemo/README.md) for full setup and usage instructions.

---

### [`prompt_examples/`](prompt_examples/)

Reference materials and a live-runnable demo covering the most common and effective AI prompting strategies.

| File | Description |
|---|---|
| `types_of_prompts.md` | Reference guide to 14 prompt types — zero-shot through meta-prompt — with examples and a quick-reference table |
| `mms_moa_prompts.ps1` | PowerShell 7 script that walks through all 12 core prompt types live against the OpenAI API, with MMS MOA-themed prompts and presenter pause points |

**Prerequisites for `mms_moa_prompts.ps1`:** PowerShell 7+, internet access, and `$env:OPENAI_API_KEY` set.

---

## Quick Start

```powershell
# Clone the repo, then pick your demo:

# — LLM comparison: open llm_comparison/llm_comparison_prompts.md and run prompts in your browser
# — MCP demo:
cd mcpdemo
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
.\venv\Scripts\Activate.ps1
python mcp_server.py          # terminal 1
python test_client.py         # terminal 2

# — Prompt examples (requires OPENAI_API_KEY):
cd prompt_examples
$env:OPENAI_API_KEY = "sk-..."
pwsh .\mms_moa_prompts.ps1
```
