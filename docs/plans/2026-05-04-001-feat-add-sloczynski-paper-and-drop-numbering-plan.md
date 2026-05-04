---
title: "Add Słoczyński (2022) IV-LATE explainer; drop folder numbering; simplify URL anchors repo-wide"
type: feat
status: active
date: 2026-05-04
---

# Add Słoczyński (2022) IV-LATE explainer; drop folder numbering; simplify URL anchors repo-wide

## Overview

Two intertwined changes:

1. **New paper.** Add an explainer for Słoczyński, T. (2022). *When should we (not) interpret linear IV estimands as LATE?* (arXiv:2011.06695). Paper sits in the `iv/` bucket and complements paper 02 (Blandhol et al.) — Słoczyński shows that even saturated linear-IV with a *binary treatment* and a single binary covariate can produce wildly off-target estimands when treatment-probability variation across covariate cells is large.
2. **Repo-wide cleanup.** Drop the global `NN-` folder-numbering convention (rename existing folders, update CLAUDE.md, README, subagent prompts, Colab-badge URLs, plan-doc cross-refs in living docs only). Replace long, hard-to-read URL anchors (`<https://...>`, raw `https://scholar.google.com/scholar?q=...`) with concise human-readable link text (`[arXiv](...)`, `[NBER working paper](...)`, `[Google Scholar search](...)`).

Both changes ship together because (a) the new paper is the first one written under the new no-numbering convention, and (b) renaming is the natural moment to also clean link presentation.

## Problem Frame

