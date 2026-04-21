---
title: Causal Inference Papers Explainer — repository scaffold + first 3 explainers
type: feat
status: active
date: 2026-04-21
---

# Causal Inference Papers Explainer — repository scaffold + first 3 explainers

> **Note on plan location:** `ce:plan` would normally write to `docs/plans/2026-04-21-001-feat-causal-inference-papers-explainer-plan.md` inside the repo. Plan mode restricts edits to this file, so the canonical plan lives here and will be copied into the repo as the first implementation step.

## Overview

Turn `~/Dropbox/other_academic/papers_explainer` into a public-facing GitHub-ready repository that explains methodological causal-inference papers in plain language for readers with no prior econometrics background, paired with runnable R simulations for methodological papers. The first pass scaffolds the repo structure, defines four purpose-built Claude subagents, and drafts complete explainers + simulations for the three PDFs currently in the folder (DiD/selection, TSLS/LATE, RDD).

## Problem Frame

- The user has three methodological causal-inference PDFs sitting in a Dropbox folder with no structure, no git, and no documentation.
- They want a reusable, GitHub-ready layout: a landing README, per-paper folders with plain-language explainers, and runnable R examples on simulated data for methodological papers. Non-methodological papers would get explainers only.
- They also want durable tooling: custom subagents specialized in causal inference (technical), pedagogy, R, and git/GitHub, so future papers can be dropped in and handled via the same pipeline.
- Target reader: a motivated learner with no prior causal-inference background who nonetheless wants methodological detail.

## Requirements Trace

- **R1.** A GitHub landing `README.md` explains what the repo is, who it's for, and lists every paper with a one-line takeaway.
- **R2.** A `CLAUDE.md` captures project conventions (language, folder template, R style, subagent routing) so future papers are handled consistently.
- **R3.** Each paper lives in its own folder with a plain-language `README.md` explainer and (for methodological papers) a `simulation.R` with simulated empirical example.
- **R4.** Four project subagents exist in `.claude/agents/`: a causal-inference expert (technical accuracy), a causal-inference professor (pedagogy), an R coding expert, and a git/GitHub expert.
- **R5.** PDFs are not committed to git; explainers link to official/arXiv sources instead.
- **R6.** Local git is initialized; GitHub repo creation is documented but left for the user to run via `gh repo create`.
- **R7.** All three current papers get complete explainers and simulations in this first pass.

## Scope Boundaries

- **Not in scope:** pushing to GitHub, creating the remote repo, configuring any CI/CD.
- **Not in scope:** translating explainers to Spanish (English only for this pass).
- **Not in scope:** redistributing the PDFs themselves.
- **Not in scope:** building any Shiny app or interactive visualization — this is a static documentation + R-script repo.

### Deferred to Separate Tasks

- `gh repo create` and first push: left for the user after review of the scaffold.
- Bilingual explainers: documented as a future extension in `CLAUDE.md` but not executed now.
- Continuous integration that re-runs `simulation.R` scripts on PR: noted for future work.

## Context & Research

### Relevant files in the working tree

- `2203.09001v14.pdf` — Ghanem, Sant'Anna & Wüthrich, *Selection and Parallel Trends* (DiD; methodological).
- `MS32417manuscript.pdf` — Blandhol, Bonney, Mogstad & Torgovitsky, *When is TSLS Actually LATE?* (IV/TSLS/LATE; methodological).
- `when-can-we-trust-regression-discontinuity-design-estimates-from-close-elections-evidence-from-experimental-benchmarks.pdf` — De Magalhães et al. (RDD; methodological).

Already set up during /ce-setup:

- `.compound-engineering/config.local.yaml` + `.example.yaml`.
- `.gitignore` with the CE-local-config entry.
- `git init` already run — repo root established.

### Patterns and conventions to establish

This is a greenfield repo — no existing patterns. The plan below establishes the conventions, which `CLAUDE.md` then codifies for future papers.

### External references consulted

