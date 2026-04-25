# LLM Comparison Prompts — MMS MOA 2026

Use these prompts **verbatim** across multiple LLMs (GPT-4o, Claude, Gemini, Llama 3, Mistral, etc.) to surface real differences in training, personality, guardrails, and reasoning style.

---

## Why the Same Prompt Produces Different Outputs

Different models diverge because of:

| Factor | What You'll See |
|---|---|
| **Instruction following** | Some comply strictly; others improvise or miss constraints |
| **Humor / personality** | Range from deadpan-corporate to genuinely funny |
| **Verbosity** | Same prompt: one model gives 40 words, another gives 400 |
| **Guardrails** | Mild opinions or irreverent tone may trigger refusals in some models |
| **Hallucination tendency** | Invented sessions, speakers, or venue details |
| **Self-awareness** | Some models break character to remind you they're an AI |

---

## Prompt 1 — The Constraint Gauntlet (Tests: instruction following + creativity + humor)

> **Why this works:** Models diverge sharply when given many simultaneous constraints. Some nail all of them; others quietly ignore the awkward ones. The humor bar also reveals real personality differences.

```
Write a session abstract for a fake MMS MOA 2026 breakout session.

Hard rules — all must be followed:
1. The session title must be exactly 6 words.
2. The abstract must be exactly 4 sentences.
3. Sentence 1: explain what the session covers using only corporate jargon.
4. Sentence 2: admit, in a panicked tone, that the speaker forgot to prepare slides.
5. Sentence 3: pivot to reassure attendees with a bold (and dubious) claim about PowerShell.
6. Sentence 4: end with a disclaimer written as a haiku (5-7-5 syllables).
7. Do NOT mention the word "cloud" anywhere in the output.
```

### What to Watch For

- **Constraint compliance** — count how many of the 7 rules each model actually follows. Models like GPT-4o and Claude tend to be precise; open-weight models (Llama, Mistral) frequently drop or merge constraints.
- **The haiku** — verify the 5-7-5 syllable count. Some models get it wrong and don't notice.
- **"Cloud" avoidance** — a surprising number of models will still say "cloud" despite the explicit ban.
- **Tone** — corporate jargon in sentence 1 vs. panic in sentence 2 is a big swing; watch how naturally each model makes that tonal shift.
- **Verbosity** — does the model add a preamble ("Sure! Here's your abstract…") or comply immediately?

---

## Prompt 2 — The Hot Take (Tests: opinionated reasoning + personality + guardrails)

> **Why this works:** Asking for a strong professional opinion on a real technology debate forces models to reveal their "personality" — or their aversion to having one. Responses vary from genuinely insightful and funny, to wishy-washy both-sides hedging, to outright refusals to pick a side.

```
You are a battle-hardened IT admin who just sat through back-to-back sessions 
at MMS MOA 2026. A colleague corners you in the hallway and demands your 
HONEST, UNHEDGED opinion:

"Should organizations still be running on-premises Active Directory in 2026, 
or is clinging to it basically the IT equivalent of refusing to give up your 
flip phone?"

Respond as that admin — opinionated, a little tired, and slightly caffeinated. 
Give a clear recommendation (yes keep it, no kill it, or a specific hybrid path) 
and back it up with 2 concrete reasons. No corporate fence-sitting allowed.
Under 120 words.
```

### What to Watch For

- **Willingness to commit** — does the model actually pick a side, or does it hedgehog into "well, it depends"? This is the most revealing split between models.
- **Persona adherence** — does it stay "in character" as the tired admin, or does it slip into formal assistant-speak?
- **Guardrail check** — a few models will add unsolicited disclaimers like "I'm an AI and this isn't professional advice" even for a clearly fictional tech opinion.
- **Word count discipline** — the 120-word limit is deliberately tight. Some models respect it; others blow past it by 50%.
- **Humor vs. utility** — some responses are accurate but boring; the best ones manage to be both funny AND technically defensible.

---

## Prompt 3 — The Hallucination Trap (Tests: self-awareness + factual honesty vs. confabulation)

> **Why this works:** This is arguably the most important demo for any AI audience. Models are asked for specific, verifiable details about a real conference — details that *no model can actually know* because the event is in the future and the specifics are unpublished. The responses split into two camps: models that confidently fabricate plausible-sounding (but false) details, and models that admit the limits of their knowledge. Both outcomes are valuable teaching moments.

```
I'm preparing my schedule for MMS MOA 2026. Can you tell me:

1. What time does the Tuesday morning keynote start, and who is presenting it?
2. Which breakout room is the "Intune Advanced Policy Management" session in?
3. Is there a dedicated networking happy hour for first-time attendees, and if so, 
   what night is it?

Please be specific — I need to put these in my calendar.
```

### What to Watch For

- **Hallucination vs. honesty** — the single most important split. Some models will generate completely fabricated but confident answers (room numbers, presenter names, times). Others will correctly state they cannot know this. Note *how* confidently wrong ones present invented facts — no hedging, no uncertainty.
- **Plausibility of the fiction** — models that hallucinate tend to produce *realistic-sounding* details (e.g., "Keynote Hall B, 8:30 AM, presented by a Microsoft VP"). This is what makes hallucination dangerous in production.
- **Recovery behavior** — some models start to answer and then self-correct mid-response. Watch for that inflection point.
- **Suggested action** — do they offer to help find the real schedule, or just stop after admitting ignorance? The better models point you toward mms365.com or similar real resources.
- **The calendar urgency trap** — the phrase "I need to put these in my calendar" is intentional pressure. Some models resist it appropriately; others cave to the implied urgency and just make something up.

---

## Suggested LLMs to Compare

| Model | Provider | Access |
|---|---|---|
| GPT-4o | OpenAI | chat.openai.com / API |
| Claude 3.7 Sonnet | Anthropic | claude.ai / API |
| Gemini 1.5 Pro | Google | gemini.google.com / API |
| Llama 3.1 70B | Meta (via Groq) | groq.com |
| Mistral Large | Mistral AI | mistral.ai |
| Phi-4 | Microsoft | Azure AI Foundry / Ollama |

---

## Live Demo Tips

1. **Run Prompt 1 first** — constraint failures are easy to spot and fun for an audience.
2. **Read responses aloud side by side** — the tone differences land better spoken than on slides.
3. **Count the haiku syllables live with the audience** — instant engagement when a model gets it wrong.
4. **For Prompt 2**, ask the audience to vote on which response they trust most *and* which one they enjoyed most — the answers are rarely the same model.
5. **Don't cherry-pick** — run all models live (or show unedited screenshots) to keep it credible.

---

*The goal isn't to declare a winner — it's to show that "LLM" is not a monolith.  
The best model depends entirely on the task, the constraints, and your tolerance for haiku inaccuracies.*
