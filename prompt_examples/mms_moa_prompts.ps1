#Requires -Version 7.0
<#
.SYNOPSIS
    Steps through key AI prompt types, all themed around MMS MOA 2026.

.DESCRIPTION
    Each section demonstrates a distinct prompting strategy against the OpenAI
    Chat Completions API.  The conference theme is Midwest Management Summit at
    the Mall of America (Bloomington, MN) – May 2026.

.NOTES
    Prerequisites
    -------------
    • PowerShell 7+
    • Environment variable  OPENAI_API_KEY  must be set before running.
      Example:
          $env:OPENAI_API_KEY = "sk-..."
    • Internet access to api.openai.com
#>

# ---------------------------------------------------------------------------
# GLOBAL SETUP
# ---------------------------------------------------------------------------

$ApiKey  = $env:OPENAI_API_KEY
$ApiUrl  = "https://api.openai.com/v1/chat/completions"
$Model   = "gpt-4o"

if (-not $ApiKey) {
    Write-Error "Environment variable OPENAI_API_KEY is not set. Exiting."
    exit 1
}

$Headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type"  = "application/json"
}

# Helper: send a request and return the assistant reply text
function Invoke-ChatCompletion {
    param(
        [Parameter(Mandatory)]
        [array]  $Messages,          # array of @{role=...; content=...}
        [int]    $MaxTokens = 400,
        [double] $Temperature = 0.9
    )

    $Body = @{
        model       = $Model
        messages    = $Messages
        max_tokens  = $MaxTokens
        temperature = $Temperature
    } | ConvertTo-Json -Depth 10

    try {
        $Response = Invoke-RestMethod -Uri $ApiUrl `
                                      -Method Post `
                                      -Headers $Headers `
                                      -Body $Body `
                                      -ErrorAction Stop
        return $Response.choices[0].message.content.Trim()
    }
    catch {
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Write-Warning "API call failed (HTTP $StatusCode): $($_.Exception.Message)"
        return $null
    }
}

# Helper: section banner
function Show-Banner {
    param([string]$Title, [string]$Description)
    $Width = 70
    Write-Host ""
    Write-Host ("=" * $Width) -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "  $Description" -ForegroundColor Gray
    Write-Host ("=" * $Width) -ForegroundColor Cyan
}

# Helper: display the prompt and result
function Show-PromptAndResult {
    param([string]$PromptLabel, [string]$PromptText, [string]$Result)
    Write-Host ""
    Write-Host "PROMPT:" -ForegroundColor Green
    Write-Host $PromptText -ForegroundColor White
    Write-Host ""
    Write-Host "RESPONSE:" -ForegroundColor Magenta
    Write-Host $Result -ForegroundColor White
}

