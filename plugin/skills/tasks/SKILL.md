---
name: tasks
description: This skill should be used when the user asks to "break this into tasks", "generate the task list", "decompose the PRD", "create milestones", or "/tasks". It turns docs/planning/01-prd.md into docs/planning/02-tasks.md: milestones and sized tasks with acceptance criteria, dependencies, verification steps, and evidence slots, and checkpoints the result in Rta-Smriti Brain.
argument-hint: [milestone focus or sizing constraints]
disable-model-invocation: true
allowed-tools: [Read, Glob, Grep, Write, Edit, AskUserQuestion, Agent, TodoWrite]
---

# Tasks — decomposition

Produce a task list where every item is small enough to finish and verify in a sitting,
traces to a PRD requirement, and says how it will be proven done.

## Setup

1. Run `${CLAUDE_PLUGIN_ROOT}/scripts/project-config.sh status`. Require `01-prd.md`;
   if missing, offer `/prd` and stop. If no project is configured, run
   `${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-project.sh`.
2. Call `brain_context_pack` (task "decompose the PRD into tasks") or the CLI fallback
   `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . context-pack "decompose the PRD into tasks"`.
3. Read `01-prd.md` and `00-brief.md`. For an existing repo, also call `brain_repo_map`
   (or `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . graph`) to see which modules already exist,
   so tasks say "extend X" rather than "create X".
4. Copy `${CLAUDE_PLUGIN_ROOT}/templates/tasks.md` to `docs/planning/02-tasks.md` if
   absent, replacing placeholders. If it exists, keep task IDs stable; add, never renumber.

## Decompose

- **Milestone 0 is always a walking skeleton**: the thinnest end-to-end path (build, run,
  one real request or interaction, one test, one deploy or packaging step). Everything
  else builds on it.
- Group remaining Must requirements into milestones that each deliver something a user
  could try. Should and Could requirements go to later milestones or the parking lot.
- Each task: stable ID, size S/M/L (split anything larger than L), the FR/US it
  satisfies, dependencies by ID, "Done when" in observable terms, "Verify" as a command
  or a manual check, an empty "Evidence" slot.
- Add cross-cutting tasks (CI, README, error handling, logging, security basics) unless
  the PRD excludes them.
- Draw the dependency graph; check it has no cycles and that Milestone 0 has no
  dependencies outside itself.
- Ask the user with AskUserQuestion only when a decomposition choice changes the order of
  milestones (for example, "auth first or data model first?"). Otherwise decide and note
  the reason in the parking lot.

## Sanity pass

Count the tasks per milestone. If Milestone 0 exceeds about eight tasks or any milestone
exceeds fifteen, split the milestone. If any Must requirement has no task, add one. If any
task has no FR/US, either link it or move it to the parking lot.

## Brain writes

`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . remember "Milestone plan: <one line per milestone>" --type procedure --pramana anumana --priority 7 --source-path docs/planning/02-tasks.md`,
one `decision` memory per ordering choice the user made (`--pramana sabda`),
`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . ingest-repo`, then
`${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . checkpoint --objective "Task list complete for <project>" --verified-evidence "docs/planning/02-tasks.md: <n> tasks in <m> milestones, all Musts covered" --remaining-gaps "<parking lot summary>" --next-action "Run /plan" --prohibited-repetition "Renumbering task IDs"`,
then `${CLAUDE_PLUGIN_ROOT}/scripts/project-config.sh set stage tasks`.

## Output

`docs/planning/02-tasks.md`, plus a chat summary: milestones with task counts, the first
three task IDs, and the next step `/plan`.
