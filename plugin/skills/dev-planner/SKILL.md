---
name: dev-planner
description: This skill should be used when the user asks to "plan a new project", "start a project the right way", "run the dev planner", "take me from idea to plan", or "/dev-planner". It orchestrates drill-me → PRD → tasks → plan with a gate between steps, resuming from the first missing artifact in docs/planning/, and keeps Rta-Smriti Brain memory up to date.
argument-hint: <idea in a sentence, or a path to an existing repo>
disable-model-invocation: true
allowed-tools: [Read, Glob, Grep, Write, Edit, AskUserQuestion, Agent, TodoWrite, Skill]
---

# Dev Planner (umbrella)

Run the whole front-loaded planning workflow for a dev project, in order, with the user
approving each stage before the next one starts. The four stages each exist as their own
skill and can be run alone; this skill sequences them and keeps them honest.

## Recommendation shown once at the start

State this in one short paragraph before anything else: run the coding agent from a
**terminal CLI** (Claude Code, Grok Build, or Cursor's CLI agent) rather than an IDE chat
pane for the best system vision. A CLI host has shell access, so it can inventory the
machine, verify versions, install toolchains, bootstrap the project brain, and run
verification commands itself. An IDE chat pane usually cannot. If the current host has no
shell tool, say so, and tell the user which steps will be degraded (machine scan, installs,
brain writes).

## Inputs

The text after the command is either a one-sentence idea or a path to an existing repo.
If nothing was given, ask for one of the two with AskUserQuestion. In Cursor there is no
argument substitution; treat the rest of the user's message as the input.

## Procedure

1. **Locate the project.** Run `${CLAUDE_PLUGIN_ROOT}/scripts/project-config.sh status`
   from the repo (or the directory the user named; for a fresh idea, ask where the repo
   should live, `git init` it if needed, and continue there). The status lists which of
   `00-brief.md`, `01-prd.md`, `02-tasks.md`, `03-plan.md` exist under `docs/planning/`.
2. **Bootstrap memory if missing.** If the status shows no project, run
   `${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap-project.sh` (optionally `--project <name>`).
   This creates the Rta-Smriti brain, indexes the repo, and writes `docs/planning/.brain.json`.
3. **Resume from the first missing artifact.** Show the user a four-line checklist of the
   stages with done/pending marks and confirm the starting point with AskUserQuestion
   (options: start at the first pending stage, or redo an earlier one).
4. **Run the stages** by invoking the matching skill with the Skill tool, in this order:
   `drill-me` → `prd` → `tasks` → `plan`. Do not paraphrase a stage inline; each skill owns
   its questions, its template, and its brain writes.
5. **Gate between stages.** After each stage finishes, summarize its output in five lines
   or fewer and ask: continue to the next stage, revise this one, or stop here. Never
   start the next stage without an explicit "continue".
6. **Close.** After `/plan`, print the paths of the four artifacts, the brain checkpoint's
   "next action", and remind the user that implementation is done normally from here
   (this bundle is planning only). Write a final checkpoint with
   `${CLAUDE_PLUGIN_ROOT}/scripts/brain.sh . checkpoint --objective "Planning complete for <project>" --verified-evidence "00–03 written and reviewed" --remaining-gaps "<open questions from 03-plan.md>" --next-action "Start T-001 from docs/planning/02-tasks.md" --prohibited-repetition "Re-running the planning stages without new information"`.

## Rules

- Use TodoWrite to track the four stages so the user sees progress.
- Read the existing artifacts before redoing a stage; carry forward decisions unless the
  user changes them, and record any change as a new `sabda` memory via the `brain` skill.
- Keep the brain in sync: every stage's skill already writes memories and a checkpoint;
  do not duplicate those writes here.
- Never invent answers for the user. Unknowns go into the "Open questions" section of the
  current artifact and into `--remaining-gaps` of the checkpoint.
