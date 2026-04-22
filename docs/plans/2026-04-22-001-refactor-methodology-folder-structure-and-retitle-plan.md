---
title: Reorganize papers by methodology buckets and drop "Plain-Language" from the landing title
type: refactor
status: active
date: 2026-04-22
---

# Reorganize papers by methodology buckets and drop "Plain-Language" from the landing title

## Overview

Two coupled changes to the public surface of the repo:

1. **Folder reorganization.** Papers currently sit flat under `papers/NN-<first-authors>-<short-topic>/`. Move each paper into a **methodology bucket** underneath `papers/`, so the structure becomes `papers/<method>/NN-<first-authors>-<short-topic>/`. The current three papers redistribute as DiD (paper 01), IV (paper 02), and RDD (paper 03). The taxonomy anticipates further buckets (RCT, synthetic-control, causal-ai, ...) that will be created lazily as papers arrive in them.
2. **Landing-page retitle.** Rename the repo from "Causal Inference Papers — Plain-Language Explainers" to "Causal Inference Papers — Explainers" in the landing `README.md`, and soften the "plain-language walkthroughs..." hook in the first paragraph so the repo is positioned as an alternative, accessible source for understanding the breadth of methodological causal-inference papers — not as a "plain-language-first" brand.

Both changes are purely surface-level *except* for one substantive side effect: every `simulation.R` currently sources `../../shared/r-setup.R` (two levels up). After the reorg, scripts live three levels below the repo root, so the relative path must become `../../../shared/r-setup.R` and every simulation must continue to run clean under `Rscript papers/<method>/NN-*/simulation.R`.

## Problem Frame

As the library grows beyond 3 papers, a flat `papers/NN-*/` directory will stop being browseable — readers interested in IV won't want to scroll through DiD and RDD entries. A methodology bucket is the first organizing axis practitioners actually use when looking for a method. The numbering (`NN-`) remains useful as a secondary signal (arrival order, commit-log traceability), but it should not be the primary lookup key.

Separately, the landing title front-loads "Plain-Language" as the repo's identity. The user wants the repo to read as *an alternative source for understanding the many causal-inference papers*, not as "the plain-language one". Plain language is still how the content is written — that convention stays in `CLAUDE.md` — but it should not be the hook in the title.

## Requirements Trace

- **R1.** `papers/` is organized into methodology buckets, each containing paper folders with their existing `NN-<first-authors>-<short-topic>/` naming.
- **R2.** The current three papers move to `papers/did/01-...`, `papers/iv/02-...`, `papers/rdd/03-...` using `git mv` so history is preserved.
- **R3.** `Rscript papers/<method>/NN-*/simulation.R` runs clean end-to-end from the repo root for all three papers after the move. No figures/, no stale cached paths.
- **R4.** Top-level `README.md` title becomes "Causal Inference Papers — Explainers"; the first paragraph is rewritten to drop "plain-language" as the brand while keeping the *for motivated learners without prior econometrics* framing.
- **R5.** The top-level `README.md` contents table is grouped by methodology (one subsection per bucket), with repo-relative links pointing at the new paths.
- **R6.** `CLAUDE.md` is updated so every reference to `papers/NN-*/` reflects the new depth, including: folder layout diagram, 12-section template preamble, R-conventions source-path depth, subagent routing table, "Adding a new paper" checklist, and "Running the simulations" block.
- **R7.** All four subagent definitions in `.claude/agents/` (causal-inference-expert, causal-inference-professor, r-coding-expert, git-github-expert) are updated so path patterns and example invocations reflect the methodology-bucket depth.
- **R8.** The existing `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md` is updated where it references specific `papers/NN-*/` example paths and the `../../shared/r-setup.R` path string — the solution itself (the `commandArgs(--file=)` preamble) stays unchanged, since it is location-independent.
- **R9.** The top-level `.gitignore` is unchanged (it already globs `papers/**/figures/`, which is bucket-tolerant).
- **R10.** One conventional-commit per milestone lands: (a) structural move + path-depth fix, (b) docs/agents refresh, (c) README retitle + contents-table regrouping. `Rscript papers/<method>/NN-*/simulation.R` passes before each commit.

