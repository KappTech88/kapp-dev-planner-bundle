# Pramana policy and priority scale

## Labels with examples

| Label | Meaning | Example memory |
|---|---|---|
| `pratyaksha` | Directly observed by a tool or command | "Machine has Python 3.14.7 and Node 26.7.0 (machine-inventory 2026-09-07)" |
| `sabda` | Stated by the user or trusted docs | "User wants v1 to be a CLI only; no web UI" |
| `anumana` | Inferred by the agent | "Because deployment is a single VPS, SQLite is sufficient for v1" |
| `smriti` | Recalled from earlier memory | "Earlier session recorded that auth uses passkeys" |
| `kalpana` | Hypothesis or idea | "A plugin marketplace might be a later revenue path" |

Only `pratyaksha` and `sabda` count as accepted truth. The rest need review before they
drive decisions. Mark hypotheses as `kalpana` so they are never mistaken for facts.

## Priority (1–10)

- 9–10: decisions that shape architecture or scope; hard constraints.
- 7–8: user preferences, milestone plans, chosen stack.
- 5–6: observed environment facts, assumed defaults.
- 3–4: rejected alternatives with reasons.
- 1–2: minor notes.

## Verification fields

For a fact checked by a command, add `--verification-command "<cmd>"` and
`--verification-status verified`; add `--source-path <file>` for facts tied to a file.
Facts without verification stay `unverified`, which is honest and fine.
