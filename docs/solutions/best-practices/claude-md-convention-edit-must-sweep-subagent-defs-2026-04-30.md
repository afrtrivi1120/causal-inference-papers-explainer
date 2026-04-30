---
title: "When CLAUDE.md relaxes a convention, the subagent definitions that enforce it must travel in the same commit"
date: 2026-04-30
category: best-practices
module: papers_explainer
problem_type: best_practice
component: development_workflow
applies_when:
  - Editing `CLAUDE.md` to relax, tighten, or rewrite a convention that any `.claude/agents/*.md` file independently encodes (cell-layout rules, pre-commit checklists, naming conventions, file-shape rules)
  - Adding a new mode of operation (e.g. single-draw notebooks alongside Monte Carlo notebooks) that an existing subagent's prompt is structurally unaware of
  - Reviewing a PR that touched `CLAUDE.md` but not `.claude/agents/` — likely an unswept surface
related_components:
  - subagent-prompts
  - documentation
tags:
  - claude-md
  - subagent-prompts
  - convention-changes
  - single-commit-discipline
  - pattern-sweep
---

# When CLAUDE.md relaxes a convention, the subagent definitions that enforce it must travel in the same commit

## Context

On 2026-04-30, three R simulation notebooks were rewritten as single-draw demonstrations and `CLAUDE.md`'s "Notebook conventions" section was relaxed to make `N_SIM` and the "re-anchor seed before representative plot" rules conditional on whether the notebook uses Monte Carlo. The implementation commit (`7df1398`) bundled the `CLAUDE.md` edit with the notebook rewrites — pattern 1 from the 2026-04-22 reorg lesson, applied correctly.

What the implementation **missed** was that the same two conventions were independently encoded in `.claude/agents/simulation-notebook-expert.md` (steps 4–5 of the prescribed cell layout, plus the comment-sparingly example, plus output-format item 2) and `.claude/agents/git-github-expert.md` (the pre-commit checklist mandates "the notebook's Monte Carlo summary cell produces a DataFrame"). Until those agent prompts were updated to match, the next subagent invocation would have either (a) produced a Monte Carlo notebook for a paper whose punchline doesn't need one, or (b) failed the git-expert's checklist on a correctly-structured single-draw notebook.

`ce:review` (run `20260430-151744-183581eb`) caught the omission. The agent-native reviewer flagged it as P2; the learnings-researcher independently traced the same pattern back to the 2026-04-22 reorg lesson's pattern 3 ("sweep every encoded surface"). The fix landed in `a66525a` as a follow-up commit. This entry documents why the omission was easy to make and how to avoid repeating it.

## Guidance

### 1. CLAUDE.md and `.claude/agents/*.md` are not single-source

`CLAUDE.md` is the human-facing authoritative convention file. `.claude/agents/*.md` are the prompts that subagents follow when invoked. The two surfaces describe overlapping but **independently-stored** rules — there is no automated "compile from CLAUDE.md" step. When a convention changes in one place, it must be hand-propagated to the other.

In this repo today, four conventions are duplicated across `CLAUDE.md` and at least one agent definition:

| Convention | `CLAUDE.md` location | Agent definition location |
|---|---|---|
| Notebook cell layout (title → setup → params → DGP → comparison → plot → punchline) | "Notebook conventions" | `simulation-notebook-expert.md` step list |
| Defensive `install.packages(...)` for non-Colab packages | "Notebook conventions" | `simulation-notebook-expert.md` step 2 + "Rules of engagement" |
| Label-safe lookup pattern (`stopifnot()` against estimator row names) | "Notebook conventions" | `simulation-notebook-expert.md` "Rules of engagement" |
| Pre-commit notebook checklist (`nbconvert` exits 0, rendered outputs present, `TODO:` placeholders gone) | "Adding a new paper — checklist" + "Pre-commit checklist" | `git-github-expert.md` step 2 |

Editing any of these in `CLAUDE.md` without sweeping the agent definitions creates a transient state where the agent enforces the old rule and the human-facing convention says something different.

### 2. Sweep with grep, not memory

Before committing a `CLAUDE.md` convention edit, grep the changed terms across `.claude/agents/`:

```bash
# Substitute the keywords actually being changed.
grep -rn 'N_SIM\|Monte Carlo\|re-anchor\|representative-draw plot' \
  .claude/agents/
```

Any hit is a surface that needs the same edit (or an explicit "this rule is conditional on …" carve-out matching the new `CLAUDE.md` text). Zero hits is the only acceptable post-edit state for the keyword set you changed.

This generalizes 2026-04-22 reorg pattern 3 (path-pattern sweep) from path-shaped conventions to *any* shape of convention encoded as prose. The mechanism is the same: subagent invocations are one-at-a-time, so drift between `CLAUDE.md` and an agent prompt stays invisible until the next time that agent runs.

### 3. Bundle the agent edits into the same commit as the CLAUDE.md edit

Per the 2026-04-22 single-commit discipline (pattern 1): the `CLAUDE.md` edit, the notebook edits that newly violate the old `CLAUDE.md` text, and the `.claude/agents/*.md` edits that bring the agents in line with the new `CLAUDE.md` text all land in **one commit**. The intermediate state where any one of those is missing is self-inconsistent.

In this incident the implementation commit (`7df1398`) included the `CLAUDE.md` edit and the notebook edits but not the agent-def edits — a partial application of the discipline. The two correct shapes are:

```
# (a) One commit for everything (preferred for small convention changes)
git add CLAUDE.md .claude/agents/*.md papers/*/*/simulation.ipynb papers/*/*/README.md
git commit -m "refactor(...): <change> + sweep CLAUDE.md, agents, notebooks"

# (b) If commits must be split for review reasons, sequence them so each
#     intermediate SHA is internally consistent: agents-first, then code.
git commit -m "chore(agents): allow single-draw notebooks (matches CLAUDE.md update)"
git commit -m "refactor(papers): rewrite notebooks as single-draw demos"
git commit -m "docs(claude-md): relax N_SIM and re-anchor rules"
```

Either pattern keeps `git bisect` and historical reproducibility intact. Splitting the convention change into "code first, agents follow up" — what happened here — produces an intermediate SHA where running the per-paper subagent pipeline would silently re-impose the old convention.

### 4. Treat ce:review's agent-native reviewer as the safety net for #2

The agent-native reviewer is selected on every ce:review run. It is the reviewer most likely to catch a missed sweep because its job is "any action a user can take, an agent can also take" — which in this repo's context translates to "any rule the human conventions impose, the agent definitions impose identically." If it flags a `CLAUDE.md`-vs-`.claude/agents/` divergence as P2, treat that finding as load-bearing, not advisory. (The lesson surfaced through `ce:review` for exactly this reason on 2026-04-30.)

## Why This Matters

Skipping this discipline produces a self-inconsistent repo: the human-facing convention file says one thing, the automation that enforces conventions on every new paper says another. Because per-paper subagents run one paper at a time, the drift is invisible until the next paper — at which point it lands authored against the wrong rule, by an agent faithfully following its own (now-stale) instructions. The humans then have to either re-author the paper to match `CLAUDE.md`, or roll the agents forward to match what the humans actually meant. Both are avoidable with a single grep before committing.

## When to Apply

- Any edit to `CLAUDE.md`'s "Notebook conventions", "Per-paper README.md template", "Adding a new paper checklist", "Pre-commit checklist", or any other section whose contract is duplicated in `.claude/agents/`.
- Adding a new shape of artifact the existing subagents don't know how to produce (e.g., single-draw notebooks alongside Monte Carlo, a new methodology bucket with a different cell layout).
- Reviewing any PR that touches `CLAUDE.md` but does not also touch `.claude/agents/` — that is the most common drift signature.

## Examples

The 2026-04-30 incident, end to end:

```bash
# What happened (the wrong sequence) — implementation commit 7df1398 ran:
git add CLAUDE.md papers/*/*/{simulation.ipynb,README.md}
git commit -m "refactor(papers): simplify R notebooks to single-draw demos"
# .claude/agents/{simulation-notebook-expert,git-github-expert}.md were
# unchanged — left in an inconsistent state until ce:review caught it.

# What ce:review's agent-native reviewer flagged (P2):
#   simulation-notebook-expert.md still mandated MC cell + N_SIM
#   git-github-expert.md still required "Monte Carlo summary cell produces a DataFrame"

# What the fix commit a66525a should have been part of 7df1398:
git add .claude/agents/simulation-notebook-expert.md .claude/agents/git-github-expert.md
git commit -m "fix: apply ce:review batch 1 (subagent-defs ...)"
```

The recipe that would have prevented this:

```bash
# Step 1 — before staging any CLAUDE.md edit, list the keywords you are
# changing and grep them across .claude/agents/
KEYWORDS='N_SIM\|Monte Carlo\|re-anchor\|representative-draw plot'
grep -rn "$KEYWORDS" .claude/agents/
# Each hit is a surface that needs an edit (or an explicit conditional
# carve-out) in this same commit.

# Step 2 — make all edits, stage them together, commit once.
git add CLAUDE.md .claude/agents/simulation-notebook-expert.md \
  .claude/agents/git-github-expert.md papers/*/*/simulation.ipynb \
  papers/*/*/README.md
git commit -m "refactor: <change> + sweep CLAUDE.md, agent defs, notebooks"

# Step 3 — re-grep post-commit. Zero hits for the old keywords means the
# sweep is complete.
grep -rn "$KEYWORDS" .claude/agents/
```

## Related

- `docs/solutions/best-practices/structural-reorg-relative-path-depth-changes-2026-04-22.md` — the parent lesson. Pattern 1 (single-commit discipline) and pattern 3 (sweep every encoded surface) generalize to this entry: this is the same discipline applied to convention prose rather than path patterns. If you land here first, read that one second; if you land there first, read this one second.
- `docs/plans/2026-04-30-001-refactor-simplify-r-notebooks-plan.md` — the plan that drove the relaxation. It correctly identified `CLAUDE.md` as a target surface and (correctly) bundled the convention edit with the implementation, but it did not enumerate `.claude/agents/*.md` as also-affected. Future plans that touch `CLAUDE.md` should add an explicit "sweep `.claude/agents/`" implementation unit.
- `CLAUDE.md` "Notebook conventions" — the surface that drifted in this incident. Two bullets are now conditional; the agent definitions were updated in `a66525a` to match.
- `.claude/agents/simulation-notebook-expert.md` — owner of notebook structure. Steps 4–5 now branch on Monte Carlo vs single-draw; output-format item 2 accepts either tibble shape.
- `.claude/agents/git-github-expert.md` — pre-commit gate. The "Monte Carlo summary cell produces a DataFrame" check is now a "truth-vs-estimate comparison present" check that admits both notebook shapes.
