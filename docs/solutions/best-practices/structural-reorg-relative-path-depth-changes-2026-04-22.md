---
title: "Structural folder reorg that changes relative path depth — single-commit discipline, path-pattern sweep, postscript-style amendments"
date: 2026-04-22
category: best-practices
module: papers_explainer
problem_type: best_practice
component: development_workflow
severity: medium
applies_when:
  - Reorganizing a repo's folder layout in a way that changes relative path depth (e.g., introducing a grouping level like methodology buckets, flattening `src/` into the root)
  - `CLAUDE.md`, subagent definitions, or `docs/solutions/` entries reference the old depth via concrete path patterns (e.g. `papers/NN-*/`, `../../shared/...`)
  - The repo documents a literal shell command users are expected to run verbatim from the repo root
  - A previous `docs/solutions/` entry documents a path-resolution fix that the move is about to invalidate
related_components:
  - documentation
  - tooling
tags:
  - repo-reorg
  - relative-paths
  - subagent-prompts
  - git-mv
  - single-commit-discipline
  - postscript-amendments
  - path-pattern-sweep
  - shell-executable-prompts
---

# Structural folder reorg that changes relative path depth

## Context

On 2026-04-22, the `papers_explainer` repo was reorganized from a flat `papers/NN-<slug>/` layout to methodology-bucketed `papers/<method>/NN-<slug>/` (`did/`, `iv/`, `rdd/`). Because every `simulation.R` sources `../../shared/r-setup.R` via a relative path anchored to the script's own directory, adding the bucket layer required flipping `../../` to `../../../` in every moved script.

Path depth is load-bearing in this repo for a second reason too: the 12-section template, the `Rscript` invocation contract, and the 4-subagent pipeline are all documented with literal `papers/NN-*/` globs that appeared 11 times across `CLAUDE.md`, `README.md`, and the four `.claude/agents/*.md` files — plus once in a prior `docs/solutions/` entry. Drift is silent in this setup because subagents run one paper at a time: a stale path pattern in `causal-inference-expert` or `r-coding-expert` doesn't surface until the next paper is scaffolded, at which point it lands at the wrong depth without any loud failure.

This entry captures the six patterns that kept the reorg coherent across all of those surfaces. It is the second learning in the repo; it composes with the 2026-04-21 single-file preamble fix (see `## Related`), which is the lower-level "how to make `source()` location-independent in the first place" lesson.

## Guidance

### 1. Commit folder moves and their path-fix edits in a single commit

Any `git mv` that changes relative-path depth must be staged together with the corresponding edit inside the moved file. The canonical move in this repo:

```bash
git mv papers/01-ghanem-selection-parallel-trends papers/did/01-ghanem-selection-parallel-trends
# inside the moved simulation.R:
#   source("../../shared/r-setup.R")  ->  source("../../../shared/r-setup.R")
git add papers/did/01-ghanem-selection-parallel-trends/simulation.R
git commit -m "refactor(papers): group papers by methodology bucket"
```

What **not** to do: commit the folder move first and fix the `source()` path in a follow-up commit. The intermediate SHA is runtime-broken — `git checkout <intermediate>` followed by the documented `Rscript papers/did/01-.../simulation.R` will fail to find `r-setup.R`. That breaks `git bisect` and historical reproducibility.

Verify post-commit:

```bash
git log --follow papers/did/01-ghanem-selection-parallel-trends/simulation.R
# -> still traces pre-move authoring commits
```

### 2. Keep the in-file edit small enough that `git mv` preserves history

Git's default rename-detection similarity threshold is 50%. A one-line edit (`../../` → `../../../`) inside a 40-line script shows up as ~99% similarity — well inside the threshold — so the rename is preserved cleanly:

```bash
git show <reorg-sha> --stat --find-renames
# papers/{ => did}/01-.../simulation.R  (99%)
```

If you're tempted to bundle the reorg with a larger content refactor of the same file, split it: do the move + minimum-viable path edit in commit A, then do substantive content changes in commit B. Otherwise rename similarity can fall below threshold and git logs the file as a delete + add, losing `git log --follow` traceability.