## Scope Boundaries

- **Not in scope:** creating empty methodology buckets for RCT, synthetic-control, causal-ai, etc. Those folders materialize when the first paper in each category is added. Only three bucket folders (`did/`, `iv/`, `rdd/`) are created in this pass.
- **Not in scope:** changing any of the 12 template sections, glossary content, or simulation logic in the three existing papers. This is a reorganization, not a rewrite.
- **Not in scope:** renumbering the papers. Global `NN-` numbering is preserved, so `papers/did/01-...`, `papers/iv/02-...`, `papers/rdd/03-...` have non-contiguous numbers within each bucket — that is intentional and documented.
- **Not in scope:** internationalization, Shiny apps, CI for `Rscript`, or any item already listed as "Future extensions" in `CLAUDE.md`.
- **Not in scope:** revising the historical plan at `docs/plans/2026-04-21-001-feat-causal-inference-papers-explainer-plan.md`. That plan is a snapshot of the original scaffold; it will be marked `status: superseded` by the git commit history of this refactor but its body text is left as-is.

### Deferred to Separate Tasks

- First paper in a new methodology bucket (RCT / synthetic-control / causal-ai / etc.): that paper's PR will create its bucket folder when it lands.

## Context & Research

### Relevant code and patterns

- `papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R` — the canonical 4-line script-dir preamble (lines 14–19) that all three simulations copy verbatim. The preamble itself is path-independent; only the `source("../../shared/r-setup.R")` call below it hard-codes a two-level depth.
- `papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.R` — same preamble + same `source()` line.
- `papers/03-demagalhaes-et-al-rdd-close-elections/simulation.R` — same preamble + same `source()` line.
- `shared/r-setup.R` — unchanged; only the *string* each simulation uses to reach it changes.
- `.gitignore` — `papers/**/figures/*.png`, `papers/**/figures/*.pdf` already use `**`, so the extra nesting level is already covered.

### Path-depth references that must update (exhaustive list from repo grep)

- `README.md` lines 20–22 (contents table), line 38 (example `Rscript` invocation), line 62 ("Adding a new paper" pattern).
- `CLAUDE.md` lines 43, 60 (source-path depth), 65 (figures-path pattern), 75, 95, 98, 107–109 (running-the-simulations block).
- `.claude/agents/causal-inference-expert.md` lines 13, 20, 21, 60.
- `.claude/agents/causal-inference-professor.md` line 57.
- `.claude/agents/r-coding-expert.md` lines 8, 20, 25, 42.
- `.claude/agents/git-github-expert.md` lines 29, 30.
- `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md` lines 12, 33, 63, 101, 116, 120–122.

### Institutional learnings

- `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md` — the `commandArgs(--file=)` preamble is location-independent; only the string passed to `source()` encodes depth. This learning is directly load-bearing for this refactor: the preamble survives unchanged, but the `source("../../shared/r-setup.R")` literal must become `source("../../../shared/r-setup.R")`. The "prevention" lessons in that doc (test the documented command verbatim from repo root; do not wrap in a subshell `cd`) apply directly to the verification step of this plan.

### External references

None required. This refactor uses only `git mv`, string edits, and `Rscript`.

## Key Technical Decisions