# Pause between demos so the presenter can breathe
function Pause-ForPresenter {
    Write-Host ""
    Write-Host "  [ Press ENTER to continue to the next prompt type... ]" `
               -ForegroundColor DarkYellow
    $null = Read-Host
}


# ===========================================================================
# 1. ZERO-SHOT PROMPT
#    No examples – pure model knowledge.
# ===========================================================================
Show-Banner "1 · Zero-Shot Prompt" `
            "No examples. Just ask. Model relies on pre-trained knowledge."

$ZeroShotPrompt = @"
MMS MOA 2026 is a Microsoft endpoint-management and Azure conference held at the
Mall of America in Bloomington, MN.

Write a single, funny out-of-office email auto-reply that an IT admin
would set when attending MMS MOA 2026.  Keep it under 80 words.
"@

$Messages = @(
    @{ role = "user"; content = $ZeroShotPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages
Show-PromptAndResult -PromptLabel "Zero-Shot" `
                     -PromptText  $ZeroShotPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 2. ONE-SHOT PROMPT
#    One example establishes the desired format/style.
# ===========================================================================
Show-Banner "2 · One-Shot Prompt" `
            "One example nudges the model toward a specific format."

$OneShotPrompt = @"
Convert a conference session title into a dramatic movie-trailer tagline.

Session title: "Zero Trust in a Hybrid World"
Tagline: "In a world where nobody trusts the VPN... one admin dared to believe."

Session title: "Mastering Intune at MMS MOA 2026"
Tagline:
"@

$Messages = @(
    @{ role = "user"; content = $OneShotPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages
Show-PromptAndResult -PromptLabel "One-Shot" `
                     -PromptText  $OneShotPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 3. FEW-SHOT PROMPT
#    Multiple examples teach a strong pattern.
# ===========================================================================
Show-Banner "3 · Few-Shot Prompt" `
            "2+ examples establish a clear pattern for the model to follow."

$FewShotPrompt = @"
Turn each MMS MOA 2026 session title into a humorous country-song title.

Session: "Autopilot Deep Dive"          → Country song: "Drove My Laptop to the Cloud (And It Never Came Back)"
Session: "ConfigMgr Migration Tricks"   → Country song: "Baby, Please Don't Deprecate Me"
Session: "Windows 11 Readiness"         → Country song: "Eleven Reasons My Blue-Screen Broke My Heart"

Session: "Azure Cost Management and You"  → Country song:
"@

$Messages = @(
    @{ role = "user"; content = $FewShotPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages
Show-PromptAndResult -PromptLabel "Few-Shot" `
                     -PromptText  $FewShotPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 4. SYSTEM PROMPT
#    Hidden meta-instruction that sets persona, tone, and rules.
# ===========================================================================
Show-Banner "4 · System Prompt" `
            "Sets the model's role and constraints for the whole conversation."

$SystemInstruction = @"
You are the official (and slightly snarky) AI concierge for MMS MOA 2026,
held at the Mall of America.  Your job is to answer attendee questions with
technically accurate but humorously over-dramatic responses.
- Always end every reply with a cheese-curd-related sign-off.
- Never say the words 'synergy' or 'leverage'.
- Keep responses under 120 words.
"@

$UserQuestion = "Where is the best place to get lunch near the conference?"

$Messages = @(
    @{ role = "system"; content = $SystemInstruction }
    @{ role = "user";   content = $UserQuestion }
)

$DisplayPrompt = @"
[SYSTEM]: $SystemInstruction

[USER]: $UserQuestion
"@

$Result = Invoke-ChatCompletion -Messages $Messages
Show-PromptAndResult -PromptLabel "System Prompt" `
                     -PromptText  $DisplayPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 5. ROLE / PERSONA PROMPT
#    Tell the model to embody a specific character.
# ===========================================================================
Show-Banner "5 · Role / Persona Prompt" `
            "Model adopts a specific expert identity or character."

$RolePrompt = @"
You are Minnesota's most dramatically enthusiastic IT podcast host.
You have just attended the final closing session at MMS MOA 2026 and your mind is blown.
Record a 4-sentence hype segment for your podcast listeners, referencing
at least one specific Microsoft product and one Minnesota stereotype.
"@

$Messages = @(
    @{ role = "user"; content = $RolePrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages
Show-PromptAndResult -PromptLabel "Role/Persona" `
                     -PromptText  $RolePrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 6. CHAIN-OF-THOUGHT (CoT) PROMPT
#    Model shows step-by-step reasoning before the final answer.
# ===========================================================================
Show-Banner "6 · Chain-of-Thought Prompt" `
            "Ask the model to reason step by step for better accuracy."

$CoTPrompt = @"
At MMS MOA 2026 the speaker table has 8 seats.
Each seat can hold 2 people, 2 laptops, 1 bag of M&Ms, and 3 USB hubs.  And at least 2 cans of Monster or Liquid Death.
Every USB hub supports 4 devices.

If every seat is occupied and each person plugs in exactly 2 devices,
will there be enough USB ports for everyone?

Think through this step by step before giving your final (comedic) verdict.
"@

$Messages = @(
    @{ role = "user"; content = $CoTPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages -MaxTokens 600 -Temperature 0.7
Show-PromptAndResult -PromptLabel "Chain-of-Thought" `
                     -PromptText  $CoTPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 7. ZERO-SHOT CHAIN-OF-THOUGHT
#    Same idea as CoT but triggered by "Think step by step" alone – no examples.
# ===========================================================================
Show-Banner "7 · Zero-Shot Chain-of-Thought" `
            "'Think step by step' appended with no examples."

$ZeroShotCoTPrompt = @"
An IT admin at MMS MOA 2026 has 45 minutes between sessions.
The Lego Store is a 7-minute walk, the food court is 4 minutes away,
and the Intune lab requires 20 minutes to complete.
He also wants at least 5 minutes to panic-check his work email.

Can he do all four things?  Think step by step.
"@

$Messages = @(
    @{ role = "user"; content = $ZeroShotCoTPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages -MaxTokens 500 -Temperature 0.7
Show-PromptAndResult -PromptLabel "Zero-Shot CoT" `
                     -PromptText  $ZeroShotCoTPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 8. INSTRUCTION / DIRECTIVE PROMPT
#    Explicit command with tight formatting constraints.
# ===========================================================================
Show-Banner "8 · Instruction / Directive Prompt" `
            "Precise command + explicit format + hard constraints."

$InstructionPrompt = @"
Write the MMS MOA 2026 official conference FAQ.

Rules:
- Exactly 4 Q&A pairs.
- Each question must be something a panicking first-time attendee would ask.
- Each answer must be helpful BUT include at least one unnecessary mention of
  the Mall of America roller coaster.
- Use the format:
    Q: <question>
    A: <answer>
- Total response must be under 200 words.
"@

$Messages = @(
    @{ role = "user"; content = $InstructionPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages -MaxTokens 500
Show-PromptAndResult -PromptLabel "Instruction/Directive" `
                     -PromptText  $InstructionPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 9. CONTEXTUAL / GROUNDED PROMPT
#    Model must answer using only provided context (RAG-style).
# ===========================================================================
Show-Banner "9 · Contextual / Grounded Prompt" `
            "Answer must be grounded in the supplied context. Prevents hallucination."

$Context = @"
MMS MOA 2026 OFFICIAL SNIPPET
------------------------------
Dates      : May 4–7, 2026
Venue      : Mall of America, Bloomington, MN
Theme      : "Manage Everything, Fear Nothing"
Keynote    : Monday May 4 at 8:30 AM in the Keynote Hall (Level 3 North)
Wi-Fi      : SSID = MMS2026 | Password = AzureRocks!
Dress code : Business casual; hoodies strongly encouraged
Parking    : Free in MOA Ramp A with conference badge
"@

$GroundedQuestion = @"
Use ONLY the information above to answer: 
What should I wear to MMS MOA 2026, and can I park for free?
If the information is not in the context, say 'I don't know.'
"@

$Messages = @(
    @{ role = "user"; content = "CONTEXT:`n$Context`n`nQUESTION:`n$GroundedQuestion" }
)

$DisplayPrompt = @"
CONTEXT:
$Context

QUESTION:
$GroundedQuestion
"@

$Result = Invoke-ChatCompletion -Messages $Messages -MaxTokens 300 -Temperature 0.5
Show-PromptAndResult -PromptLabel "Contextual/Grounded" `
                     -PromptText  $DisplayPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 10. CONSTRAINT / NEGATIVE PROMPT
#     Explicit list of things the model must NOT do.
# ===========================================================================
Show-Banner "10 · Constraint / Negative Prompt" `
            "Explicitly define what NOT to do to shape the output."

$ConstraintPrompt = @"
Write a 5-sentence hype description for the MMS MOA 2026 conference.

Constraints – do NOT:
- Use the words 'amazing', 'exciting', 'innovative', or 'game-changer'.
- Mention the Mall of America's famous Nickelodeon Universe park.
- Use any exclamation marks.
- Exceed 80 words.
"@

$Messages = @(
    @{ role = "user"; content = $ConstraintPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages -MaxTokens 300 -Temperature 0.8
Show-PromptAndResult -PromptLabel "Constraint/Negative" `
                     -PromptText  $ConstraintPrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 11. TEMPLATE / FILL-IN-THE-BLANK PROMPT
#     Provide the skeleton; ask the model to fill in the blanks.
# ===========================================================================
Show-Banner "11 · Template / Fill-in-the-Blank Prompt" `
            "Supply a structure; let the model fill in consistent content."

$TemplatePrompt = @"
Complete the following MMS MOA 2026 conference tweet template.
Replace every [PLACEHOLDER] with appropriate (funny) content.

---
Just landed at [CITY_AIRPORT] for #MMSMOA2026.
My bag contains: [TECH_ITEM_1], [TECH_ITEM_2], and an embarrassing number of [SNACK].
First session I'm hitting: "[FAKE_BUT_PLAUSIBLE_SESSION_TITLE]"
Hoping to finally understand [CONFUSING_MICROSOFT_FEATURE].
Send help—and Wi-Fi.
---
"@

$Messages = @(
    @{ role = "user"; content = $TemplatePrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages -MaxTokens 250
Show-PromptAndResult -PromptLabel "Template/Fill-in-Blank" `
                     -PromptText  $TemplatePrompt `
                     -Result      $Result

Pause-ForPresenter


# ===========================================================================
# 12. META-PROMPT / PROMPT GENERATOR
#     Ask the model to write a prompt for you.
# ===========================================================================
Show-Banner "12 · Meta-Prompt / Prompt Generator" `
            "Ask the model to write a better prompt on your behalf."

$MetaPrompt = @"
Write a detailed system prompt for an AI assistant whose sole purpose is
to help confused IT admins survive their first MMS MOA 2026 conference.

The assistant should:
- Have a warm, mildly sarcastic personality.
- Know the conference schedule, networking tips, and nearby food options.
- Enforce the rule that no attendee leaves without visiting at least one
  hands-on lab.
- Politely refuse to discuss anything unrelated to the conference or
  Microsoft endpoint management.

Output only the system prompt text – no explanation needed.
"@

$Messages = @(
    @{ role = "user"; content = $MetaPrompt }
)

$Result = Invoke-ChatCompletion -Messages $Messages -MaxTokens 500 -Temperature 0.8
Show-PromptAndResult -PromptLabel "Meta-Prompt" `
                     -PromptText  $MetaPrompt `
                     -Result      $Result


# ===========================================================================
# WRAP-UP
# ===========================================================================
Write-Host ""
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "  All prompt types demonstrated – see you at MMS MOA 2026!" -ForegroundColor Yellow
Write-Host "  (Hopefully your Intune policies deploy faster than you found" -ForegroundColor Gray
Write-Host "   a parking spot at the Mall of America.)" -ForegroundColor Gray
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host ""