### 3. Sweep every encoded surface for the old path pattern

Before the reorg, `papers/NN-*/` literally appeared in `CLAUDE.md` (8 spots), `README.md` (3 spots), and all four `.claude/agents/*.md` files. Treat these as first-class refactor targets, not drift:

```bash
grep -rn 'papers/NN-\*' CLAUDE.md .claude/agents/ README.md docs/solutions/
```

Post-refactor this command should return zero live hits. Any remaining hits must be explicit historical or negative examples (e.g. the sentence "never place a new paper directly at `papers/NN-<slug>/`" or the Before/After block inside a historical `docs/solutions/` entry). Live patterns in a subagent's *Inputs*, *Outputs*, or *Verify* sections will scaffold the next paper at the wrong depth, and because subagents are invoked one-paper-at-a-time, the drift stays invisible until the next paper actually lands.

### 4. Amend `docs/solutions/` entries via postscript, not edit-in-place

When the reorg invalidates the example paths or depth numbers in a prior `docs/solutions/` entry, do **not** rewrite its Before/After block — the historical record is load-bearing for understanding why the lesson exists. Instead, append a dated postscript:

```markdown
## Postscript — YYYY-MM-DD — <one-line reason>

The canonical `source()` is now `../../../shared/r-setup.R`. The lesson
(anchor to the script's own directory) is unchanged; only the depth differs.
The historical Before/After block above is preserved verbatim because it
documents the fix as it landed on <original date> (commit <sha>).
```

The frontmatter `date` field stays the original discovery date. The postscript dates the amendment. Future readers get both "how the lesson looked when it was first learned" and "what the canonical state is today." Edit-in-place would silently destroy the historical state.

### 5. Verify via the literally-documented command from the repo root