- **Bucket naming: kebab-case lowercase (`did`, `iv`, `rdd`, `rct`, `synthetic-control`, `causal-ai`).** Rationale: matches the existing `NN-<first-authors>-<short-topic>/` lowercase-kebab convention; avoids cross-platform case-sensitivity surprises (macOS default vs. Linux); keeps URLs on GitHub clean. Canonical capitalization (DiD, IV, RDD) lives in the *display* column of the landing-README contents table, not in folder paths.
- **Preserve global `NN-` numbering.** Rationale: numbering reflects arrival order, which is useful commit-history context. Per-bucket renumbering would also force rewriting every `NN-` occurrence in every subagent definition and docs/solutions entry, and would obscure the order in which ideas landed in the repo.
- **Use `git mv` for each paper folder, not delete-and-recreate.** Rationale: preserves per-file commit history so `git log --follow papers/did/01-.../README.md` still surfaces the original authoring commits. `git` detects pure renames automatically when the content is unchanged, so this is a safe move.
- **Do not pre-create empty bucket folders** (RCT, synthetic-control, causal-ai). Rationale: empty directories signal "nothing here yet" to visitors and create noise; the *taxonomy* lives in a short section of the landing `README.md` instead.
- **Update source-path depth in a single logical commit with the folder moves.** Rationale: `Rscript papers/did/01-.../simulation.R` will break the moment the folder moves unless `source("../../../shared/r-setup.R")` lands in the same commit. Shipping them separately would leave an intermediate commit where the documented command fails — violating the "always push after each milestone" authorization from `CLAUDE.md`.
- **Retitle + contents-table regrouping land together** in the third commit. Rationale: the title line and the contents table are both in the landing `README.md`; separating them is arbitrary churn.
- **Use `papers/<method>/NN-*/` as the new glob pattern in `CLAUDE.md` and subagent definitions** (not `papers/**/NN-*/`). Rationale: the `<method>` segment is a *required* part of the structure; `**` would match both the old and new layouts during transition, which is confusing once the refactor is complete.

## Open Questions

### Resolved during planning

- **Do we renumber papers per bucket?** No. Global `NN-` numbering is preserved. Within `papers/did/` there is only `01-...`; within `papers/iv/` only `02-...`. Future papers keep climbing the global counter regardless of bucket.
- **Do we create empty buckets for methods with no papers yet?** No — taxonomy lives in a one-paragraph section of the landing `README.md`, and buckets are created on first paper.
- **How much of the "plain-language" framing stays?** The *convention* stays in `CLAUDE.md` (plain language first, analogies over algebra, glossary required). Only the landing-page *title* and the first-paragraph *hook* change, so the repo's identity is not "the plain-language one" but rather "an alternative, accessible source for understanding many methodological causal-inference papers".
- **Does the `docs/plans/2026-04-21-001-...` original plan need revising?** No. It is a historical snapshot. The new plan supersedes it; git history documents the evolution.

### Deferred to implementation

- None. This refactor is entirely deterministic from planning.

## Output Structure

```
papers/
├── did/
│   └── 01-ghanem-santanna-wuthrich-selection-parallel-trends/
│       ├── README.md
│       ├── simulation.R            # source("../../../shared/r-setup.R")
│       └── references.md
├── iv/
│   └── 02-blandhol-bonney-mogstad-torgovitsky-tsls-late/
│       ├── README.md
│       ├── simulation.R            # source("../../../shared/r-setup.R")
│       └── references.md
└── rdd/
    └── 03-demagalhaes-et-al-rdd-close-elections/
        ├── README.md
        ├── simulation.R            # source("../../../shared/r-setup.R")
        └── references.md
```

Buckets not yet populated (`rct/`, `synthetic-control/`, `causal-ai/`, etc.) are **not** created in this pass; they are listed in the landing-README's taxonomy paragraph only.

## Implementation Units

- [ ] **Unit 1: Move paper folders into methodology buckets and fix source-path depth**

**Goal:** Relocate each of the three existing paper folders into the new `papers/<method>/` structure, update the three `simulation.R` files so `source("../../../shared/r-setup.R")` resolves correctly from the new depth, and confirm that `Rscript papers/<method>/NN-*/simulation.R` exits 0 from the repo root.

**Requirements:** R1, R2, R3, R10.

