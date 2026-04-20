# Types of AI Prompts

A **prompt** is the input you give to an AI model to guide its response. The structure and strategy behind a prompt dramatically affects the quality and usefulness of the output. Below is a reference guide to the most common and effective prompt types.

---

## 1. Zero-Shot Prompt

Ask the model to perform a task with **no examples**. Relies entirely on the model's pre-trained knowledge.

**When to use:** Simple, well-defined tasks the model handles well out of the box.

```
Translate the following sentence to Spanish:
"The meeting starts at 9am."
```

---

## 2. One-Shot Prompt

Provide **one example** before asking the model to do the same thing.

**When to use:** When you want to nudge the model toward a specific format or style.

```
English: "The cat is on the roof."
Spanish: "El gato está en el techo."

English: "The meeting starts at 9am."
Spanish:
```

---

## 3. Few-Shot Prompt

Provide **two or more examples** to establish a strong pattern before the actual request.

**When to use:** Structured outputs, custom classification, tone matching, or teaching the model a domain-specific format.

```
Review: "Amazing product, works perfectly!" → Sentiment: Positive
Review: "Broke after one day, waste of money." → Sentiment: Negative
Review: "It's fine, nothing special." → Sentiment: Neutral

Review: "Best purchase I've made all year!" → Sentiment:
```

---

## 4. System Prompt

A **meta-instruction** (usually hidden from the end user) that sets the model's role, persona, tone, and constraints for the entire conversation.

**When to use:** Building chatbots, agents, or assistants with a specific personality or set of rules.

```
You are a concise IT helpdesk assistant. 
- Always reply in plain English, no jargon.
- If you do not know the answer, say so and escalate to a human.
- Never discuss topics unrelated to IT support.
```

---

## 5. Role / Persona Prompt

Tell the model to **act as a specific person, expert, or character** to shape its perspective and vocabulary.

**When to use:** Getting expert-level explanations, creative writing, interview prep, red-teaming.

```
You are a senior cybersecurity engineer with 15 years of experience.
Explain SQL injection to a junior developer who just joined the team.
```

---

## 6. Chain-of-Thought (CoT) Prompt

Instruct the model to **show its reasoning step by step** before giving the final answer. Dramatically improves accuracy on logic, math, and multi-step problems.

**When to use:** Math problems, logical deduction, planning, debugging.

```
A store sells apples for $0.50 each and oranges for $0.75 each.
Sarah buys 4 apples and 3 oranges. How much does she spend in total?

Think through this step by step before giving the answer.
```

> **Tip:** Simply adding *"Let's think step by step"* to any prompt often improves results.

---

## 7. Zero-Shot Chain-of-Thought

A zero-shot variant of CoT — no examples, just the phrase **"Think step by step"** appended to the prompt.

```
Is 17 a prime number? Think step by step.
```

---

## 8. Instruction / Directive Prompt

A direct command that specifies exactly **what to do, how to format it, and any constraints**.

**When to use:** Content generation, summarisation, data transformation, code tasks.

```
Summarise the following article in exactly 3 bullet points.
Each bullet must be under 20 words.
Do not include any introductory sentence.

[article text here]
```

---

## 9. Contextual / Grounded Prompt

Provide **background context or source material** the model must use to answer. Prevents hallucination by anchoring the model to real data.

**When to use:** RAG (Retrieval-Augmented Generation) pipelines, document Q&A, customer support bots with knowledge bases.

```
Use only the information below to answer the question. 
If the answer is not in the provided text, say "I don't know."

CONTEXT:
[paste document excerpt here]

QUESTION: What is the refund policy for digital downloads?
```

---

## 10. Constraint / Negative Prompt

Explicitly tell the model **what NOT to do**.

**When to use:** Safety guardrails, output formatting, keeping responses focused.

```
Explain quantum entanglement.
- Do NOT use mathematical equations.
- Do NOT exceed 150 words.
- Do NOT use analogies involving cats.
```

---

## 11. Template / Fill-in-the-Blank Prompt

Provide a **partial template** and ask the model to complete it.

**When to use:** Generating consistent structured content at scale (emails, reports, job descriptions).

```
Write a professional LinkedIn post announcing a new product launch.
Use this structure:

Hook: [one attention-grabbing sentence]
Problem: [the problem the product solves]
Solution: [what the product does]
Call to action: [what readers should do next]
Hashtags: [3–5 relevant hashtags]
```

---

## 12. ReAct Prompt (Reason + Act)

A pattern used in **AI agents** where the model alternates between reasoning about a problem and deciding which tool or action to invoke next.

**When to use:** Agentic workflows, tool-use (search, code execution, APIs), multi-step tasks.

```
You have access to the following tools:
- search(query) — searches the web
- calculator(expression) — evaluates math

Question: What is the population of Tokyo multiplied by 2?

Thought: I need to find the population of Tokyo first.
Action: search("current population of Tokyo")
Observation: Tokyo's population is approximately 13.96 million.
Thought: Now I'll multiply that by 2.
Action: calculator("13960000 * 2")
Observation: 27920000
Answer: 27,920,000
```

---

## 13. Self-Consistency Prompt

Ask the model to **generate multiple independent reasoning paths** for the same question, then select the most consistent answer. Usually done programmatically.

**When to use:** High-stakes decisions, fact checking, reducing hallucination on reasoning tasks.

```
Answer the following question three times independently, 
using different reasoning each time, then state which 
answer appears most consistently.

Question: Should a small business adopt a microservices architecture?
```

---

## 14. Meta-Prompt / Prompt Generator

Ask the model to **write a prompt** for you.

**When to use:** Bootstrapping prompt engineering, building prompt libraries, teaching prompt writing.

```
Write a detailed system prompt for an AI assistant that helps 
junior developers review pull requests. It should enforce 
best practices for security, readability, and performance.
```

---

## Quick Reference

| Type | Key Idea | Best For |
|---|---|---|
| Zero-Shot | No examples | Simple, clear tasks |
| One-Shot | 1 example | Light formatting guidance |
| Few-Shot | 2+ examples | Pattern matching, custom formats |
| System | Sets persona & rules | Chatbots, agents |
| Role / Persona | Acts as an expert | Deep explanations, creative tasks |
| Chain-of-Thought | Show your reasoning | Math, logic, complex decisions |
| Zero-Shot CoT | "Think step by step" | Quick reasoning boost |
| Instruction | Direct command + constraints | Generation, summarisation |
| Contextual | Grounded in source data | RAG, Q&A, document chat |
| Constraint | Define what NOT to do | Safety, focus, format control |
| Template | Fill-in-the-blank structure | Consistent bulk content |
| ReAct | Reason → Act → Observe | AI agents with tools |
| Self-Consistency | Multiple reasoning paths | High-accuracy tasks |
| Meta-Prompt | Model writes the prompt | Prompt engineering, automation |

---

*Good prompting is iterative — start simple, observe results, then layer in examples, constraints, and personas as needed.*