This is the direct application of the pre-existing 2026-04-21 lesson (`runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md`, Prevention #1). In a reorg context it means: after the move, run the command *exactly* as `CLAUDE.md` or `README.md` documents it.

```bash
# RIGHT — the documented command, from the repo root
Rscript papers/did/01-ghanem-selection-parallel-trends/simulation.R

# WRONG — masks the very CWD-sensitive bugs the documented command exists to surface
(cd papers/did/01-ghanem-selection-parallel-trends && Rscript simulation.R)
```

The command that ships in the README is the contract with the reader; that is the one to verify. A verification wrapper that pre-`cd`'s into the paper folder will pass even when the canonical invocation is broken — exactly the failure mode the 2026-04-21 entry documents.

### 6. Subagent-encoded shell commands must be literally runnable

`ce:review` batch 3 caught that `.claude/agents/git-github-expert.md` told the agent to run `grep -n 'TODO:' papers/<method>/NN-*/`. This is un-runnable two ways: plain `grep` errors on directory arguments (needs `-r`), and `<method>` is a shell-literal placeholder that doesn't expand. Two acceptable fix shapes:

```bash
# (a) Runnable generic — works from repo root, no substitution needed
grep -rn 'TODO:' papers/*/NN-*/

# (b) Parameterised, with explicit substitution instruction in the prompt:
#     "With <method> and <slug> replaced by the paper you are committing, run:"
grep -rn 'TODO:' papers/<method>/<slug>/
```

What is not acceptable: leaving shell-literal placeholders in a command the agent is supposed to execute verbatim. Before shipping a subagent edit, copy each shell block out of the agent prompt and run it in a terminal. If it requires substitution, say so in the prose.

## Why This Matters

Skipping pattern 1 produces commits that are individually runtime-broken — `git bisect` lands on a SHA where the simulation can't find its setup file, and bisect chases a phantom regression.

Skipping pattern 2 loses `git log --follow` traceability across the rename, which silently erodes blame and provenance for methodology-critical code.

Skipping pattern 3 is the worst failure mode in this repo: a subagent prompt carries the stale path pattern, but because each subagent runs on one paper at a time, the drift doesn't surface until the next paper is scaffolded — at which point it's authored at the wrong depth by an agent faithfully following its own (now-incorrect) instructions.

Skipping pattern 4 destroys the historical reasoning trail in `docs/solutions/`, turning a learning archive into a rolling snapshot and making the sequence of lessons unreconstructable.

Skipping pattern 5 means the command users actually run (from the repo root, per the README) is not the command that was tested, and `getwd()`-sensitive bugs slip through unseen.

Skipping pattern 6 bakes unreachable instructions into the automation itself — the agent will either error on execution or, worse, silently synthesize a different command that doesn't match the documented contract.

## When to Apply

- Any folder reorg that adds or removes a level of depth above scripts with relative `source()` / `import` / `require_relative` paths.
- Path-pattern renames (bucket introduction, directory flattening, `src/` → `lib/`) in a repo whose conventions are enforced by subagent or agent prompts.
- Refactors touching scripts invoked from outside their own directory (`Rscript path/to/script.R`, `python -m package.module`, `bash scripts/foo.sh`).
- Any repo where `docs/solutions/`, `runbooks/`, or similar archives cite literal paths that the refactor will invalidate.
- Multi-file find-and-replace operations where the pattern appears in both executable code and in prompts/docs — the docs-side edits must land in the same commit as the code-side edits to keep history atomic.

## Examples

Reusable recipes for a future reorg:

```bash
# Pre-refactor audit — enumerate every surface that encodes the old shape
grep -rn '<old-path-pattern>' \
  CLAUDE.md AGENTS.md README.md .claude/agents/ docs/solutions/ docs/plans/

# Atomic move + path-fix commit (one logical change)
git mv <old-dir>/<item> <new-dir>/<item>
# edit relative paths inside <new-dir>/<item>/<script>
git add <new-dir>/<item>
git commit -m "refactor(<scope>): move <item> under <new-dir>/"

# Verify rename detection preserved history
git show <sha> --stat --find-renames
git log --follow <new-dir>/<item>/<script>

# Verify the literally documented invocation still works from repo root
<the-exact-command-from-the-README>

# Amend a prior solution doc without destroying its history
cat >> docs/solutions/<category>/<slug>.md <<'EOF'

## Postscript — YYYY-MM-DD — <one-line reason>

<current canonical state; note that the lesson above is unchanged, only the
surface details (path / depth / name) have shifted.>
EOF

# Subagent-command sanity check — copy every shell block out of every agent
# prompt and run it. Placeholders like <method> must either be replaced with
# a glob that actually expands, or be flagged in the prompt as
# "substitute before running".
```

This refactor's evidentiary trail:

| Commit | Change |
|---|---|
| `339017e` | Plan added to `docs/plans/2026-04-22-001-refactor-methodology-folder-structure-and-retitle-plan.md` |
| `b19d313` | Bucketing commit — 9 `git mv` renames + 3 one-line `source()` depth fixes, atomic |
| `6586c9d` | `CLAUDE.md` + 4 subagent defs + `docs/solutions/` postscript |
| `8224a7c` | `README.md` retitle + per-methodology sub-tables |
| `976f582` | `ce:review` batch 3 — subagent shell-runnability fixes |

## Related

- `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md` — the lower-level "how to make `source()` location-independent via `commandArgs(--file=)` preamble" lesson. Its Postscript section is the on-the-ground artifact of pattern 4. The preamble itself was location-independent and survived this reorg byte-identical; only the literal depth in the `source()` string below it changed.
- `docs/plans/2026-04-22-001-refactor-methodology-folder-structure-and-retitle-plan.md` — the planning document that drove the reorg (useful as a worked example of enumerating affected surfaces up front).
- `CLAUDE.md` — the repo's authoritative convention file; updated in commit `6586c9d` for the new depth. The "R conventions" bullet now mandates the 3-level path.
- `.claude/agents/causal-inference-expert.md` — now explicitly owns `<method>` bucket resolution and `papers/<method>/` folder creation (commit `976f582`), closing the agent-native gap that would otherwise require a human to pick the bucket manually.
