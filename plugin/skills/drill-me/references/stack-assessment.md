# Stack assessment guide

How to turn `machine-inventory.sh` output into advice the user can act on.

## 1. Summarize
Ten lines max. Group: OS and hardware (note GPU only if ML or graphics is in scope),
languages and versions, package managers (system, mise, language-level), databases and
services already running, containers, deployment CLIs, AI coding CLIs present.

## 2. Assess fit
Score the candidate stacks (installed first, then obvious alternatives) against:
- **Target platform**: web, desktop, mobile, CLI, embedded. Rule out mismatches first.
- **Familiarity**: what the user said they have shipped with. Familiar beats fashionable.
- **Ecosystem fit**: libraries the requirements need (auth, payments, ML, realtime, PDF…).
- **Performance and scale**: only if the brief states real numbers.
- **Hosting**: where it will run and what is cheapest to operate there.
- **Toolchain readiness**: is the required version already installed and working?
- **Longevity**: maintained, documented, hireable.

State the assessment as "installed stack: fits / fits with changes / poor fit" with one
reason per line.

## 3. Recommend
Recommend a switch only when it is materially better on at least two criteria above and
the switching cost is small at this stage (nothing is built yet). Give:
- the recommendation in one sentence,
- why, in three bullets tied to the brief,
- what changes for the user (learning curve, hosting, cost),
- exactly what would be installed and how (package manager, versions).

If the installed stack is fine, say so and do not manufacture a recommendation.

## 4. Install path by ecosystem (Arch/Omarchy defaults; adapt to the OS in the inventory)
- Runtimes with many versions (node, python, go, rust, java, bun, deno): prefer `mise use -g <tool>@<version>`.
- System services (postgresql, redis, docker, nginx): `sudo pacman -S <pkg>` then `sudo systemctl enable --now <svc>`.
- AUR-only tools: `yay -S <pkg>`.
- Language-level tools: the ecosystem's own installer (`pipx`/`uv tool`, `npm i -g`, `cargo install`, `go install`).
Show each command before running it. Run one at a time. Verify with a version command.
Record the outcome (installed version or failure text) in the brief.

## 5. Record
In the brief's Tech stack section: inventory summary, fit assessment, recommendation,
the user's choice (keep/switch), the install choice (for me / self / skip), and outcome.
Store the choice as a `sabda` decision memory and the observed versions as `pratyaksha`.
