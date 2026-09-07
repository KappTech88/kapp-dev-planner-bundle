---
name: drill-me
description: This skill should be used when the user asks to "drill me", "interrogate my idea", "ask me everything before we build", "requirements interview", or "/drill-me". It runs a Socratic requirements interview in rounds, including a tech-stack round that can scan the machine, assess fit, recommend a better option, and offer to install it, and writes docs/planning/00-brief.md.
argument-hint: <idea in a sentence, or a path to an existing repo>
disable-model-invocation: true
allowed-tools: [Read, Glob, Grep, Write, Edit, AskUserQuestion, Agent, TodoWrite]
---

# Drill Me — requirements interrogation

Interview the user until the project is understood well enough to write a PRD without
guessing. Ask, do not assume. Prefer AskUserQuestion with concrete options plus "Other"
so the user can answer fast, and follow up on anything vague.

## Setup

1. Run `${CLAUDE_PLUGIN_ROOT}/scripts/project-config.sh status`. If no project is
   configured, run `${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-project.sh` (for a brand-new
   idea with no repo yet, ask where the repo should live, `git init` it, then bootstrap).
2. Pull memory first: call the `brain_context_pack` MCP tool with the task
   "drill-me requirements interview" and the project name (fallback:
   `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . context-pack "drill-me requirements interview"`).
   If a brief already exists, read it and only ask about gaps and changes.
3. For an existing repo, launch two `codebase-scout` agents in parallel (one on
   architecture and entry points, one on build/test/deploy tooling), then read the files
   they name before asking questions. Use their findings to make questions specific.
4. Copy `${CLAUDE_PLUGIN_ROOT}/templates/brief.md` to `docs/planning/00-brief.md` if it
   does not exist, replacing `{{PROJECT}}` and `{{DATE}}`.

## Interview rounds

Run the rounds in this order; each round is one or two AskUserQuestion calls with 2–4
options plus free text. Skip a round only when the brief already answers it. The
question bank in `references/question-bank.md` lists follow-ups per round.

1. **Pitch and problem** — one-line pitch; what hurts today; what happens if nothing is built.
2. **Users** — personas, how often they hit the problem, their current workaround.
3. **Success** — two measurable outcomes; explicit non-goals.
4. **Scope** — in for v1, later, never. Push back on anything that makes v1 larger than a
   few weeks of work; ask what the smallest useful version is.
5. **Constraints** — time and budget, platform and deployment target, compliance and
   privacy, licensing, systems it must fit.
6. **Tech stack** — see the next section; it has a mandatory machine-scan option.
7. **Risks and unknowns** — what could sink it; what we do not know yet and how to find out.
8. **Wrap** — read back a ten-line summary and ask whether anything is wrong or missing.
   Repeat until the user says it is right.

Stop early when the user says "done" or "enough"; record the skipped rounds as open questions.

## Tech-stack round (machine scan)

Ask the stack question with these options, in this order:

- **Scan what's on this machine and advise me** — run
  `${CLAUDE_PLUGIN_ROOT}/scripts/machine-inventory.sh`. It is read-only and prints Markdown
  ending in `KDP_INVENTORY_OK`. If that line is missing, or no shell tool exists in this
  host, tell the user the scan needs a terminal-hosted agent and give the exact command to
  run in Claude Code or Grok Build; then continue with the remaining options.
- **I already know my stack** — take it as given and record why.
- **Recommend a stack without scanning** — recommend from the requirements alone.

After a scan, follow `references/stack-assessment.md`:
1. Summarize the inventory in ten lines or fewer (languages, runtimes, package managers,
   databases, containers, GPU if relevant, AI CLIs present).
2. Assess fit of what is installed against the requirements gathered so far: platform
   target, team familiarity, performance needs, ecosystem maturity, hosting.
3. If a materially better option exists, recommend it in one paragraph with the reason
   and the cost of switching. If the installed stack is fine, say so plainly.
4. Ask with AskUserQuestion: **keep the current stack** or **switch to the recommendation**.
5. If anything must be installed (a missing runtime, a newer version, a database), ask:
   **install it for me**, **I'll install it myself**, or **skip for now**. For
   "install it for me", show each command (pacman, yay, mise, or the ecosystem's own
   installer) before running it, run them one at a time, and verify with a version
   command. Never install without that explicit answer.
6. Write the inventory summary, assessment, recommendation, the user's choice, and the
   install outcome into the brief's "Tech stack" section.

## Brain writes

After each round, store durable answers as single memories using
`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . remember "<fact>" --type <decision|constraint|fact|bug|procedure> --pramana <sabda|pratyaksha|anumana> --priority <1-10>`:
`sabda` for what the user said, `pratyaksha` for what the scan observed (add
`--source-path docs/planning/00-brief.md`), `anumana` for your inferences. One fact per
call; no secrets. Aim for the ten most consequential facts, not a transcript.

At the end: run `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . ingest-repo`, then
`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . checkpoint --objective "Brief complete for <project>" --verified-evidence "docs/planning/00-brief.md written; <n> memories stored" --remaining-gaps "<open questions>" --next-action "Run /prd" --prohibited-repetition "Re-asking answered interview questions"`,
then `${CLAUDE_PLUGIN_ROOT}/scripts/project-config.sh set stage brief`.

## Output

`docs/planning/00-brief.md` filled in, the interview log condensed to the answers that
matter, open questions listed, and a closing message with the brief's path, the memory
count, and the suggestion to run `/prd`.