- The current `NN-` numbering signals an order that is not actually meaningful (it's arrival order, not importance, not dependency). Readers and contributors keep asking what the numbers mean. Folders are easier to scan without them, and the per-bucket grouping in the contents table already provides structure.
- Several explainers expose raw URLs as their anchor text — `<https://www.nber.org/papers/w29709>`, `<https://scholar.google.com/scholar?q=De+Magalh%C3%A3es+...>`. These read as visual noise. The intent is plain prose first; URLs should be hidden behind short words.
- Słoczyński (2022) is the right next paper for the IV bucket: it tightens the Blandhol et al. story by showing the LATE-vs-non-LATE gap can be enormous in everyday applied setups, and it has a closed-form weight expression that simulates cleanly.

## Requirements Trace

- **R1.** Słoczyński (2022) ships as a complete paper folder under `papers/iv/` with a 12-section README, an executable `simulation.ipynb` (R kernel), and a `references.md`, all conforming to CLAUDE.md.
- **R2.** The `/review-paper` skill is run on the Słoczyński PDF and its output (referee-style review) is consulted by `causal-inference-expert` while drafting the technical sections (1, 5, 7, 8, 9). The review report itself is saved to `quality_reports/` and is not part of the explainer artifact.
- **R3.** No paper folder retains the `NN-` prefix. Old folders are git-renamed (history-preserving), not deleted-and-recreated.
- **R4.** No README, CLAUDE.md, subagent prompt, contents table, Colab-badge URL, or section-11 example command in any *living* repo file references an `NN-` path or the "paper 02" / "paper 03" naming; references *inside historical plan documents* under `docs/plans/2026-04-*` and `2026-04-30-*` are preserved as-is (those are historical artifacts).
- **R5.** Long, raw, or hash-bearing URL anchors in `papers/*/*/README.md` and `papers/*/*/references.md` are replaced with concise anchor text. The full URL still resolves; only the visible link text changes.
- **R6.** Top-level `README.md` contents table no longer has a `#` column. The methodology sub-headings remain.
- **R7.** Each touched `simulation.ipynb` re-executes cleanly via `jupyter nbconvert --to notebook --execute --inplace` after any path/Colab-badge change, with rendered outputs committed.
- **R8.** Commits land per the milestone cadence in CLAUDE.md (one logical change per commit, push after each).

## Scope Boundaries

- **In scope:** new paper folder; repo-wide rename of three existing folders; CLAUDE.md + top README + subagent-prompt updates; URL anchor cleanup in living docs; Colab-badge URL refresh; re-execution of all four notebooks.
- **Out of scope:** changes to the simulation logic of the three existing notebooks (only Colab-badge URLs and any in-notebook path strings change); rewriting any explainer's prose beyond what link cleanup requires.

### Deferred to Separate Tasks

- **Editing historical plan files** under `docs/plans/2026-04-21-*` and `docs/plans/2026-04-30-*` to drop `NN-` references: deferred indefinitely. Plans are point-in-time records; rewriting them rewrites history.
- **Adding a CI workflow that re-executes notebooks on PR**: already listed under "Future extensions" in CLAUDE.md and not pulled in here.

## Context & Research

### Relevant Code and Patterns

- `CLAUDE.md` — single source of truth for folder layout, the 12-section README template, the 4-agent pipeline, and notebook conventions. References `NN-` in 7 places (folder layout, numbering paragraph, agent table, checklist, the "Running the simulations" links section, and two `jupyter nbconvert` invocations).
- `README.md` (top-level) — references `NN-` in the contents-table preamble paragraph, in three table rows (one per paper), in two `jupyter` example commands, and once in the "How to add a new paper" step list.
- `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/README.md` — model README. Section 2 contains `*Paper 02 — Instrumental Variables / Two-Stage Least Squares*` subtitle line. Section 11's `jupyter nbconvert` command embeds the numbered path.
- `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/references.md` — line 7 shows the long-URL pattern: `- NBER: <https://www.nber.org/papers/w29709>`. Same pattern repeats in the DiD and RDD `references.md` and `README.md` Section 1 blocks.
- All three `simulation.ipynb` files — Colab badge in cell index 0 hardcodes `github/afrtrivi1120/causal-inference-papers-explainer/blob/master/papers/<bucket>/<NN-slug>/simulation.ipynb`. The `<NN-slug>` segment must change.
- `.claude/agents/causal-inference-expert.md`, `.claude/agents/causal-inference-professor.md`, `.claude/agents/simulation-notebook-expert.md` — each prompt references `papers/<method>/NN-*/...` patterns. (`git-github-expert.md` may also; verify during execution.)

### Institutional Learnings

- The two recent solution docs in `docs/solutions/` (single-draw notebook seed-survivability discipline; CLAUDE.md ↔ `.claude/agents` sweep discipline) bear directly on this work — when CLAUDE.md changes, the four `.claude/agents/*.md` files must be re-read and updated in the same PR. Reflected in Unit 1.

### External References

- arXiv abstract for Słoczyński (2022): `https://arxiv.org/abs/2011.06695`. Public PDF: `https://arxiv.org/pdf/2011.06695`. Published as Słoczyński, T. (2022). "When Should We (Not) Interpret Linear IV Estimands as LATE?" — *Quantitative Economics* / pre-print, depending on which version of record we cite. The arXiv ID is the durable identifier.
- The paper's central object: a closed-form expression for the linear-IV estimand as a weighted combination of subgroup LATEs, where weights depend on a cross-section of `Var(Z|X) × first_stage(X)` ratios. Notably, Słoczyński shows the weight on the larger covariate cell can become negative even with monotonicity satisfied — strictly stronger than the Blandhol et al. negative-weight result for fully-saturated specs.

## Key Technical Decisions

- **Numbering removed entirely, not retained as a sort key.** The contents-table sub-headings (DiD / IV / RDD / ...) already group entries; no fallback ordering is needed. Folder names sort alphabetically by first-author surname inside each bucket, which is acceptable.
- **New folder slug for Słoczyński (2022): `papers/iv/sloczynski-linear-iv-late/`.** First author surname (no diacritics in the path — git/Jupyter portability), short topical token. Matches the post-rename convention.
- **Renames use `git mv` (history-preserving), in a dedicated commit, before any new content lands.** Prevents the new-paper commit from being polluted with rename diff noise.
- **Colab badges encode the post-rename path.** They are committed once at the end of the rename + Słoczyński add, after a clean nbconvert pass for all four notebooks.
- **`/review-paper` runs early — before the expert agent.** The review output goes to `quality_reports/paper_review_sloczynski_2022.md` and is referenced (not pasted verbatim) by the causal-inference-expert subagent during section 1/5/7/8/9 drafting. The review report is gitignored if it would otherwise contain reproduced paper text; see Unit 4 for handling.
- **Link-anchor convention going forward.** Each link uses one of: `[arXiv](...)`, `[NBER working paper](...)`, `[publisher page](...)`, `[Google Scholar search](...)`, `[Open in Colab](...)`. The bare-URL form `<https://...>` is reserved for cases where there is no natural text label (rare in this repo). This convention is added to CLAUDE.md (Section: Language and tone, sub-bullet "Linking").
- **CLAUDE.md updates are the master change.** All other living docs (top README, subagent prompts, the new paper) follow CLAUDE.md after it is updated, not the other way around.
- **Existing explainers' link anchors are simplified in-place** (Unit 5). Prose changes are minimal — only the visible anchor text changes; the URL targets stay the same so external bookmarks still work.

## Open Questions

### Resolved During Planning

- **Should historical plans be updated for the rename?** No. Historical `docs/plans/2026-04-*` files are point-in-time artifacts. They would lie about what was committed at the time. Living docs only.
- **What slug should Słoczyński's folder use?** `sloczynski-linear-iv-late`. Drops the diacritic for path safety; the README displays `Słoczyński` correctly because it is UTF-8 prose, not a path component.
- **Does the `/review-paper` skill output need to land in the repo?** No — it lives in `quality_reports/`, which is already gitignored at the user's home (skill default), or if not, it can be added to this repo's `.gitignore` in Unit 1. Either way, it is reference material, not an artifact of the explainer.

### Deferred to Implementation

- **Whether `git-github-expert.md` references `NN-` patterns.** Verify by `grep -n 'NN-' .claude/agents/git-github-expert.md` during Unit 1 and update if so. Not pre-resolved here because the agent file may or may not embed the pattern.
- **Whether `tidyverse` alone is enough for Słoczyński's notebook, or if `AER` is also needed for the linear-IV estimator.** Most likely `AER::ivreg` is the cleanest path (mirrors paper 02). Final dep list lives in the notebook's setup cell. Decided at Unit 6 implementation time by `simulation-notebook-expert`.
- **Exact section-11 representative output numbers.** Depend on the DGP the simulation-notebook-expert chooses and on the seed. Decided at Unit 6 execution time.

## Implementation Units

- [ ] **Unit 1: Update `CLAUDE.md` and the top-level `README.md` to drop `NN-` and codify the link-anchor convention.**

**Goal:** Change the documented convention before changing anything on disk that depends on it. After this unit lands, every other unit consults the new CLAUDE.md.

**Requirements:** R3, R4, R5, R6.

**Dependencies:** None.

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md`

**Approach:**
- In `CLAUDE.md`: rewrite the folder-layout fenced block (line ~14) to drop the `NN-` token; rewrite the "Folder numbering:" paragraph (line ~32) to a one-liner explaining there is no global numbering — folders sort alphabetically by first-author surname inside each bucket; update the agent-routing table cells that say `papers/<method>/NN-*/...` to `papers/<method>/<slug>/...`; update the "Adding a new paper — checklist" line accordingly; update the "Running the simulations" bullets to point to the post-rename paths *and the post-rename Słoczyński path* (so this unit also forecasts Unit 6's path). Add a new "Linking" sub-bullet under "Language and tone" enumerating the allowed anchor forms.
- In top-level `README.md`: drop the `# |` column from each of the three contents-table headers and rows; rewrite the contents-table preamble paragraph (line ~18) to remove the "paper numbering (`NN-`) is global" sentence; rewrite the two `jupyter` example commands to use the post-rename paths; rewrite the "How to add a new paper" step 2 to drop `NN-`.
- Optionally add `quality_reports/` to `.gitignore` if it is not already covered, so the review-paper output (Unit 4) does not need a manual ignore.

**Patterns to follow:**
- Existing `CLAUDE.md` section ordering and tone. Plain language, no jargon dump.
- Existing top-README table style.

**Test scenarios:**
- Verification: none — this is convention/docs scaffolding. The downstream units exercise the convention.

**Verification:**
- `grep -n 'NN-' CLAUDE.md README.md` returns zero hits.
- Top README's contents tables have three columns (Paper / Folder / One-line takeaway), not four.
- The new "Linking" bullet exists under "Language and tone" in CLAUDE.md.

- [ ] **Unit 2: Update the four `.claude/agents/*.md` subagent prompts to drop `NN-` and reflect the new linking convention.**

**Goal:** Keep the subagent prompts in lockstep with CLAUDE.md so the next pipeline run produces convention-compliant output.

**Requirements:** R3, R4, R5.

**Dependencies:** Unit 1.

**Files:**
- Modify: `.claude/agents/causal-inference-expert.md`
- Modify: `.claude/agents/causal-inference-professor.md`
- Modify: `.claude/agents/simulation-notebook-expert.md`
- Modify: `.claude/agents/git-github-expert.md` (only if grep shows `NN-` is referenced)

**Approach:**
- Replace `papers/<method>/NN-<slug>/` with `papers/<method>/<slug>/` everywhere it appears in the four agent prompts.
- Add a one-liner in `causal-inference-expert.md` and `causal-inference-professor.md` instructing them to use the new link-anchor convention (mirror the bullets in CLAUDE.md, do not duplicate the full text — link to it).
- Run `grep -rn 'NN-\|01-\|02-\|03-' .claude/agents/` after the edits to confirm zero residual hits.

**Patterns to follow:**
- The existing subagent-file structure (frontmatter + sections).
- Cross-reference CLAUDE.md by anchor when possible rather than copying its rules.

**Test scenarios:**
- Verification: none — these are agent prompts, not executable code. Downstream units (4–6) exercise them.

**Verification:**
- `grep -rn 'NN-' .claude/agents/` returns zero hits.
- Each subagent file still parses (no broken markdown headings).

- [ ] **Unit 3: Rename the three existing paper folders with `git mv`; update all in-repo cross-references; re-execute the three notebooks.**

**Goal:** Translate the new convention into on-disk reality for the three already-shipped papers, without touching their content.

**Requirements:** R3, R4, R7.

**Dependencies:** Unit 1, Unit 2.

**Files:**
- Rename (via `git mv`):
  - `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/` → `papers/did/ghanem-santanna-wuthrich-selection-parallel-trends/`
  - `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/` → `papers/iv/blandhol-bonney-mogstad-torgovitsky-tsls-late/`
  - `papers/rdd/03-demagalhaes-et-al-rdd-close-elections/` → `papers/rdd/demagalhaes-et-al-rdd-close-elections/`
- Modify (cross-ref text inside each renamed folder):
  - `papers/did/.../README.md` — drop the `*Paper 01 — ...*` subtitle line under Section 1; update Section 11's `jupyter nbconvert` command path
  - `papers/iv/.../README.md` — same (drop `*Paper 02 — ...*`, update Section 11 command path)
  - `papers/rdd/.../README.md` — same (drop `*Paper 03 — ...*`, update Section 11 command path)
  - `papers/did/.../simulation.ipynb` — Colab badge URL: replace `papers/did/01-ghanem-...` with `papers/did/ghanem-...`
  - `papers/iv/.../simulation.ipynb` — Colab badge URL: replace `papers/iv/02-blandhol-...` with `papers/iv/blandhol-...`
  - `papers/rdd/.../simulation.ipynb` — Colab badge URL: replace `papers/rdd/03-demagalhaes-...` with `papers/rdd/demagalhaes-...`

**Approach:**
- Use `git mv` for each rename (one folder at a time) so git tracks history.
- After all three renames, run `grep -rn '01-ghanem\|02-blandhol\|03-demagalhaes\|NN-' --include='*.md' --include='*.ipynb' papers/ README.md CLAUDE.md` and fix any residual hits *outside* `docs/plans/`.
- Re-execute each notebook in place: `jupyter nbconvert --to notebook --execute --inplace papers/<method>/<slug>/simulation.ipynb` for all three. Confirm exit 0.
- Diff the re-executed notebooks against the prior committed versions: only the Colab-badge URL string and possibly a re-rendered cell-execution-count should change. If outputs drift, the seed has not been respected — investigate before proceeding (would indicate a deeper bug not in this plan's scope).

**Patterns to follow:**
- The seed-survivability discipline from `docs/solutions/` — re-execution must preserve published numbers.

**Test scenarios:**
- Happy path — `find papers -type d -name '0[123]-*'` returns nothing.
- Happy path — each of the three renamed `simulation.ipynb` files executes 0 under `jupyter nbconvert --execute --inplace`.
- Happy path — `grep -rn 'NN-\|01-ghanem\|02-blandhol\|03-demagalhaes' README.md CLAUDE.md papers/ .claude/agents/` returns zero hits.
- Edge case — if any of the three notebooks' executed output cells differ on numerical values from the pre-rename version, halt and investigate; expected diff is metadata + Colab-badge URL only.

**Verification:**
- `git status` shows R-status on the three folders (rename detected).
- `grep` checks above all return zero.
- All three notebooks execute clean and committed with rendered outputs.

- [ ] **Unit 4: Run the `/review-paper` skill on Słoczyński (2022) and stash the report.**

**Goal:** Produce the deep-context referee-style review that the `causal-inference-expert` subagent will consult while drafting Sections 1, 5, 7, 8, 9 of the new explainer.

**Requirements:** R2.

**Dependencies:** Unit 1 (so `quality_reports/` is gitignored).

**Files:**
- Create (gitignored, outside the repo's tracked tree): `quality_reports/paper_review_sloczynski_2022.md`
- Required input: the Słoczyński (2022) PDF dropped at the repo root before this unit runs (per CLAUDE.md "Adding a new paper — checklist"). PDF is gitignored.

**Approach:**
- User drops `2011.06695.pdf` (or equivalent filename) at repo root.
- Invoke `/review-paper <pdf-path>`. The skill reads the PDF in chunks and emits a 6-dimension review plus 3–5 referee objections.
- Skim the report; surface for the user a 3–5-bullet summary of the most explainer-relevant findings (the central estimand decomposition, the negative-weight conditions, the empirical illustration in the paper, and any caveats Słoczyński himself flags about Blandhol et al.). The full report stays in `quality_reports/`.

**Patterns to follow:**
- `/review-paper` skill output template — six dimensions + referee objections + ratings.

**Test scenarios:**
- Verification: none — output is a knowledge artifact, not code.

**Verification:**
- `quality_reports/paper_review_sloczynski_2022.md` exists and contains the six review-dimension headers, referee objections, and ratings.
- The 3–5 bullet summary is captured for handoff to Unit 5 (likely as part of the `causal-inference-expert` subagent's context).

- [ ] **Unit 5: Draft the Słoczyński (2022) explainer scaffolding via the `causal-inference-expert` subagent.**

**Goal:** Produce `papers/iv/sloczynski-linear-iv-late/README.md` (12-section template, with Sections 1, 5, 7, 8, 9 fully drafted and Sections 2, 4, 6, 10 left as `TODO:` placeholders) plus `papers/iv/sloczynski-linear-iv-late/references.md` (full citation + 3–5 adjacent readings using the new link-anchor convention).

**Requirements:** R1, R2, R5.

**Dependencies:** Units 1, 2, 4.

**Files:**
- Create: `papers/iv/sloczynski-linear-iv-late/README.md`
- Create: `papers/iv/sloczynski-linear-iv-late/references.md`

**Approach:**
- Invoke `causal-inference-expert` with: the paper PDF, the review-paper output from Unit 4, the post-rename Blandhol et al. README as a structural model, and explicit instructions that (a) the bucket is `iv/`, (b) the slug is `sloczynski-linear-iv-late`, (c) the linking convention is the new one in CLAUDE.md.
- Section 1 ("Citation"): full reference; one short link `[arXiv](https://arxiv.org/abs/2011.06695)` in the body, plus the canonical pointer to `references.md`.
- Section 5 ("Glossary"): all jargon used later — linear IV estimand, complier-mass weighting, weight-on-the-non-complier, propensity-score variation, monotonicity, conditional saturation. Define every term used in 7 and 8.
- Section 7 ("Method walkthrough"): present Słoczyński's decomposition formula in words, state the closed-form weight expression once as a reference (one fenced equation block), and walk the binary-treatment / binary-covariate special case that anchors the simulation.
- Section 8 ("Assumptions and when they fail"): be explicit that Słoczyński's result *adds* to (not replaces) Blandhol et al. — even when monotonicity holds and `Z` is conditionally random, the linear-IV weights can still be negative on the larger cell. Name the failure mode: when one covariate cell has near-constant treatment, all the identifying variation comes from the other cell, and the apparent "average" silently equals one cell's effect.
- Section 9 ("Findings"): paraphrase the paper's main numerical illustrations (it has applied case studies) without verbatim quotation.
- `references.md`: 3–5 adjacent readings — Imbens & Angrist (1994), Angrist & Imbens (1995), Blandhol et al. (2025), Mogstad-Torgovitsky-Walters (2021), Kolesár (2013). All using the new link-anchor convention.

**Patterns to follow:**
- `papers/iv/blandhol-bonney-mogstad-torgovitsky-tsls-late/README.md` — same bucket, same general 12-section shape, same level of rigor.
- The new linking convention from CLAUDE.md.

**Test scenarios:**
- Verification: none directly; Unit 7 (`causal-inference-professor`) consumes this draft and Unit 8 (`simulation-notebook-expert`) closes Section 11. The git agent in Unit 9 will refuse to commit if any 12-section slot still has `TODO:`.

**Verification:**
- 12-section README exists with Sections 1, 5, 7, 8, 9 filled and Sections 2, 4, 6, 10, 11 marked `TODO:`.
- `references.md` exists with the new link-anchor style.
- `grep -n '<https://' papers/iv/sloczynski-linear-iv-late/references.md` returns at most one hit, and only for a case with no natural text label.

- [ ] **Unit 6: Rewrite Sections 2 (TL;DR), 4 (Causal question), 6 (Core idea), 10 (Practitioner takeaway) via `causal-inference-professor`.**

**Goal:** Convert the technically-correct expert draft into plain-language sections an econ-curious reader can follow without prior IV training.

**Requirements:** R1.

**Dependencies:** Unit 5.

**Files:**
- Modify: `papers/iv/sloczynski-linear-iv-late/README.md` (Sections 2, 4, 6, 10 only)

**Approach:**
- Invoke `causal-inference-professor` with the post-Unit-5 README and the Blandhol et al. README as a tone reference.
- Section 6 ("Core idea") needs a concrete analogy — a parallel of the coupon analogy in paper 02 but framed around "when one cell barely complies, you're really only measuring the other cell".
- Section 10 ("Practitioner takeaway") should explicitly contrast Słoczyński's recommendations with Blandhol et al.'s saturation prescription — Słoczyński shows the problem persists even *after* saturation if propensity-score variation across cells is extreme, so the practical fix is not just "saturate" but "report the cell-specific effects and the implied weights".
- The professor must not introduce new Glossary terms — if a term is needed, kick back to the expert.

**Patterns to follow:**
- Pedagogy bar: a motivated reader with no prior econometrics should follow Sections 2, 4, 6, 10.

**Test scenarios:**
- Verification: none — pedagogy is judged by the orchestrator + user review at hand-off.

**Verification:**
- All four sections are fully written, no `TODO:` strings remain in those slots.
- Section 6 contains at least one analogy that is not algebra.
- Glossary (Section 5) is unchanged from the expert pass — confirm via diff.

- [ ] **Unit 7: Build the simulation notebook and write Section 11 via `simulation-notebook-expert`.**

**Goal:** Produce `papers/iv/sloczynski-linear-iv-late/simulation.ipynb` that simulates a binary-treatment, binary-covariate DGP where the linear-IV estimand visibly differs from the cell-mass-weighted LATE; print a truth-vs-estimate tibble; render at least one ggplot2 diagnostic; and fill Section 11 of the README with a one-paragraph DGP summary plus the representative output block.

**Requirements:** R1, R7.

**Dependencies:** Unit 5, Unit 6.

**Files:**
- Create: `papers/iv/sloczynski-linear-iv-late/simulation.ipynb`
- Modify: `papers/iv/sloczynski-linear-iv-late/README.md` (Section 11 only)

**Approach:**
- Setup cell: defensive `install.packages('AER', ...)` (likely needed for `ivreg`) and any other missing dep; `suppressPackageStartupMessages({ library(...) })`; `set.seed(20260421)`; version-print block. Per CLAUDE.md, single-draw demo — no `N_SIM` constant needed.
- DGP idea (final values to be determined by the expert): binary `X`, conditionally random binary `Z`, binary `D`, two stratum LATEs `LATE(X=0)` and `LATE(X=1)` chosen so that linear IV's negative-weight regime bites. Choose stratum complier shares such that the implied linear-IV weights are explicit and easy to display.
- Print a tibble showing: true cell-mass-weighted LATE, linear-IV estimand (closed-form), naive linear-IV regression coefficient (estimated), and gap in each. Make the rownames-vs-positional-index discipline from the existing notebooks the default.
- Render a single ggplot2 figure that visualizes the weight discrepancy (e.g., bar plot: cell-mass weight vs linear-IV weight per cell) — this is the punchline visual.
- Section 11 of the README:
  - Three-bullet DGP summary (covariate, instrument, treatment, true LATE, true linear-IV estimand).
  - One representative output block (similar shape to paper 02's Section 11) showing truth, linear-IV estimate, gap.
  - One-sentence reading of what the diagnostic plot makes visible.
  - Closing line referencing the Colab badge.
- Re-execute the notebook with `jupyter nbconvert --to notebook --execute --inplace`. Commit with rendered outputs.

**Patterns to follow:**
- `papers/iv/blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.ipynb` — same style, same setup-cell shape, same single-draw discipline (per the recent notebook-simplification refactor).

**Test scenarios:**
- Happy path — `jupyter nbconvert --to notebook --execute --inplace papers/iv/sloczynski-linear-iv-late/simulation.ipynb` exits 0 with rendered outputs.
- Happy path — final printed tibble shows three rows (Truth, Linear-IV estimand closed form, Linear-IV coefficient) with a numerically meaningful gap.
- Edge case — re-running the notebook a second time produces byte-identical numerical output (seed-survivability).
- Integration — the README's Section 11 representative output matches what the notebook actually printed (no drift).

**Verification:**
- The notebook's last cell prints a non-empty plot.
- The notebook's printed tibble matches the README Section 11 block.
- Section 11 ends with a Colab-badge sentence.

- [ ] **Unit 8: Repo-wide URL-anchor cleanup pass on the three pre-existing paper folders.**

**Goal:** Convert long-URL anchors and bare URLs in the three already-shipped explainers (DiD, IV-Blandhol, RDD) to the new convention.

**Requirements:** R5.

**Dependencies:** Unit 1 (convention codified), Unit 3 (folders renamed).

**Files:**
- Modify: `papers/did/ghanem-santanna-wuthrich-selection-parallel-trends/README.md` (Section 1 link, anywhere a bare URL appears in prose)
- Modify: `papers/did/ghanem-santanna-wuthrich-selection-parallel-trends/references.md`
- Modify: `papers/iv/blandhol-bonney-mogstad-torgovitsky-tsls-late/README.md`
- Modify: `papers/iv/blandhol-bonney-mogstad-torgovitsky-tsls-late/references.md`
- Modify: `papers/rdd/demagalhaes-et-al-rdd-close-elections/README.md`
- Modify: `papers/rdd/demagalhaes-et-al-rdd-close-elections/references.md`

**Approach:**
- For each file, replace every `<https://...>` and every long anchor of the form `[https://scholar.google.com/scholar?q=...](...)` with a short-text anchor:
  - `<https://www.nber.org/papers/w29709>` → `[NBER working paper](https://www.nber.org/papers/w29709)`
  - `<https://arxiv.org/abs/2203.09001>` → `[arXiv](https://arxiv.org/abs/2203.09001)`
  - `<https://scholar.google.com/scholar?q=De+Magalh%C3%A3es+...>` → `[Google Scholar search](https://scholar.google.com/scholar?q=De+Magalh%C3%A3es+...)`
  - The `[Google Scholar](...)` row in the De Magalhães README's Section 1 is already in good shape but still embeds a long query — replace with `[Google Scholar search](...)` for consistency.
- After edits, run `grep -rn '<https://' papers/` — should return at most a handful of cases that genuinely have no natural text label, and each should be justifiable.

**Patterns to follow:**
- The link-anchor convention from Unit 1 (CLAUDE.md "Linking" sub-bullet).

**Test scenarios:**
- Edge case — `grep -rn '<https://' papers/` ideally returns zero, certainly fewer than five hits.
- Edge case — each link still resolves (the URL target is unchanged; only anchor text changed).
- Happy path — visual scan of each Section 1 in the three READMEs reads as prose first, URLs second.

**Verification:**
- Zero raw `<https://...>` anchors except where the link genuinely has no natural text label.
- All link targets are unchanged from before this unit (`git diff` shows only anchor-text changes, not URL changes).

- [ ] **Unit 9: Update top-level README contents table; commit and push milestones via `git-github-expert`.**

**Goal:** Add the new paper's row under "Instrumental Variables (IV)", confirm CLAUDE.md and `.claude/agents/` are in sync, run the standard pre-commit checks, and ship.

**Requirements:** R3, R4, R5, R6, R7, R8.

**Dependencies:** Units 1–8.

**Files:**
- Modify: `README.md` (add row to the IV contents-table block)

**Approach:**
- Add a row to the IV table (now three columns):
  - Paper: `Słoczyński — *When Should We (Not) Interpret Linear IV Estimands as LATE?*`
  - Folder: `[`papers/iv/sloczynski-linear-iv-late/`](papers/iv/sloczynski-linear-iv-late/)`
  - One-line takeaway: drafted from the paper's punchline — something like "Even with conditional random assignment, monotonicity, *and* saturation, linear IV can put negative weight on the larger covariate cell — what looks like an average is often a single cell's effect in disguise."
- `git-github-expert` runs the pre-commit checklist from CLAUDE.md:
  - All four `simulation.ipynb` files re-execute clean.
  - No `TODO:` placeholder in any 12-section slot of any paper README.
  - `git check-ignore *.pdf` confirms PDFs untracked.
  - No bypassed hooks.
- Commit cadence — separate commits per logical change (per CLAUDE.md):
  1. `chore(repo): drop NN- folder numbering convention; codify link-anchor rules` (CLAUDE.md + top README + `.claude/agents/*` from Units 1–2)
  2. `refactor(papers): rename three paper folders to drop NN- prefix` (Unit 3 git-mv + cross-ref updates + notebook re-execution)
  3. `docs(papers): simplify URL anchors across existing explainers` (Unit 8)
  4. `feat(papers/iv): add Słoczyński (2022) IV-LATE explainer` (Units 5–7, all the new-paper content)
  5. `docs(readme): add Słoczyński paper to contents` (Unit 9 README row)
- Push after each commit if `origin` exists; otherwise hold and surface the `gh repo create` instruction.

**Patterns to follow:**
- CLAUDE.md "Committing, pushing, and publishing" section.

**Test scenarios:**
- Happy path — `git log --oneline -5` shows the five commits in the order above (or four if Unit 8's cleanup is small enough to fold into commit 1; agent's call).
- Edge case — `git status` post-push shows clean tree.
- Integration — opening the new paper folder on GitHub renders the notebook with outputs and the Colab badge points to the correct path.

**Verification:**
- All commits land with conventional prefixes.
- Each commit message references the right requirement.
- `git push` succeeds (or the agent surfaces "no remote yet" cleanly).
- `find papers -type d -name '0[123]-*'` returns nothing.
- Top README's IV table has two rows (Blandhol, Słoczyński).

## System-Wide Impact

- **Interaction graph:** the four `.claude/agents/*.md` subagent prompts, CLAUDE.md, and the top-level README are all interlocked. A change in one of them must propagate to the others in the same PR — Unit 1 + Unit 2 enforce that. The `docs/solutions/` learning about CLAUDE.md ↔ subagent sweeps applies directly.
- **Error propagation:** if Unit 3's rename mid-step is interrupted, repo state is incoherent (folders missing, references broken). Mitigation: each rename is one `git mv` followed by an immediate cross-reference grep + fix; do all three before committing.
- **State lifecycle risks:** Colab-badge URLs hardcode the GitHub repo path. The repo name is `causal-inference-papers-explainer` (per the existing badges); this plan does not change the repo name, only the path-segment after `master/`. If the repo is later renamed, all four notebooks need their badges updated separately.
- **API surface parity:** the rename changes every existing public-facing path. Anyone who has bookmarked `papers/iv/02-blandhol-...` from GitHub gets a 404. Acceptable cost — the repo is small and pre-public-launch.
- **Integration coverage:** the `jupyter nbconvert --execute` re-runs in Unit 3 and Unit 7 are the only tests that catch a Colab-badge or path-string regression in the notebooks.
- **Unchanged invariants:** the 12-section README template is unchanged. The notebook conventions (R kernel, seed `20260421`, single-draw discipline, truth-vs-estimate output, at least one diagnostic plot) are unchanged. The four-agent pipeline is unchanged. The numerical content of the three pre-existing simulations is unchanged — only their folder paths and Colab-badge URLs change.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Rename in Unit 3 leaves a stale path in a file the grep misses (e.g., a lesser-used markdown reference). | After Unit 3, run `grep -rn 'NN-\|01-ghanem\|02-blandhol\|03-demagalhaes' README.md CLAUDE.md papers/ .claude/agents/ docs/` and treat any hit outside `docs/plans/2026-04-*` as a bug to fix in the same commit. |
| Notebook re-execution in Unit 3 produces drifted outputs because of an unrelated package-version bump on the local machine. | The pre-commit checklist already requires the notebook to execute clean. If outputs drift on an unchanged path, that is a pre-existing issue — pause, surface to the user, do not commit. |
| `/review-paper` skill output reproduces too much paper text and triggers the "do not paste verbatim" rule from CLAUDE.md. | Treat the review report as private reference material under `quality_reports/` (gitignored). The expert agent paraphrases for Sections 1/5/7/8/9; nothing from `quality_reports/` lands in the explainer verbatim. |
| Słoczyński PDF not yet at repo root when the pipeline starts. | `causal-inference-expert` and `/review-paper` both require the PDF. Halt at Unit 4 and ask the user to drop the PDF before continuing. |
| `git mv` on macOS case-insensitive filesystem accidentally collides with an existing folder. | Slugs are unambiguously distinct (`ghanem-...`, `blandhol-...`, `demagalhaes-...`, `sloczynski-...`); no collision risk. |
| Negative-weight DGP for the simulation produces non-intuitive numbers (e.g., the linear-IV estimand has the wrong sign, which is the *paper's* point but may confuse readers). | Section 11 explicitly frames the wrong-sign / negative-weight outcome as the punchline, with the diagnostic plot making the weight discrepancy visible. Pedagogy is the professor's job in Unit 6. |

## Documentation / Operational Notes

- `quality_reports/paper_review_sloczynski_2022.md` is a knowledge artifact, not a deliverable. It is referenced by Unit 5 but does not appear in any commit.
- Bookmarks to old `papers/iv/02-...` paths break after Unit 3. Acceptable — repo is small and personally maintained.
- The plan file itself (`docs/plans/2026-05-04-001-feat-add-sloczynski-paper-and-drop-numbering-plan.md`) is not part of any commit unless the user explicitly asks; in this repo's convention, plans are committed when meaningful (see CLAUDE.md commit-cadence table — `docs(plans): ...`).

## Sources & References

- Origin document: none (direct invocation).
- Repo conventions: `CLAUDE.md` (folder layout, 12-section template, agent pipeline, notebook conventions, commit cadence).
- Pattern references: `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/README.md`, `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/references.md`, `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.ipynb`.
- Skill reference: `/review-paper` skill at `~/.claude/skills/review-paper/SKILL.md`.
- External: arXiv:2011.06695 (Słoczyński 2022).
- Recent learning: `docs/solutions/` entries on CLAUDE.md ↔ subagent sweep discipline and single-draw notebook seed-survivability.
