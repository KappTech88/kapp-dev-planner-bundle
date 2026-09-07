# Tasks: {{PROJECT}}

_Produced by `/tasks` on {{DATE}} from `01-prd.md`. Check items off as they are verified, not merely written. IDs are stable; never renumber._

## Conventions
- Size: S (≤2h), M (≤1 day), L (2–3 days). Anything larger must be split.
- Each task lists the PRD requirement it satisfies and how it is verified.
- "Evidence" is filled in when done: a test name, command output, or screenshot path.

## Milestone 0: Walking skeleton
- [ ] **T-001** (S) <title> — satisfies FR-…; depends on: none
  - Done when: …
  - Verify: …
  - Evidence:

## Milestone 1: <name>
- [ ] **T-010** (M) …
  - Done when:
  - Verify:
  - Evidence:

## Milestone 2: <name>
- [ ] **T-020** …

## Cross-cutting
- [ ] **T-900** (S) CI runs tests and lint on every push
- [ ] **T-901** (S) README documents setup, run, test
- [ ] **T-902** (S) Error handling and logging baseline

## Dependency graph
```
T-001 → T-010 → T-011
T-001 → T-020
```

## Parking lot
- Ideas deferred with a one-line reason.