**Dependencies:** None. This unit is the structural foundation for everything else.

**Files:**
- Move (via `git mv`):
  - `papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/` → `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/`
  - `papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/` → `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/`
  - `papers/03-demagalhaes-et-al-rdd-close-elections/` → `papers/rdd/03-demagalhaes-et-al-rdd-close-elections/`
- Modify (after move): the `source(...)` line in each of the three `simulation.R` files
  - `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R`
  - `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.R`
  - `papers/rdd/03-demagalhaes-et-al-rdd-close-elections/simulation.R`

**Approach:**
- For each paper, run `git mv papers/NN-<slug>/ papers/<method>/NN-<slug>/` — `git` auto-detects pure renames and preserves per-file history for `git log --follow`.
- In each moved `simulation.R`, change the single line `source("../../shared/r-setup.R")` to `source("../../../shared/r-setup.R")`. The 4-line script-dir preamble above it is location-independent and stays byte-identical.
- After all three edits, verify each simulation runs clean end-to-end from the repo root using the literal documented invocation (per the docs/solutions learning: no subshell `cd`, no wrapper). Each script should exit 0, print its "truth vs estimate" line, and drop figures into its own paper folder's `figures/` subdirectory — not at the repo root, not at `papers/` root.

**Patterns to follow:**
- Preamble from `papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R` (about lines 14–19). Do **not** modify the preamble — only the `source()` call below it.
- The `commandArgs(--file=)` idiom documented in `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md` — its prevention section ("test the exact documented invocation from the repo root") is the verification protocol for this unit.

**Test scenarios:**
- Integration (post-move): `Rscript papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R` from repo root exits 0, prints the truth-vs-estimate comparison for both scenarios A and B, and writes its PNG into `papers/did/01-.../figures/` — not at the repo root, not at `papers/` root.
- Integration (post-move): `Rscript papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.R` from repo root exits 0, prints the truth-vs-estimate comparison, and writes its PNG into `papers/iv/02-.../figures/`.
- Integration (post-move): `Rscript papers/rdd/03-demagalhaes-et-al-rdd-close-elections/simulation.R` from repo root exits 0, prints its coverage comparison, and writes its PNG into `papers/rdd/03-.../figures/`.
- Edge case: running each simulation a second time from *inside* its paper folder (`cd papers/did/01-.../ && Rscript simulation.R`) also exits 0 — verifies the preamble's interactive-safe `length(.file) > 0` guard still holds at the new depth.
- Edge case: `git log --follow papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/README.md` surfaces the pre-move authoring commits — confirms `git mv` preserved history.

**Verification:**
- Three `Rscript papers/<method>/NN-*/simulation.R` invocations from repo root all exit 0.
- `find papers -maxdepth 3 -name figures` shows figures/ only under paper folders, never at the repo root.
- `git status` after the move shows renames (`R`), not delete+add pairs.

---

- [ ] **Unit 2: Update `CLAUDE.md` and all four subagent definitions for the new depth**

**Goal:** Reflect the methodology-bucket structure everywhere the old flat `papers/NN-*/` pattern appears in project conventions and subagent instructions, so future papers are scaffolded into the correct location by default.

**Requirements:** R6, R7.

**Dependencies:** Unit 1 (the folder structure must actually exist before docs claim it does).

**Files:**
- Modify: `CLAUDE.md`
- Modify: `.claude/agents/causal-inference-expert.md`
- Modify: `.claude/agents/causal-inference-professor.md`
- Modify: `.claude/agents/r-coding-expert.md`
- Modify: `.claude/agents/git-github-expert.md`
- Modify: `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md`

