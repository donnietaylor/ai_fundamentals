# AI Fundamentals

A presentation that covers the fundamentals of Artificial Intelligence — from core terminology to enterprise deployment.

## Topics Covered

- **AI vs. ML vs. Deep Learning** — Understanding the hierarchy and differences
- **Essential AI Terminology** — Tokens, embeddings, transformers, attention, RAG, hallucinations, and more
- **How LLMs Work** — Training pipeline, RLHF, context windows, inference
- **Small Language Models (SLMs)** — What they are, why they matter, and how they compare to LLMs
- **Model Context Protocol (MCP)** — The open standard for connecting AI models to tools and data sources
- **The AI Landscape** — OpenAI, Anthropic, Google DeepMind, Meta, Microsoft, and others
- **Why GPUs Matter** — The hardware behind AI and why NVIDIA dominates
- **Enterprise AI** — Architecture, use cases, data strategy, governance, and platform decisions

## Viewing the Presentation

The presentation is written in [Marp](https://marp.app/) Markdown format (`presentation.md`), which renders as a slide deck.

### Option 1 — Marp CLI

```bash
npm install -g @marp-team/marp-cli
marp presentation.md --html -o presentation.html
open presentation.html
```

### Option 2 — VS Code Extension

Install the [Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode) extension, then open `presentation.md` to see a live slide preview.

### Option 3 — Read as Markdown

The file is also fully readable as plain Markdown — just open `presentation.md` in any Markdown viewer (GitHub renders it inline).

## File Structure

```
presentation.md   — Full slide deck (Marp Markdown)
README.md         — This file
```