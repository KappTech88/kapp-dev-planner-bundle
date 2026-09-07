---
name: plan
description: This skill should be used when the user asks to "write the implementation plan", "design the architecture", "how should we build this", "compare approaches", or "/plan". It has three planning-critic agents propose architectures with different biases (minimal, clean, pragmatic), synthesizes a recommendation, lets the user choose, and writes docs/planning/03-plan.md with sequencing, verification strategy, and risks, checkpointed in Rta-Smriti Brain.
argument-hint: [constraints or preferred approach]
disable-model-invocation: true
allowed-tools: [Read, Glob, Grep, Write, Edit, AskUserQuestion, Agent, TodoWrite]
---

# Plan — implementation plan

Decide how the project will be built before any code is written: architecture, repo
layout, order of work, and how each step is verified. Compare real alternatives instead of
presenting the first idea as the only one.

## Setup

1. Run `${CLAUDE_PLUGIN_ROOT}/scripts/project-config.sh status`. Require `01-prd.md` and
   `02-tasks.md`; if either is missing, offer the earlier step and stop. If no project is
   configured, run `${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-project.sh`.
2. Call `brain_context_pack` (task "design the implementation plan") or the CLI fallback
   `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . context-pack "design the implementation plan"`.
   For an existing repo also call `brain_repo_map` and `brain_stale_check`; if the index is
   stale, run `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . ingest-repo` first.
3. Read `00-brief.md`, `01-prd.md`, `02-tasks.md`. Note the stack decision and the machine
   inventory constraints (installed versions, hosting) from the brief.
4. Copy `${CLAUDE_PLUGIN_ROOT}/templates/plan.md` to `docs/planning/03-plan.md` if absent,
   replacing placeholders.

## Explore options in parallel

Launch three `planning-critic` agents in one message, each with the same inputs (paths of
the three artifacts, the stack decision, any constraint the user typed after the command)
and a different bias:

- **minimal change / fastest path**: fewest moving parts, reuse what exists, ship Milestone 0 soonest.
- **clean architecture**: clear boundaries, testability, room to grow; accept more upfront structure.
- **pragmatic balance**: the version a senior engineer would defend in review.

Ask each to return: proposed architecture (components, data flow, storage), repo layout,
the order the tasks should be tackled, verification approach, top three risks, and what
this option gives up. Read the files they reference before judging.

## Synthesize and choose

Write the Alternatives table with strengths and weaknesses stated concretely. Recommend
one option in a paragraph and say what it gives up. Ask the user with AskUserQuestion:
the recommended option first, the other two, and "blend" with a note field. Record the
choice and the reason in the Decision log.

## Fill the plan

Architecture, repository layout, sequencing table (each phase lists task IDs and an exit
criterion that is observable), verification strategy (what is automated, what stays
manual and why, definition of done), environment and tooling (exact setup commands and
versions taken from the inventory), risks with early signals, and the first three actions
with task IDs. Every section must be specific to this project; delete template text that
does not apply rather than leaving placeholders.

## Brain writes

`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . remember "Architecture: <chosen option in one sentence>" --type decision --pramana sabda --priority 9 --source-path docs/planning/03-plan.md`,
one memory per rejected alternative with its reason (`--type decision --pramana anumana --priority 4`),
one `constraint` memory per version or hosting constraint the plan depends on,
`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . ingest-repo`, `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . reflect`, then
`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . checkpoint --objective "Implementation plan complete for <project>" --verified-evidence "docs/planning/03-plan.md; option <name> chosen by user" --remaining-gaps "<risks without mitigation, open questions>" --next-action "Start <first task ID> per docs/planning/03-plan.md §10" --prohibited-repetition "Re-opening the architecture choice without new evidence"`,
then `${CLAUDE_PLUGIN_ROOT}/scripts/project-config.sh set stage plan`.

## Output

`docs/planning/03-plan.md`, and a chat summary: chosen option and why in two lines, the
first three actions, and a reminder that this bundle stops at planning; implementation
proceeds normally with the brain's checkpoint as the handoff.