**Approach:**
- In `CLAUDE.md`:
  - "Folder layout" diagram (lines ~20–34): nest each paper folder under a `<method>/` layer.
  - "Per-paper `README.md` — 12-section template" header (line 43): change `papers/NN-*/README.md` → `papers/<method>/NN-*/README.md`.
  - "R conventions" bullet about the preamble (line 60): update the `source` path string to `../../../shared/r-setup.R` and the example invocation to `Rscript papers/<method>/NN-*/simulation.R`.
  - Figures-path bullet (line 65): `papers/NN-*/figures/` → `papers/<method>/NN-*/figures/`.
  - Subagent routing table (line 75): update path pattern in the expert row.
  - "Adding a new paper" checklist (lines 94–100): update the folder path pattern and the `Rscript` invocation.
  - "Running the simulations" block (lines 107–109): replace the three example commands with the new bucket paths.
- In each of the four `.claude/agents/*.md` files: replace every `papers/NN-*/` pattern with `papers/<method>/NN-*/`. The semantics of the instructions do not change; only the path depth does.
- In `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md`:
  - `symptoms` frontmatter entry (line 12) and any example command strings (lines 33, 63, 101, 116, 122) — update `papers/NN-.../` and `papers/01-ghanem.../` to their new bucket paths.
  - "Related Issues" section (lines 120–122) — canonical reference implementation path now points at `papers/did/01-ghanem-.../simulation.R`.
  - Do **not** change the "Solution" section (the 4-line preamble is still byte-identical); only example invocations and path references update.

**Patterns to follow:**
- Repo-relative paths only (`CLAUDE.md` itself enforces this for plans; the same principle applies to convention docs).
- Preserve line numbering of unchanged lines where practical — reviewers comparing diffs will scan for *intent* changes, not *shift* churn.

**Test scenarios:**
- Happy path: `grep -rn 'papers/NN-' CLAUDE.md .claude/agents/ docs/solutions/` returns zero hits after the change (all path patterns now include a `<method>/` segment or a literal bucket name).
- Happy path: `grep -rn '\.\./\.\./shared/r-setup\.R' CLAUDE.md .claude/agents/ docs/solutions/` returns zero hits outside of *historical* quoted code blocks in `rscript-cwd-source-path-resolution-2026-04-21.md` that describe the pre-preamble bug. Any live example that claims to be current uses `../../../shared/r-setup.R`.
- Edge case: the `docs/solutions/` file's "Before / After" block (lines 70–88) documenting the pre-preamble bug is left intact — this is historical evidence, not a current example. Only its "Related Issues" file path and the invocation example in "Prevention" point at the new bucket layout.
- Edge case: the pre-existing `docs/plans/2026-04-21-001-...` historical plan is not modified (it is a frozen snapshot; the new plan supersedes it by date).

**Verification:**
- `grep -rn 'papers/NN-\*' CLAUDE.md .claude/agents/ docs/solutions/` returns zero occurrences of the old flat pattern in live (non-historical) context.
- All four subagent definitions still parse as valid markdown with their YAML frontmatter intact (sanity read of the first ~15 lines of each).
- A fresh reader following the "Adding a new paper" checklist in `CLAUDE.md` would land the new paper under `papers/<method>/NN-<slug>/`, not at `papers/NN-<slug>/`.

---

- [ ] **Unit 3: Retitle the landing `README.md` and regroup the contents table by methodology**

**Goal:** Change the repo's public-facing framing so "plain-language" is no longer the hook, and reorganize the contents table so readers browse by methodology instead of scrolling through a flat numeric list.

**Requirements:** R4, R5.

**Dependencies:** Unit 1 (contents-table links point at the new paths) and Unit 2 (CLAUDE.md + subagents are the documented canonical reference by the time the landing README tells readers to "see CLAUDE.md").

**Files:**
- Modify: `README.md`

