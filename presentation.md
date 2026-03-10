---
marp: true
theme: default
paginate: true
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
  }
  section.title {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
    color: white;
    text-align: center;
  }
  section.title h1 {
    font-size: 2.4em;
    margin-bottom: 0.2em;
  }
  section.title p {
    font-size: 1.1em;
    opacity: 0.85;
  }
  section.section-header {
    background: #0f3460;
    color: white;
    text-align: center;
    justify-content: center;
  }
  h1 { color: #0f3460; border-bottom: 3px solid #e94560; padding-bottom: 0.2em; }
  h2 { color: #16213e; }
  strong { color: #e94560; }
  table { font-size: 0.85em; }
  code { background: #f4f4f4; padding: 2px 6px; border-radius: 4px; }
---

<!-- _class: title -->

# AI Fundamentals

### From Terminology to Enterprise Deployment

---

## Agenda

1. **What is AI? AI vs. ML vs. Deep Learning**
2. **Essential AI Terminology**
3. **How Large Language Models (LLMs) Work**
4. **Small Language Models (SLMs)**
5. **Model Context Protocol (MCP)**
6. **The AI Landscape — Major Companies**
7. **Why GPUs Matter**
8. **Enterprise AI**
9. **Summary & Q&A**

---

<!-- _class: section-header -->

# 1. What is AI?

## AI vs. ML vs. Deep Learning

---

## The AI Hierarchy

```
┌─────────────────────────────────────────────────────┐
│                  Artificial Intelligence             │
│   (any technique enabling machines to mimic humans) │
│                                                     │
│   ┌─────────────────────────────────────────────┐  │
│   │          Machine Learning                   │  │
│   │  (systems that learn from data)             │  │
│   │                                             │  │
│   │   ┌─────────────────────────────────────┐  │  │
│   │   │        Deep Learning                │  │  │
│   │   │  (neural networks with many layers) │  │  │
│   │   │                                     │  │  │
│   │   │  ┌───────────────────────────────┐  │  │  │
│   │   │  │   Generative AI / LLMs        │  │  │  │
│   │   │  │  (foundation models, GPT, etc)│  │  │  │
│   │   │  └───────────────────────────────┘  │  │  │
│   │   └─────────────────────────────────────┘  │  │
│   └─────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## Artificial Intelligence (AI)

> The broad field of creating machines that can perform tasks that typically require **human intelligence**.

**Examples:**
- Rule-based systems (chess engines, expert systems)
- Computer vision
- Natural language processing
- Robotics and autonomous systems

**Key point:** Not all AI is "learning" — early AI systems used hand-crafted rules.

---

## Machine Learning (ML)

> Systems that **learn patterns from data** rather than following explicitly programmed rules.

**Three main types:**
- **Supervised Learning** — learns from labeled input/output pairs *(spam detection, image classification)*
- **Unsupervised Learning** — finds patterns in unlabeled data *(customer segmentation, anomaly detection)*
- **Reinforcement Learning** — learns by trial and error with rewards *(game playing, robotics)*

**Why it matters:** ML removes the need to hand-code every rule — the model discovers rules from examples.

---

## Deep Learning

> A subset of ML using **artificial neural networks** with many layers (hence "deep") to learn hierarchical representations.

**What makes it powerful:**
- Automatically learns features — no manual feature engineering
- Excels on unstructured data (text, images, audio, video)
- Scales well with more data and compute

**Examples:** Image recognition (CNNs), speech recognition (RNNs), language models (Transformers)

**Trade-off:** Requires large amounts of data and significant compute; models are often harder to interpret ("black boxes").

---

## AI vs. ML vs. Deep Learning — Summary

| | AI | ML | Deep Learning |
|---|---|---|---|
| **Scope** | Broadest | Subset of AI | Subset of ML |
| **Approach** | Rules OR learning | Learns from data | Multi-layer neural nets |
| **Data needed** | Varies | Moderate | Large amounts |
| **Compute** | Varies | Moderate | High (GPUs!) |
| **Interpretability** | Varies | Often high | Often low |
| **Key examples** | Chess engine, expert system | Decision trees, SVMs | GPT, image classifiers |

---

<!-- _class: section-header -->

# 2. Essential AI Terminology

---

## Parameters & Model Size

**Parameters** are the numerical weights inside a neural network that are adjusted during training.

- **GPT-3** (2020): 175 billion parameters
- **Phi-4-mini** (2025): 3.8 billion parameters
- **Llama 4 Scout** (2025): 17B model with 16 experts (MoE)
- **Qwen3 flagship** (2025): 235B total / 22B active parameters (MoE)

> **Rule of thumb:** More parameters usually mean more capacity, but modern vendors often hide exact counts — and MoE models separate **total** parameters from **active** parameters.

A model's **size** is typically described in billions of parameters (e.g., "a 7B model" or "a 70B model").

---

## Tokens

**Tokens** are the basic units of text that a model processes — not necessarily whole words.

```
"Hello, world!"  →  ["Hello", ",", " world", "!"]  (4 tokens)
"unbelievable"   →  ["un", "bel", "iev", "able"]   (4 tokens)
```

**Why tokens matter:**
- Models have a **context window** — the maximum number of tokens they can process at once
- API pricing is often based on token count
- GPT-4.1: 1,000,000 token input context window (published by OpenAI in 2025)

> Tokenization is done by a **tokenizer** (e.g., Byte-Pair Encoding) trained separately from the model.

---

## Embeddings

**Embeddings** are dense numerical vector representations of text (or images, audio) that capture **semantic meaning**.

```
"king"   → [0.25, -0.13, 0.88, 0.42, ...]   (e.g. 768 numbers)
"queen"  → [0.24, -0.11, 0.89, 0.45, ...]   (similar vector!)
"dog"    → [0.91,  0.67, 0.12, 0.03, ...]   (very different)
```

**Key property:** Similar meaning → similar vector → close together in "embedding space"

**Used in:**
- Semantic search (find documents by meaning, not keywords)
- Recommendation systems
- Retrieval-Augmented Generation (RAG)
- Clustering and classification

---

## Transformers

The **Transformer** architecture (introduced in *"Attention Is All You Need"*, 2017) is the foundation of all modern LLMs.

**Key innovations:**
- **Self-Attention** — each token can "look at" every other token in the context
- **Parallel processing** — processes all tokens simultaneously (vs. sequential RNNs)
- **Positional encoding** — preserves word order information

**Components:**
- **Encoder** — reads and understands input (BERT-style models)
- **Decoder** — generates output token by token (GPT-style models)
- **Encoder-Decoder** — translation, summarization (T5, BART)

---

## Attention Mechanism

**Attention** allows the model to focus on the most relevant parts of the input when processing each token.

```
"The animal didn't cross the street because it was too tired."
                                                   ↑
                         What does "it" refer to? "animal" (not "street")
```

- **Attention score** tells the model: "When processing token X, how much should I pay attention to token Y?"
- **Multi-head attention** — runs multiple attention operations in parallel, each learning different relationships

> This is why Transformers understand context and long-range dependencies so well.

---

## Training, Fine-tuning & Inference

**Pre-training:**
- Model is trained on massive datasets (entire internet, books, code)
- Learns language patterns, facts, reasoning
- Very expensive: millions of dollars, months of compute

**Fine-tuning:**
- A pre-trained model is further trained on a smaller, task-specific dataset
- Much cheaper than pre-training; adapts the model to a domain
- Example: Fine-tuning GPT on medical literature for healthcare use

**Inference:**
- Using a trained model to generate responses
- What happens when you type a prompt — the model predicts tokens one at a time

---

## Prompt Engineering

**Prompts** are the instructions or context you provide to an LLM to guide its output.

**Key techniques:**
- **Zero-shot** — ask directly without examples: *"Summarize this article."*
- **Few-shot** — provide examples: *"Here are 3 examples of summaries → now summarize this."*
- **Chain-of-thought** — ask the model to reason step-by-step: *"Let's think step by step..."*
- **System prompt** — instructions given before user input to set behavior/persona

> Good prompts dramatically improve output quality without any model training.

---

## RAG — Retrieval-Augmented Generation

**RAG** combines an LLM with a **retrieval system** to ground responses in up-to-date, specific knowledge.

```
User Query
    ↓
[Retriever] → searches vector database for relevant documents
    ↓
[Relevant context chunks] + [Original query]
    ↓
[LLM] generates response grounded in retrieved context
    ↓
Response (with citations!)
```

**Why RAG?**
- LLMs have a knowledge cutoff date — RAG adds current information
- Reduces hallucinations by providing source material
- Keeps proprietary data out of the model (privacy/security)

---

## Hallucinations

**Hallucinations** occur when an LLM generates **confident-sounding but factually incorrect** information.

**Why it happens:**
- Models are trained to predict the next likely token, not to "look up" facts
- They can interpolate/extrapolate patterns in ways that produce plausible-but-wrong content
- No internal "fact checker"

**Mitigations:**
- RAG (ground responses in retrieved documents)
- Fine-tuning on accurate domain data
- Output verification and human review
- Structured outputs with citations

> Critical consideration for any enterprise deployment!

---

## Agentic AI & AI Agents

**AI Agents** are systems where an LLM can take actions, use tools, and complete multi-step tasks autonomously.

**Agent capabilities:**
- Call APIs and web services
- Read/write files and databases
- Browse the web
- Write and execute code
- Orchestrate other agents (multi-agent systems)

**Agentic loop:**
```
Goal → Plan → [Action → Observe result → Adjust plan] → ... → Goal achieved
```

**Examples:** GitHub Copilot agent mode, AutoGPT, LangChain agents, OpenAI Assistants

---

<!-- _class: section-header -->

# 3. How Large Language Models Work

---

## LLMs — The Big Picture

**Large Language Models (LLMs)** are deep learning models based on the Transformer architecture, trained on vast amounts of text to understand and generate human language.

**"Large" means:**
- Billions to trillions of parameters
- Trained on hundreds of billions to trillions of tokens
- Require massive compute infrastructure

**Core capability:** Given a sequence of tokens, predict the next most likely token — repeated to generate complete responses.

> This simple objective, at scale, produces remarkable emergent capabilities: reasoning, coding, translation, summarization, and more.

---

## LLM Training Pipeline

```
1. DATA COLLECTION
   Web crawls, books, code, Wikipedia, academic papers
   → Petabytes of text data

2. DATA PREPROCESSING
   Deduplication, filtering, tokenization
   → Clean, tokenized training corpus

3. PRE-TRAINING
   Train Transformer on next-token prediction
   → Base model (can complete text)

4. INSTRUCTION TUNING (SFT)
   Fine-tune on prompt-response pairs
   → Instruction-following model

5. RLHF / DPO
   Align with human preferences using feedback
   → Helpful, harmless, honest model
```

---

## RLHF — Reinforcement Learning from Human Feedback

A key alignment technique used by OpenAI (ChatGPT), Anthropic, and others.

**Steps:**
1. **Supervised Fine-Tuning (SFT):** Fine-tune base model on high-quality human-written responses
2. **Reward Model Training:** Humans rank multiple model outputs; train a reward model to predict human preference
3. **PPO Training:** Use the reward model as a signal to optimize the LLM via reinforcement learning

**Goal:** Make the model **helpful, harmless, and honest** (Anthropic's "HHH" principle)

**Alternative:** **DPO (Direct Preference Optimization)** — simpler, trains directly on preference pairs without a separate reward model

---

## Context Window & Memory

**Context window** = the maximum number of tokens the model can "see" at once

| Model | Published Context Window |
|-------|--------------------------|
| GPT-4.1 | 1,000,000 input tokens |
| Gemini 2.5 Flash | 1,048,576 input tokens |
| Llama 4 Scout | 10,000,000 tokens |
| Llama 4 Maverick | 1,000,000 tokens |
| Qwen3-2507 | 256,000 native / 1,000,000 extended |

**Current closed-model branding changes fast:** Anthropic's latest Claude API family now includes **Claude Opus 4.6** and **Claude Sonnet 4.6**, so always verify live vendor docs right before a customer-facing presentation.

**Limitations of context:**
- Beyond the window, the model has no memory of earlier content
- Larger windows require more compute (attention is O(n²))
- **Long-term memory** requires external storage (vector DBs, databases)

---

## How Inference Works (Token Generation)

When you send a prompt, the model generates tokens **one at a time**:

```
Prompt: "The capital of France is"
Step 1: Model predicts → "Paris" (probability distribution over vocabulary)
Step 2: "Paris" appended → "The capital of France is Paris"
Step 3: Model predicts → "." 
Step 4: Model predicts → "<end_of_sequence>" → Stop!
```

**Temperature** controls randomness:
- `temperature = 0` → deterministic, always picks highest-probability token
- `temperature = 1` → samples from full probability distribution (creative)
- `temperature > 1` → more random/creative but less coherent

---

<!-- _class: section-header -->

# 4. Small Language Models (SLMs)

---

## What Are SLMs?

**Small Language Models (SLMs)** are language models with significantly fewer parameters than frontier LLMs — typically **under 10 billion parameters**.

**Examples:**
| Model | Parameters | Creator |
|-------|-----------|---------|
| Phi-4-mini | 3.8B | Microsoft |
| Phi-4-multimodal | 5.6B | Microsoft |
| Gemma 3 1B / 4B | 1B / 4B | Google |
| Mistral 7B | 7B | Mistral AI |
| Qwen3 0.6B–8B | 0.6–8B | Alibaba |

---

## SLMs vs. LLMs

| Dimension | SLMs (≤10B) | LLMs (>10B) |
|-----------|------------|-------------|
| **Parameters** | <10B | 10B–1T+ |
| **Hardware** | Laptop / phone CPU/GPU | Data center GPUs |
| **Latency** | Very fast | Slower |
| **Cost** | Cheap / free to run | $$ per API call |
| **Privacy** | Fully on-device | Cloud dependency |
| **Capability** | Good for focused tasks | Broad general knowledge |
| **Customization** | Easy to fine-tune | Expensive to fine-tune |
| **Offline use** | Yes | Typically no |

---

## Why SLMs Are Important

**On-device / edge AI:**
- Run on smartphones, laptops, embedded systems
- No network round-trip → ultra-low latency
- No data leaves the device → **privacy-preserving**

**Cost efficiency:**
- Self-host on modest hardware vs. paying per API call
- Run thousands of inferences for pennies

**Domain specialization:**
- Fine-tune a small model on a specific task → often matches or beats large general models
- Easier to audit and validate in regulated industries

**Microsoft's Phi family** is a good example of efficient model design: current Phi-4 variants span **3.8B mini/reasoning**, **5.6B multimodal**, and **15B reasoning-vision** models while still targeting edge and enterprise use cases.

---

<!-- _class: section-header -->

# 5. Model Context Protocol (MCP)

---

## What is MCP?

**Model Context Protocol (MCP)** is an **open standard** (introduced by Anthropic in 2024) that defines how AI applications connect to external data sources and tools.

> *"MCP is to AI agents what USB-C is to devices — a universal connector."*

**Problem it solves:**
- Every AI app previously needed custom integrations for every data source
- M tools × N models = M×N integrations (explosion of custom connectors)

**MCP solution:**
- Define one standard protocol
- M tools × N models = M+N implementations (each tool and model implements once)

---

## MCP Architecture

```
┌─────────────────┐         ┌─────────────────────┐
│   MCP HOST      │         │    MCP SERVERS       │
│  (AI app with   │◄───────►│                      │
│   LLM inside)   │  MCP    │  ┌────────────────┐  │
│                 │ Protocol│  │  File System   │  │
│  e.g. Claude,  │         │  └────────────────┘  │
│  VS Code w/     │         │  ┌────────────────┐  │
│  Copilot,       │         │  │   GitHub API   │  │
│  Cursor         │         │  └────────────────┘  │
└─────────────────┘         │  ┌────────────────┐  │
                             │  │  Databases     │  │
                             │  └────────────────┘  │
                             │  ┌────────────────┐  │
                             │  │  Web Browser   │  │
                             │  └────────────────┘  │
                             └─────────────────────┘
```

---

## MCP — Core Concepts

**MCP Servers expose three primitives:**

1. **Tools** — actions the LLM can invoke (like function calls)
   - `search_web(query)`, `read_file(path)`, `query_database(sql)`

2. **Resources** — data sources the LLM can read
   - Files, database records, API responses

3. **Prompts** — reusable prompt templates for common tasks

**MCP Hosts** (clients) are the applications running the LLM:
- Claude Desktop, VS Code with Copilot, Cursor, custom apps

**Transport:** MCP uses JSON-RPC 2.0 over stdio or HTTP+SSE

---

## MCP — Why It Matters

**Before MCP:**
- Each AI tool had its own proprietary plugin system
- Vendor lock-in — tools only worked with specific AI products
- Developers had to build integrations from scratch for every combination

**After MCP:**
- Build an MCP server once → works with any MCP-compatible AI host
- Open ecosystem — anyone can contribute MCP servers
- AI agents can safely and predictably interact with real-world systems

**Adoption:** The ecosystem now includes the official MCP spec plus SDKs maintained with partners including **Microsoft** and **Google**, along with Anthropic clients and hundreds of community-built servers.

---

<!-- _class: section-header -->

# 6. The AI Landscape

## Major Companies & How They Differ

---

## The AI Ecosystem

```
┌──────────────────────────────────────────────────────────────┐
│                    FOUNDATION MODEL LABS                     │
│         OpenAI  │  Anthropic  │  Google DeepMind  │  Meta AI │
│         Mistral │  xAI        │  Cohere            │  etc.    │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│                    CLOUD AI PLATFORMS                        │
│    Microsoft Azure AI  │  Google Cloud AI  │  AWS Bedrock   │
└──────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────┐
│                ENTERPRISE AI APPLICATIONS                    │
│   Salesforce Einstein │ ServiceNow AI │ SAP AI │ Microsoft 365│
└──────────────────────────────────────────────────────────────┘
```

---

## OpenAI

**Founded:** 2015 (non-profit) → 2019 (capped-profit)
**Backed by:** Microsoft and other investors
**Key models:** ChatGPT / GPT-5.4, GPT-5.2, GPT-4.1, o3, o4-mini, DALL-E, Sora, Whisper

**Positioning:**
- Pioneer of the current generative AI wave (ChatGPT launched Nov 2022)
- API-first platform — powers thousands of applications
- Strong on reasoning models (o-series) and large-context models (GPT-4.1)
- Consumer: ChatGPT
- Enterprise: Azure OpenAI Service (via Microsoft partnership)

**Philosophy:** "Controlled commercialization" toward AGI with safety guardrails

---

## Anthropic

**Founded:** 2021 (by ex-OpenAI researchers, including Dario Amodei)
**Backed by:** Amazon and Google
**Key models:** Claude Opus 4.6, Claude Sonnet 4.6, Claude 4.5, Claude 3.7

**Positioning:**
- **Safety-first AI** — Constitutional AI and RLHF for alignment
- Known for long-context, coding, and agent workflows
- Strong Claude Code / agent tooling ecosystem
- Inventor of MCP (Model Context Protocol)
- More conservative about releasing model weights (closed-source)

**Philosophy:** AI Safety is existential — slow down and get it right

---

## Google DeepMind

**Formed:** 2023 (merger of Google Brain + DeepMind)
**Key models:** Gemini 2.5 / 2.0 (Pro, Flash, Flash-Lite), Gemma 3, Imagen 4, Veo 3, AlphaCode

**Positioning:**
- Broadest research portfolio (AlphaFold, AlphaGo, AlphaStar, Gemini)
- **Massive context windows** (Gemini 2.5 Flash publishes a 1,048,576-token input limit)
- Native **multimodal** (text, image, video, audio in one model)
- Deep integration with Google products (Search, Workspace, Android)
- Gemma gives Google a strong open-model story alongside Gemini APIs
- TPUs give Google unique infrastructure advantage

**Philosophy:** AI for scientific discovery and broad societal benefit

---

## Meta AI

**Key models:** Llama 3.3, Llama 4 Scout / Maverick, Code Llama, SAM (vision)

**Positioning:**
- **Open-weight champion** — Llama weights are widely downloadable
- Powers Meta's own products (Facebook, Instagram, WhatsApp)
- Llama models have been downloaded hundreds of millions of times
- Enables self-hosting, fine-tuning without API fees

**Philosophy:** Open release democratizes AI and accelerates research

**Impact of open-weight release:**
- Created entire ecosystem of fine-tuned variants (Mistral, Hermes, etc.)
- Enables privacy-preserving, on-premise enterprise deployments
- Sparked debate about safety vs. openness

---

## Microsoft (Azure AI / Copilot)

**Not a model lab, but the largest AI platform company**

**Strategy:** Partner with OpenAI + open models + own research (Phi series)
**Products:**
- **Azure OpenAI Service** — enterprise access to GPT-5 / GPT-4.1 / o-series models
- **Microsoft Copilot** — AI in Microsoft 365 (Word, Excel, Teams, etc.)
- **GitHub Copilot** — AI coding assistant
- **Azure AI Foundry** — build, deploy, and manage AI apps
- **Phi-4 / Phi-4-mini / Phi-4-multimodal** — Microsoft's own SLMs (open-weight)

**Positioning:** Make AI accessible and safe for enterprises — compliance, security, governance, and integration with existing Microsoft stack

---

## Other Key Players

| Company | Focus | Notable |
|---------|-------|---------|
| **Mistral AI** | Open + efficient models | Mistral Small 3.1, Mistral Large 2, Codestral, Le Chat |
| **xAI (Elon Musk)** | Alternative to OpenAI | Grok (integrated with X/Twitter) |
| **Cohere** | Enterprise NLP | Command, Embed, Rerank — B2B focused |
| **Amazon AWS** | Cloud AI platform | Bedrock (multi-model), Titan, Nova, Trainium chips |
| **NVIDIA** | AI infrastructure | CUDA, H100/H200/B200 GPUs, NIM inference, NeMo |
| **Hugging Face** | Open-source AI hub | Model Hub, Transformers library, Spaces |
| **Stability AI** | Open generative AI | Stable Diffusion (image generation) |

---

## Open Weight vs. Closed API

| | Open Weight | Closed API |
|--|------------|------------|
| **Examples** | Llama 4, Qwen3, Gemma 3, Phi-4 | ChatGPT / GPT-5.x, Claude 4.x, Gemini 2.5 |
| **Cost** | Free to download, pay for compute | Pay per token |
| **Privacy** | Data stays on-premise | Data sent to vendor |
| **Customization** | Full fine-tuning access | Limited (fine-tuning API) |
| **Capability ceiling** | Growing fast, may lag frontier | Frontier capability |
| **Deployment** | Self-managed infrastructure | Managed service |
| **Compliance** | Full data sovereignty | Dependent on vendor |

**Trend:** The gap is narrowing rapidly — especially for focused, cost-sensitive, and long-context workloads.

---

<!-- _class: section-header -->

# 7. Why GPUs Matter

---

## CPUs vs. GPUs

| | CPU | GPU |
|--|-----|-----|
| **Design goal** | General-purpose, sequential tasks | Parallel numeric computation |
| **Cores** | 8–128 cores | 1,000s–10,000s of cores |
| **Clock speed** | 3–5 GHz | ~2 GHz |
| **Memory** | 32–512 GB DDR5 | 24–192 GB HBM3 |
| **Memory bandwidth** | ~100 GB/s | ~3–4 TB/s |
| **AI training** | Very slow | ✅ Dominant |
| **AI inference** | Slow for large models | ✅ Fast |
| **Best for** | OS, business logic, I/O | Matrix math, ML |

---

## Why Neural Networks Love GPUs

Neural network training is essentially **massive matrix multiplication** performed billions of times.

```
Forward pass:  output = W₁ × W₂ × W₃ × ... × Wₙ × input
Backward pass: ΔW = learning_rate × gradient × input

For GPT-3:  175B parameters → 175B floats to update each step
            Trained on 300B tokens → ~10²³ floating-point operations total
```

**GPU advantage:**
- Can perform **thousands of multiply-accumulate operations simultaneously**
- High-bandwidth memory (HBM) feeds data to cores fast enough to keep them busy
- Tensor Cores (NVIDIA) — specialized hardware for mixed-precision matrix math

---

## The GPU Supply Chain

```
NVIDIA dominates AI GPUs (~80–90% market share)

Key GPUs for AI:
├── A100 (2020) — 80 GB HBM2e, 312 TFLOPS (BF16)
├── H100 (2022) — 80 GB HBM3, 1,979 TFLOPS (BF16)   ← current standard
├── H200 (2024) — 141 GB HBM3e, 1,979 TFLOPS + more memory
└── B200 Blackwell (2025) — 192 GB HBM3e, ~4,500 TFLOPS (BF16)

A single H100 costs ~$25,000–$35,000
A typical LLM training cluster uses 1,000–10,000+ H100s
GPT-4 estimated training cost: $50M–$100M in compute
```

---

## CUDA — Why NVIDIA Has a Moat

**CUDA** (Compute Unified Device Architecture) — NVIDIA's parallel computing platform (released 2007)

**Why it matters:**
- PyTorch, TensorFlow, and virtually all AI frameworks are built on CUDA
- Decade+ of ecosystem development: optimized libraries (cuDNN, cuBLAS, NCCL)
- Researchers and engineers trained on CUDA
- Switching costs are enormous

**Challengers:**
- **AMD ROCm** — open-source GPU compute platform (improving, but behind)
- **Google TPUs** — custom AI accelerators, only on Google Cloud
- **AWS Trainium/Inferentia** — custom chips, growing
- **Intel Gaudi** — growing enterprise presence

---

## Inference Hardware

**Training vs. Inference needs:**

| | Training | Inference |
|--|----------|-----------|
| **Goal** | Update model weights | Generate responses |
| **When** | Once (or periodically) | Millions of times/day |
| **Memory** | Store weights + gradients + optimizer state | Weights only |
| **Compute pattern** | Batch processing | Often single requests |
| **Hardware** | High-end GPUs (H100, B200) | GPUs, but also CPUs, NPUs |

**Inference options:**
- Cloud GPUs (NVIDIA, AMD, custom silicon)
- Edge/on-device: Apple Neural Engine, Qualcomm NPU, Intel Neural Processor
- Consumer GPUs: RTX 4090 can run 70B models with quantization

---

<!-- _class: section-header -->

# 8. Enterprise AI

---

## What Is Enterprise AI?

**Enterprise AI** is the deployment of AI within organizations to:
- Automate business processes
- Augment employee productivity
- Extract insights from proprietary data
- Improve customer experiences
- Enable new products and services

**Key difference from consumer AI:**
- **Security & compliance** requirements (GDPR, HIPAA, SOC 2, FedRAMP)
- **Data privacy** — proprietary data must not leave the organization
- **Reliability** — SLAs, uptime guarantees, auditability
- **Integration** — must connect to existing enterprise systems
- **Governance** — who can use AI, what data can it access, how are outputs reviewed?

---

## Enterprise AI Architecture

```
┌────────────────────────────────────────────────────────────┐
│                   ENTERPRISE AI PLATFORM                   │
│                                                            │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐  │
│  │  AI Gateway  │   │  Model Hub   │   │  Observability│  │
│  │  (routing,   │   │  (manage     │   │  (logs, traces│  │
│  │   rate limits│   │  multiple    │   │   cost, safety│  │
│  │   auth)      │   │  models)     │   │   monitoring) │  │
│  └──────────────┘   └──────────────┘   └──────────────┘  │
│                                                            │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐  │
│  │  RAG / Data  │   │  Fine-tuning │   │  Agent       │  │
│  │  Connectors  │   │  Pipeline    │   │  Orchestration│ │
│  └──────────────┘   └──────────────┘   └──────────────┘  │
└────────────────────────────────────────────────────────────┘
```

---

## Enterprise AI Use Cases

**Productivity & Collaboration:**
- Meeting summaries and action items (Copilot in Teams)
- Document drafting and review (Copilot in Word)
- Email triage and drafting (Copilot in Outlook)
- Code generation and review (GitHub Copilot, Cursor)

**Customer-Facing:**
- Intelligent chatbots / virtual agents
- Personalized recommendations
- Automated customer support ticket resolution

**Back-Office & Operations:**
- Contract analysis and extraction
- Financial report generation
- Supply chain optimization
- Fraud detection and anomaly detection

---

## Enterprise AI — Data Strategy

**The enterprise data advantage:**
- Organizations have proprietary data LLMs were not trained on
- Domain-specific knowledge = competitive moat

**Data approaches:**

1. **RAG (Retrieval-Augmented Generation)**
   - Keep data in vector databases; retrieve at inference time
   - No model training needed; data stays current
   - Best for: knowledge bases, internal docs, FAQs

2. **Fine-tuning**
   - Update model weights with domain-specific data
   - Model "absorbs" knowledge; faster inference
   - Best for: style/tone adaptation, specialized reasoning

3. **Both** — fine-tune for domain behavior + RAG for current facts

---

## Enterprise AI — Governance & Risk

**Key concerns:**

**Hallucinations & Accuracy**
- LLMs can confidently state wrong information
- Mitigation: RAG with citations, human-in-the-loop review, output validation

**Data Privacy & Leakage**
- Model could expose confidential information in responses
- Mitigation: Role-based access control, output filtering, data classification

**Bias & Fairness**
- Models can reflect biases in training data
- Mitigation: Bias testing, diverse training data, monitoring

**Regulatory Compliance**
- EU AI Act, HIPAA (healthcare), FINRA (finance), GDPR
- Mitigation: Model cards, audit trails, human oversight requirements

---

## Enterprise AI — Key Platforms

| Platform | Provider | Key Strengths |
|----------|----------|---------------|
| **Azure AI Foundry** | Microsoft | OpenAI integration, enterprise compliance, M365 |
| **Google Cloud AI** | Google | Vertex AI, BigQuery ML, Gemini, multimodal |
| **AWS Bedrock** | Amazon | Multi-model choice, pay-per-use, AWS ecosystem |
| **Salesforce Einstein** | Salesforce | CRM native, customer data, no-code AI |
| **ServiceNow AI** | ServiceNow | IT/HR workflows, process automation |
| **Databricks** | Databricks | Open-source lakehouse, MLflow, DBRX model |
| **Snowflake Cortex** | Snowflake | In-warehouse AI on your own data |

---

## The "Build vs. Buy vs. Configure" Decision

**Build (custom models):**
- Train/fine-tune your own model
- Maximum control, maximum cost and expertise required
- When: unique data, extreme performance requirements, IP protection

**Buy (commercial APIs):**
- Use GPT-4, Claude, Gemini via API
- Fastest time-to-value, ongoing costs, data-sharing concerns
- When: general tasks, speed to market matters, no sensitive data constraints

**Configure (platform AI):**
- Use AI built into tools you already have (M365 Copilot, Salesforce Einstein)
- Lowest friction, limited customization
- When: team productivity use cases, non-technical users

---

<!-- _class: section-header -->

# 9. Summary & Key Takeaways

---

## Key Takeaways

**The AI Stack:**
- AI ⊃ ML ⊃ Deep Learning ⊃ Generative AI / LLMs
- Transformers + Attention + Scale = modern AI capabilities

**LLMs & SLMs:**
- LLMs: general, powerful, expensive, cloud-dependent
- SLMs: specialized, fast, cheap, privacy-preserving, on-device capable

**MCP:**
- Open standard for connecting AI models to tools and data sources
- Eliminates M×N integration problem for AI agents

**The Market:**
- OpenAI (pioneer, API), Anthropic (safety), Google (multimodal, scale), Meta (open-source), Microsoft (platform)
- Closed vs. open-source gap is narrowing rapidly

---

## Key Takeaways (continued)

**GPUs:**
- Neural network training/inference = matrix math → GPUs excel
- NVIDIA dominates with CUDA ecosystem (significant moat)
- Hardware cost is a major factor in AI economics

**Enterprise AI:**
- Not just "add ChatGPT to your website"
- Requires: governance, security, data strategy, integration, compliance
- RAG + fine-tuning for proprietary data
- Platform choice: Build / Buy / Configure

**What's coming:**
- Reasoning models (o1/o3 style "think before answering")
- Multimodal agents (see, hear, act, generate)
- Fully autonomous agentic systems
- On-device AI everywhere (SLMs on every phone/laptop)

---

## Glossary

| Term | Definition |
|------|-----------|
| **AI** | Artificial Intelligence — machines simulating human intelligence |
| **ML** | Machine Learning — systems that learn from data |
| **LLM** | Large Language Model — large transformer model for text generation |
| **SLM** | Small Language Model — compact LLM (≤10B parameters) |
| **MCP** | Model Context Protocol — standard for AI-tool integration |
| **RAG** | Retrieval-Augmented Generation — LLM + search over documents |
| **Embedding** | Dense vector representation of text capturing semantic meaning |
| **Token** | Unit of text processed by a model |
| **Fine-tuning** | Further training a pre-trained model on specific data |
| **RLHF** | Reinforcement Learning from Human Feedback — alignment technique |
| **Hallucination** | LLM generating confident but factually wrong information |
| **Agentic AI** | AI that plans and takes actions autonomously with tools |

---

<!-- _class: title -->

# Questions?

### Resources

- **OpenAI Platform** — platform.openai.com
- **Anthropic / Claude** — anthropic.com
- **Hugging Face** — huggingface.co
- **MCP Documentation** — modelcontextprotocol.io
- **Andrej Karpathy's AI tutorials** — karpathy.ai
- **"Attention Is All You Need"** — arxiv.org/abs/1706.03762
- **Microsoft AI** — ai.microsoft.com

---

*Presentation created for AI Fundamentals overview.*
*Content refreshed with public model information current as of March 2026. Frontier model names, pricing, and limits change quickly — verify vendor docs again before presenting.*
