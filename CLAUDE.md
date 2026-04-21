# CLAUDE.md — Project Conventions

This file tells Claude (and future contributors) how this repository is organized, what its content standards are, and how to add new papers consistently. It is the single source of truth for the per-paper template and the subagent pipeline.

## Project purpose

Build plain-language explainers of methodological causal-inference papers, paired with runnable R code on simulated data. Target reader: a motivated learner with no prior econometrics background who nonetheless wants methodological detail.

## Folder layout

```
.
├── README.md                # GitHub landing page (contents table)
├── CLAUDE.md                # This file
├── .gitignore
├── .claude/agents/          # Project subagents (see "Subagent routing")
├── shared/r-setup.R         # Common package loader + seed
├── papers/
│   └── NN-<first-authors>-<short-topic>/
│       ├── README.md        # The explainer (12-section template below)
│       ├── simulation.R     # Runnable simulation (methodological papers only)
│       └── references.md    # Citation + adjacent reading
├── docs/
│   └── plans/               # Implementation plans (ce:plan output)
```

Folder numbering: `NN-` is a zero-padded two-digit sequence (`01-`, `02-`, ...) reflecting the order in which papers were added to the repo. This is *not* a ranking.

## Language and tone

- **English** for all explainers and code comments.
- **Plain language first.** Introduce jargon via the Glossary section — never inline.
- **Analogies over algebra** in prose. Equations are allowed as a reference in the "Method walkthrough" section, but the core idea must land without them.
- **Be honest about assumptions.** Every method has failure modes. Name them.

## Per-paper `README.md` — 12-section template

Every `papers/NN-*/README.md` MUST follow this structure, in this order. Subagents enforce it.

1. **Citation** — full reference with a working link (arXiv, DOI, or publisher).
2. **TL;DR** — 3–5 sentences any motivated reader can follow.
3. **Why this paper matters** — which real empirical practice it changes.
4. **The causal question** — in plain English.
5. **Glossary** — every acronym and technical term used later in the doc.
6. **Core idea** — with at least one concrete analogy.
7. **Method walkthrough** — step-by-step. Equations in words; at most one reference formula per subsection.
8. **Assumptions and when they fail** — bulleted, blunt about failure modes.
9. **What the authors find** — their main results.
10. **What this means for a practitioner** — what a user of the method should actually do differently after reading.
11. **Runnable example** — short description of the DGP in `simulation.R` and what its output shows.
12. **Further reading** — 3–5 adjacent papers or textbook chapters.

## R conventions

- Every `simulation.R` starts with `source("../../shared/r-setup.R")` (relative path from the paper folder).
- `shared/r-setup.R` sets `set.seed(20260421)`. Per-script overrides are fine but should be explicit.
- Use **tidyverse** (dplyr, ggplot2, purrr) for data manipulation and plotting. `data.table` is fine if a specific script benefits from it — document why at the top.
- Expose an `N_SIM` constant near the top of each script so readers can throttle Monte Carlo draws for quick iteration.
- Always print a **truth vs. estimate** comparison.
- Always render **at least one diagnostic plot** (`ggplot2` preferred). Plots may be displayed interactively or saved to `figures/`; either is fine, but `figures/` images are gitignored.
- When a package is missing, emit a clear install hint — do not fail with a raw traceback. `shared/r-setup.R` already handles this for the standard package list.
- No secrets, no API keys, no hard-coded absolute paths. Everything must run on a clean machine after `install.packages(...)`.

## Subagent routing

Four project-scoped subagents live in `.claude/agents/`. Invoke them in this order when adding or revising a paper:

| Step | Agent | Why |
|------|-------|-----|
| 1 | `causal-inference-expert` | Technical accuracy. Reads the PDF or source, extracts the estimand, identification argument, assumptions, and results. Drafts or critiques the technical sections of the README (5, 7, 8, 9). |
| 2 | `causal-inference-professor` | Pedagogy. Rewrites the TL;DR, builds the Glossary, adds analogies, and keeps math minimal in prose while preserving correctness. Owns sections 2, 4, 5, 6, 10. |
| 3 | `r-coding-expert` | Simulation. Produces `simulation.R` following the R conventions above, runs it with `Rscript` to confirm it executes end-to-end, and reports missing packages with an install hint. |
| 4 | `git-github-expert` | Repository hygiene. Updates the contents table in the top-level README, stages only files for the paper being added, writes a conventional commit, and prepares `gh repo create` / `gh pr create` instructions when the user is ready to push. |

Rule of thumb: the expert drafts, the professor rewrites, the R coder verifies, the git expert ships.

## Do not

- **Do not commit PDFs.** They're gitignored for copyright safety. Always link to the official or arXiv version in `references.md` instead.
- **Do not paste verbatim paper text** into explainers. Paraphrase.
- **Do not skip the Glossary** — even for "obvious" terms like *cutoff* or *instrument*.
- **Do not claim a method is "the" answer.** Every method has failure modes; name them in section 8.
- **Do not let simulation scripts print nothing.** Readers should be able to run `Rscript simulation.R` and *see* the punchline.

## Adding a new paper — checklist

- [ ] PDF dropped in repo root (will be gitignored).
- [ ] Folder `papers/NN-<first-authors>-<short-topic>/` created.
- [ ] `references.md` with full citation + link.
- [ ] Subagent pipeline run end-to-end (expert → professor → R coder → git).
- [ ] `Rscript papers/NN-*/simulation.R` runs to completion (for methodological papers).
- [ ] Top-level `README.md` contents table updated with a real 1-line takeaway.
- [ ] Conventional commit on its own (e.g., `feat(papers): add paper NN on <topic>`).

## Running the simulations

From the repo root:

```bash
Rscript papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R
Rscript papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.R
Rscript papers/03-demagalhaes-et-al-rdd-close-elections/simulation.R
```

Troubleshooting:

- *"there is no package called X"* — run the `install.packages(...)` line that `shared/r-setup.R` printed.
- *Simulation feels slow* — each script exposes an `N_SIM` constant; set it to a small number (e.g., 50) for quick iteration.
- *Different numbers than expected* — verify you haven't changed `set.seed(...)` upstream.

## Publishing

This repo is initialized locally with `git init`. When you're ready to push to GitHub:

```bash
# Public repo, push current branch, set remote
gh repo create papers-explainer --public --source=. --remote=origin --push

# Or private
gh repo create papers-explainer --private --source=. --remote=origin --push
```

Afterwards, subsequent work flows through regular pull requests. The `git-github-expert` agent will help compose PR descriptions that follow the repo's conventional-commit style.

## Future extensions (not in scope yet)

- Spanish translations of explainers (dual-language folders).
- CI that re-runs `simulation.R` files on PR to catch broken scripts.
- Notebook companions (`.Rmd` / Quarto) rendered to HTML for blog-style reading.