**Approach:**
- **Line 1 (title):** `# Causal Inference Papers — Plain-Language Explainers` → `# Causal Inference Papers — Explainers`.
- **Line 3 (first paragraph):** rewrite so the hook is *alternative, accessible source for understanding the breadth of causal-inference papers*, not *plain-language walkthroughs*. Keep it one sentence; keep the "paired with runnable R code on simulated data" clause. Do **not** delete the plain-language framing entirely from the rest of the document — the "Who this is for" section (lines 5–14) already does the explanatory work and stays unchanged.
- **Contents section (lines 16–22):** replace the flat single-table structure with a sub-header per methodology bucket. Each bucket has its own small table (Method / Paper / Folder / One-line takeaway) that only lists papers in that bucket. Add a short leading sentence above the buckets that names the taxonomy we plan to cover (RCT, DiD, RDD, IV, synthetic control, causal AI, ...) and notes that buckets are created lazily as papers land.
- **"How to run the R code" block (lines 36–38):** update the `Rscript` example to point at `papers/did/01-.../simulation.R`.
- **"How to add a new paper" section (lines 58–64):** update step 2 so the folder pattern is `papers/<method>/NN-<first-authors>-<short-topic>/`, where `<method>` is one of the kebab-case buckets.

**Patterns to follow:**
- The current contents-table column structure (Method / Paper / Folder / One-line takeaway) is good — do not redesign it. Only replace the single table with one small table per bucket.
- The existing one-line takeaways for each paper are already calibrated and should be reused verbatim.
- Repo-relative links throughout (already the convention).

**Test scenarios:**
- Happy path: a visitor lands on the rendered README, sees "Causal Inference Papers — Explainers" (no "Plain-Language" in the title), reads a first paragraph that positions the repo as an alternative source, and sees three methodology subsections (DiD, IV, RDD) each with a link row.
- Happy path: every link in the contents section points to a valid repo-relative path that exists on disk after Unit 1. Verify manually: click/visit each of `papers/did/01-...`, `papers/iv/02-...`, `papers/rdd/03-...`.
- Edge case: the `shared/r-setup.R` package list (lines 42–44) and the `set.seed(...)` seed reference (line 55) need no changes — the R machinery itself is untouched by the reorg.
- Edge case: the "Licensing and sources" section (lines 66–70) and the "Who this is for" section (lines 5–14) need no changes — the retitle is targeted, not a full rewrite.

**Verification:**
- `grep -n 'Plain-Language\|plain-language' README.md` returns zero hits (title and first paragraph are the only two places this framing lived as a brand; other mentions in the body belong to legitimate explanatory prose and should be preserved only if they still make sense after the retitle — spot-check during the edit).
- All folder links in the contents section resolve (`test -d papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/ && ...` for each).
- The "How to run the R code" example, if copied and pasted verbatim by a reader, succeeds (same verification protocol as Unit 1: literal command from repo root, no subshell wrapper).

## System-Wide Impact