- `rdrobust` (Calonico-Cattaneo-Titiunik) for RDD with bias correction and CER-optimal bandwidths.
- `fixest::feols` for DiD with two-way fixed effects.
- `AER::ivreg` and `estimatr::iv_robust` for TSLS.
- `did` (Callaway-Sant'Anna) for staggered DiD if needed in later papers.

No external research agent was dispatched — standard causal-inference R packages and the three papers' methods are well-known to the planner.

## Key Technical Decisions

- **English only, plain-language first.** Jargon is introduced in a per-paper Glossary section, not inline.
- **Folder numbering `NN-first-authors-short-topic/`** for stable ordering as papers are added.
- **Each methodological paper gets one `simulation.R`** that defines a DGP with a known treatment effect, runs the paper's estimator(s), prints truth-vs-estimate, and renders at least one diagnostic plot.
- **Four subagents, project-scoped** in `.claude/agents/`, not user-global. Keeps the tooling portable with the repo.
- **Top-level `shared/r-setup.R`** loads a pinned package list via `require()` and sets `set.seed(20260421)`. Avoids a full `renv` setup for now.
- **PDFs gitignored.** `.gitignore` contains `*.pdf` plus the CE-local entries already added.
- **Explainer template is fixed** (12 sections, see Unit 3). Enforced via `CLAUDE.md`. New papers start from this template.

## Open Questions

### Resolved during planning

- Language of explainers → English (user answered earlier).
- PDFs in repo? → No, gitignored (user answered earlier).
- GitHub repo creation timing? → Local git now, remote later (user answered earlier).
- First-pass scope? → Scaffold + all three explainers (user answered earlier).
- Tool chain installs? → All four CE tools (agent-browser, vhs, silicon, ffmpeg) installed during /ce-setup.

### Deferred to implementation

- Exact package-version pins in `shared/r-setup.R`: pick at install time based on what's available on the user's machine (`R --version`, `installed.packages()`).
- Whether `simulation.R` should save plots to `figures/` or only render interactively — decided per-paper once the plot count is known.
- Exact wording of each paper's TL;DR — written during the drafting step.
- Whether to create a shared `LICENSE` file (MIT for code, CC-BY for text) now vs. in a follow-up — defer to after initial commit.

## Output Structure

```
papers_explainer/
├── README.md                              # GitHub landing page (Unit 1)
├── CLAUDE.md                              # Project conventions (Unit 1)
├── .gitignore                             # *.pdf, R artifacts, CE-local config (Unit 1)
├── LICENSE-code                           # optional, deferred
├── LICENSE-text                           # optional, deferred
├── .claude/
│   └── agents/
│       ├── causal-inference-expert.md     # Unit 2
│       ├── causal-inference-professor.md  # Unit 2
│       ├── r-coding-expert.md             # Unit 2
│       └── git-github-expert.md           # Unit 2
├── .compound-engineering/                 # already set up
│   ├── config.local.yaml                  # gitignored
│   └── config.local.example.yaml
├── papers/
│   ├── 01-ghanem-santanna-wuthrich-selection-parallel-trends/
│   │   ├── README.md                      # Unit 3
│   │   ├── simulation.R                   # Unit 3
│   │   └── references.md                  # Unit 3
│   ├── 02-blandhol-bonney-mogstad-torgovitsky-tsls-late/
│   │   ├── README.md                      # Unit 4
│   │   ├── simulation.R                   # Unit 4
│   │   └── references.md                  # Unit 4
│   └── 03-demagalhaes-et-al-rdd-close-elections/
│       ├── README.md                      # Unit 5
│       ├── simulation.R                   # Unit 5
│       └── references.md                  # Unit 5
└── shared/
    └── r-setup.R                          # common package loader + seed (Unit 1)
```

## High-Level Technical Design

> *This illustrates the intended pipeline and is directional guidance for review, not implementation specification.*

Pipeline for adding any paper (current and future):

```
PDF dropped in repo
      │
      ▼
[causal-inference-expert]   ──►  draft README.md: technical core
  reads paper, extracts                (estimand, identification,
  estimand + assumptions                assumptions, results)
      │
      ▼
[causal-inference-professor] ──►  rewrites for non-expert reader
  adds glossary, analogies,             (TL;DR, Glossary, intuition)
  simplifies math in prose
      │
      ▼
[r-coding-expert]           ──►  writes simulation.R
  DGP with known effect                 runs Rscript to verify
      │
      ▼
[git-github-expert]         ──►  commits, updates landing README
  updates contents table                prepares gh repo create notes
```

Per-paper README anatomy (12 sections, enforced by CLAUDE.md):

```
1. Citation (full ref + link)
2. TL;DR (3–5 sentences)
3. Why this paper matters
4. The causal question
5. Glossary
6. Core idea (with analogy)
7. Method walkthrough (step-by-step, equations in words)
8. Assumptions and failure modes
9. Authors' findings
10. Practitioner takeaways
11. Runnable example (link to simulation.R)
12. Further reading (3–5 refs)
```

## Implementation Units

- [ ] **Unit 1: Repository scaffolding**

  **Goal:** Create the top-level files that define the repo (landing README, CLAUDE.md, .gitignore updates, shared R setup) and copy this plan into the repo's `docs/plans/` for discoverability.

  **Requirements:** R1, R2, R5, R6

  **Dependencies:** None. `git init` already ran during /ce-setup.

  **Files:**
  - Create: `README.md`
  - Create: `CLAUDE.md`
  - Create: `shared/r-setup.R`
  - Create: `docs/plans/2026-04-21-001-feat-causal-inference-papers-explainer-plan.md` (copy of this plan)
  - Modify: `.gitignore` (add `*.pdf`, `.Rhistory`, `.RData`, `.Rproj.user/`, `.DS_Store`)

  **Approach:**
  - `README.md` sections: one-paragraph description, audience, contents table (paper #, title, method, folder link, 1-line takeaway), how-to-read, how-to-run-R (R ≥ 4.3, packages list), how-to-add-a-paper, license note.
  - `CLAUDE.md` sections: project purpose, folder naming rule, explainer template (12 sections), R conventions (tidyverse, `set.seed(20260421)`, truth-vs-estimate, ≥1 plot), subagent routing table, PDF policy, publishing note with `gh repo create` command.
  - `shared/r-setup.R`: `required_pkgs <- c("tidyverse","fixest","did","rdrobust","rddensity","AER","ivreg","estimatr","ggplot2")`, loop over `require()`, `set.seed(20260421)`.

  **Patterns to follow:** None — establishes the conventions.

  **Test scenarios:**
  - Happy path: `Rscript -e 'source("shared/r-setup.R")'` loads without error on a machine with the listed packages; missing packages produce a clear warning naming the package.
  - Edge case: `.gitignore` correctly excludes the three PDFs in the repo root — verified by `git check-ignore 2203.09001v14.pdf` exiting 0.
  - Integration: `git status` after Unit 1 shows only the newly created files (no PDFs).

  **Verification:**
  - `tree -L 2` shows the top-level layout from §Output Structure.
  - `CLAUDE.md` includes a routing table naming all four subagents (even before they're written in Unit 2).
  - Landing `README.md` contents table has three rows, one per paper, with folder links that will resolve after Units 3–5.

---

- [ ] **Unit 2: Four project subagents**

  **Goal:** Write four subagent definitions into `.claude/agents/` with precise roles, tool scopes, and invocation guidance.

  **Requirements:** R4

  **Dependencies:** Unit 1 (CLAUDE.md references these agent names).

  **Files:**
  - Create: `.claude/agents/causal-inference-expert.md`
  - Create: `.claude/agents/causal-inference-professor.md`
  - Create: `.claude/agents/r-coding-expert.md`
  - Create: `.claude/agents/git-github-expert.md`

  **Approach:**
  - Each file uses Claude Code subagent frontmatter: `name`, `description`, `tools`, `model`.
  - **causal-inference-expert** — model `opus`, tools `Read, Grep, Glob, WebFetch`. Role: read PDF/arXiv, extract estimand, identification argument, assumptions, results; draft or critique the technical sections of a paper README. Must flag overstatements.
  - **causal-inference-professor** — model `sonnet`, tools `Read, Edit`. Role: pedagogy pass — rewrite TL;DR, build glossary, add analogies, keep math minimal in prose but honest.
  - **r-coding-expert** — model `sonnet`, tools `Read, Write, Edit, Bash`. Role: produce `simulation.R` following repo conventions, run `Rscript` to verify, report missing packages.
  - **git-github-expert** — model `sonnet`, tools `Read, Write, Edit, Bash`. Role: `.gitignore` hygiene, per-paper commits, update landing README contents table, document `gh repo create` steps.
  - Each description mentions the proactive triggers (e.g., "invoke after a paper folder is added").

  **Patterns to follow:** Claude Code subagent frontmatter spec.

  **Test scenarios:**
  - Happy path: each agent file contains the four required frontmatter fields and a body describing role, inputs, outputs, and when NOT to invoke.
  - Integration: `CLAUDE.md`'s routing table matches the four file names exactly.
  - Edge case: descriptions are written so Claude can auto-select each agent from a natural-language task request without ambiguity (e.g., R-code requests don't route to the professor agent).

  **Verification:**
  - `ls .claude/agents/` returns exactly four `.md` files.
  - Each agent's `description` is specific enough that a future prompt like "draft the RDD explainer for paper 03" routes to `causal-inference-expert` then `causal-inference-professor`, not arbitrarily.

---

- [ ] **Unit 3: Paper 01 — Ghanem, Sant'Anna & Wüthrich (DiD / Selection and Parallel Trends)**

  **Goal:** Write the plain-language explainer and a runnable DiD simulation that illustrates when parallel trends holds and when selection-on-gains breaks it.

  **Requirements:** R3, R7

  **Dependencies:** Unit 1 (template, shared/r-setup.R), Unit 2 (subagents available for iterative drafting).

  **Files:**
  - Create: `papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/README.md`
  - Create: `papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R`
  - Create: `papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/references.md`

  **Approach:**
  - README follows the 12-section template from CLAUDE.md. Glossary covers: treatment group, control group, parallel trends, selection-on-levels vs. selection-on-gains, two-way fixed effects, counterfactual trend.
  - `simulation.R` DGP:
    - Two groups × two periods, N=2000 per group.
    - True ATT = 1.5.
    - Scenario A (parallel trends holds): selection on time-invariant levels only.
    - Scenario B (violated): selection on expected gains (Roy-style) → time-varying unobservable.
    - Estimator: `fixest::feols(y ~ treat*post | id + period)`.
  - Output: print truth-vs-estimate for both scenarios; plot group-period means with counterfactual trend line.

  **Patterns to follow:** README template in CLAUDE.md; `shared/r-setup.R` for package loading.

  **Test scenarios:**
  - Happy path: `Rscript simulation.R` prints an ATT estimate within ±0.15 of 1.5 for Scenario A across 200 Monte Carlo draws.
  - Happy path: Scenario B shows systematic bias (estimate differs from 1.5 by > 0.3 in expectation) — demonstrating the failure mode the paper warns about.
  - Integration: the plot file (or screen render) labels both trajectories and the counterfactual clearly.
  - Edge case: script runs with `R --no-save` in a fresh session, no leftover state assumed.

  **Verification:**
  - README's TL;DR is understandable to a reader who has never heard of DiD — validated by re-reading after the professor-agent pass.
  - Glossary defines every acronym/term used elsewhere in the README.
  - `Rscript simulation.R` exits 0 and writes the expected printed output.

---

- [ ] **Unit 4: Paper 02 — Blandhol, Bonney, Mogstad & Torgovitsky (TSLS and LATE)**

  **Goal:** Explainer + simulation showing that adding covariates to TSLS without full saturation can give negative weights on some CATEs, breaking the LATE interpretation.

  **Requirements:** R3, R7

  **Dependencies:** Unit 1, Unit 2.

  **Files:**
  - Create: `papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/README.md`
  - Create: `papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.R`
  - Create: `papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/references.md`

  **Approach:**
  - README glossary covers: instrument, exclusion restriction, monotonicity, complier / never-taker / always-taker, LATE, saturated specification, first stage.
  - `simulation.R` DGP:
    - Binary instrument Z, binary treatment D, binary covariate X with heterogeneous compliance across X strata.
    - Heterogeneous effects: τ(X=0) = 0.5, τ(X=1) = 2.0.
    - Three estimators:
      1. Unsaturated TSLS `y ~ d + x | z + x` with `AER::ivreg`.
      2. Saturated TSLS (interactions of Z with X).
      3. True LATE computed directly from the complier population.
    - Show (1) does not recover a non-negative weighted average; (2) matches LATE under saturation; (3) is the benchmark.

  **Patterns to follow:** Same template and R conventions as Unit 3.

  **Test scenarios:**
  - Happy path: saturated TSLS estimate within ±0.1 of true LATE across 500 Monte Carlo draws.
  - Happy path: unsaturated TSLS estimate is demonstrably different from the true LATE (> 0.2 gap in expectation).
  - Edge case: script still runs when `AER` is missing — emits a clear "install AER" message and exits 1 (not a silent failure).
  - Integration: a decomposition table shows which subgroups receive negative implicit weights.

  **Verification:**
  - README walks through the core intuition ("why covariates break LATE") in ≤ 500 words without invoking matrix algebra in prose.
  - `Rscript simulation.R` prints a comparison table with the three estimators and the truth.

---

- [ ] **Unit 5: Paper 03 — De Magalhães et al. (RDD validation from close elections)**

  **Goal:** Explainer + simulation comparing MSE-optimal vs CER-optimal bandwidths at multiple polynomial degrees in a sharp RDD with known non-linear curvature.

  **Requirements:** R3, R7

  **Dependencies:** Unit 1, Unit 2.

  **Files:**
  - Create: `papers/03-demagalhaes-et-al-rdd-close-elections/README.md`
  - Create: `papers/03-demagalhaes-et-al-rdd-close-elections/simulation.R`
  - Create: `papers/03-demagalhaes-et-al-rdd-close-elections/references.md`

  **Approach:**
  - README glossary covers: running variable, cutoff, sharp vs. fuzzy RDD, local polynomial, bandwidth, MSE-optimal, CER-optimal, bias-corrected robust inference, coverage.
  - `simulation.R` DGP:
    - Running variable X ~ Uniform(-1, 1), cutoff at 0.
    - E[Y|X] has meaningful non-linear curvature near cutoff (e.g., cubic on each side).
    - True treatment effect at threshold τ = 0.5.
  - Estimators compared (via `rdrobust::rdrobust`):
    - Polynomial order p ∈ {1, 2}.
    - Bandwidth selector: `bwselect = "mserd"` vs `"cerrd"`.
    - Inference: conventional vs bias-corrected robust.
  - Monte Carlo (≥ 500 draws) reports coverage of the true effect and RMSE for each spec.

  **Patterns to follow:** Same as Units 3–4.

  **Test scenarios:**
  - Happy path: under non-linear curvature, CER-optimal bandwidth + bias-corrected robust inference achieves coverage ≥ 90%; conventional inference with MSE-optimal bandwidth shows under-coverage.
  - Happy path: `rdrobust` outputs render via `rdplot()` into the explainer's illustrative plot.
  - Edge case: simulation scales — user can re-run with fewer draws (N_sim) via a top-of-script constant for quick iteration.
  - Integration: coverage table matches the paper's qualitative claim (CER > MSE under curvature).

  **Verification:**
  - README's practitioner takeaway section explicitly says "use CER-optimal bandwidth with bias-corrected robust SEs when you suspect curvature near the cutoff".
  - `Rscript simulation.R` produces a coverage/RMSE table across all specifications.

---

- [ ] **Unit 6: Integration, landing-page wiring, and git history**

  **Goal:** Wire the finished paper folders into the landing README contents table, run one end-to-end sanity check, and create clean initial commits.

  **Requirements:** R1, R6

  **Dependencies:** Units 1–5.

  **Files:**
  - Modify: `README.md` (contents table now lists real folders with real 1-line takeaways)
  - Modify: `CLAUDE.md` (add the "Publishing" section with the exact `gh repo create` command)

  **Approach:**
  - Update landing README so every row's folder link resolves.
  - Run `Rscript papers/0*/simulation.R` in sequence; capture any missing-package errors and note them in `CLAUDE.md` troubleshooting.
  - Create git commits with clear history: one for scaffold (Unit 1), one for agents (Unit 2), one per paper (Units 3–5), one for the landing-page wiring (Unit 6).
  - Leave the repo in a state where the user can run `gh repo create papers-explainer --public --source=. --push` when they're ready.

  **Patterns to follow:** Conventional-commit-style messages (`feat:`, `docs:`).

  **Test scenarios:**
  - Integration: `git log --oneline` shows 6 commits in logical order.
  - Integration: `git status` is clean.
  - Edge case: `git check-ignore 2203.09001v14.pdf MS32417manuscript.pdf when-can-we-trust-*.pdf` confirms all three PDFs are ignored.
  - Happy path: each of the three `simulation.R` files runs to completion end-to-end.

  **Verification:**
  - Landing README rendered on GitHub would be fully navigable (all folder links resolve).
  - `CLAUDE.md` publishing section contains a runnable `gh repo create ...` command the user can copy.

## System-Wide Impact

- **Interaction graph:** The four subagents form a pipeline; CLAUDE.md is the single source of truth for routing them. Adding a new paper should exercise the full pipeline, not just the R agent.
- **Error propagation:** Simulations that fail due to missing R packages must print a clear install hint, not a cryptic traceback.
- **State lifecycle risks:** `set.seed(20260421)` in `shared/r-setup.R` means every simulation is reproducible; per-script seeds should only override, not clobber, this default.
- **API surface parity:** The per-paper README template is the contract. If one paper diverges from it, CLAUDE.md and all subsequent papers drift — professor-agent reviews enforce this.
- **Unchanged invariants:** The three PDFs themselves are never modified or committed. `inputs/`-style workflows from other CEPE-style projects are not imported.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| User's R lacks one of the required packages (e.g., `rdrobust`) | `shared/r-setup.R` emits a clear warning per missing package; CLAUDE.md lists the `install.packages(...)` line. |
| Subagent descriptions aren't specific enough and future tasks route to the wrong agent | Descriptions include proactive triggers and explicit "do NOT invoke for X" clauses; routing is tested with a smoke invocation per agent. |
| Drift in per-paper README template (sections missing or reordered) | CLAUDE.md freezes the 12-section template; professor-agent review verifies structure before commit. |
| User accidentally commits a PDF | `.gitignore` includes `*.pdf` at the repo root; Unit 6's verification includes `git check-ignore`. |
| Simulations are too slow to re-run routinely (500 MC draws × 3 papers) | Each `simulation.R` exposes `N_SIM` at the top of the file so users can throttle for iteration. |

## Documentation / Operational Notes

- `CLAUDE.md` will include a dedicated "Adding a new paper" section with the agent pipeline and a checklist.
- `CLAUDE.md` publishing section: `gh repo create papers-explainer --public --source=. --remote=origin --push` (user-editable for private or alternative names).
- Troubleshooting R package issues goes in `CLAUDE.md` under a "Running the simulations" subsection, not in the landing README.

## Sources & References

- User prompt: initial request captured in the working conversation on 2026-04-21.
- Prior planning decisions captured via `AskUserQuestion` earlier in this session (language = English, PDFs gitignored, local git now, full three-paper first pass).
- /ce-setup output confirming plugin v2.66.1 and tool installs.
- The three PDFs (read-only inputs) — not committed.