- **Interaction graph:** Four project subagents (`causal-inference-expert`, `causal-inference-professor`, `r-coding-expert`, `git-github-expert`) encode the old flat `papers/NN-*/` pattern in their prompts; they will scaffold new papers at the wrong depth until Unit 2 lands. Because the subagent pipeline is strict (expert → professor → R coder → git), a single stale reference anywhere in the chain silently misroutes new papers — every agent definition must be updated, not just the expert's.
- **Error propagation:** Until Unit 1 and its source-path fix land *in the same commit*, any `git checkout` that lands on an intermediate state would have `Rscript papers/<method>/NN-*/simulation.R` failing with the same `cannot open file '../../shared/r-setup.R'` error documented in the docs/solutions entry. The single-commit discipline for Unit 1 is the mitigation.
- **State lifecycle risks:** Pre-existing `papers/**/figures/*.png` files — if any exist locally (the directory is gitignored so nothing is tracked) — will be relocated with the `git mv` along with their parent folders. No cleanup required; new simulation runs will overwrite them in their new locations.
- **API surface parity:** The "public API" here is the set of documented `Rscript` invocations (in both the landing `README.md` and `CLAUDE.md`'s "Running the simulations" block). Both must agree on the new paths.
- **Integration coverage:** The ce:review correctness finding **COR-01** that originally triggered the `docs/solutions` entry was about *the exact documented command from docs must succeed from the repo root*. Unit 1's verification protocol re-runs that exact test at the new depth — this is the integration coverage.
- **Unchanged invariants:**
  - The 4-line script-dir preamble is byte-identical at old and new depths — only the `source()` string below it changes. The preamble's `commandArgs(--file=)` logic depends on the script discovering its own filesystem location at runtime, which is independent of where the script is stored.
  - `shared/r-setup.R` itself is unchanged. The seed, the package list, and the missing-package install hint are all untouched.
  - The 12-section per-paper README template is unchanged. The three paper READMEs' bodies are unchanged.
  - The `.gitignore` entries for `papers/**/figures/*.png` and `papers/**/figures/*.pdf` already use `**` and are bucket-tolerant — no change needed.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| A `simulation.R` silently fails after the move because the source-path fix was forgotten on one of the three files. | Unit 1's verification step runs all three `Rscript papers/<method>/NN-*/simulation.R` invocations from the repo root as the literal final step — per the `docs/solutions/` lesson, the test matches the documented command exactly. |
| A subagent definition still references `papers/NN-*/` after Unit 2, so the next new paper scaffolds at the wrong depth. | Unit 2's verification step greps for `papers/NN-\*` across `CLAUDE.md`, `.claude/agents/`, and `docs/solutions/` and expects zero matches. |
| The folder rename loses per-file history because `git` doesn't detect the rename for some reason (e.g., one file was also edited in the same commit). | Move folders with `git mv` *before* editing the `source()` line inside `simulation.R`. Commit the moves first (or at minimum stage the moves and the one-line source edits together — `git` rename-detection tolerates small content edits during move). If `git log --follow` loses the trail, revert and redo with the two operations in separate commits. |
| A reader following the landing-README "How to add a new paper" section lands a paper at `papers/NN-<slug>/` (the old pattern) instead of `papers/<method>/NN-<slug>/`. | Unit 3's rewrite of that section explicitly includes the `<method>` segment in the folder pattern, matching `CLAUDE.md`. Both documents agree. |
| The historical `docs/plans/2026-04-21-001-feat-...` plan references old paths and confuses a future reader. | That plan's `status:` frontmatter remains `active` because it was never formally closed, but this new plan supersedes it by date. A later commit can mark the historical plan `status: superseded` if desired — out of scope for this refactor. |

## Documentation / Operational Notes

- Three commits land in sequence, each a milestone (per the `CLAUDE.md` "Committing, pushing, and publishing" policy):
  1. `refactor(papers): group papers by methodology bucket` — Unit 1 (`git mv` + three `source()` path fixes). Run all three simulations clean before committing.
  2. `docs(conventions): update CLAUDE.md and subagents for methodology-bucket paths` — Unit 2.
  3. `docs(readme): drop "Plain-Language" from title and regroup contents by methodology` — Unit 3.
- After each commit, push if `git remote -v` shows an origin (per `CLAUDE.md`).
- No `.gitignore` edits, no new package installs, no `gh repo create` — this is a pure-refactor pass.
- After all three commits, a final spot-check by a fresh reader: clone the repo, run `Rscript papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R` from the repo root, confirm exit 0 and a figure under `papers/did/01-.../figures/`.

## Sources & References

- Landing page being retitled: [`README.md`](../../README.md)
- Project conventions being updated: [`CLAUDE.md`](../../CLAUDE.md)
- Subagent definitions being updated: [`.claude/agents/`](../../.claude/agents/)
- Path-depth learning this refactor depends on: [`docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md`](../solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md)
- Historical scaffolding plan (superseded by this one): [`docs/plans/2026-04-21-001-feat-causal-inference-papers-explainer-plan.md`](./2026-04-21-001-feat-causal-inference-papers-explainer-plan.md)
