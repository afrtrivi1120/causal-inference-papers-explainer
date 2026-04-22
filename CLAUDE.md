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
├── papers/
│   └── <method>/            # Methodology bucket: did, iv, rdd, rct, synthetic-control, causal-ai, ...
│       └── NN-<first-authors>-<short-topic>/
│           ├── README.md        # The explainer (12-section template below)
│           ├── simulation.ipynb # Runnable Jupyter notebook (methodological papers only; Colab badge at top)
│           └── references.md    # Citation + adjacent reading
├── docs/
│   ├── plans/               # Implementation plans (ce:plan output)
│   └── solutions/           # Documented solutions to past problems (runtime errors,
│                            # best practices, workflow patterns), organized by
│                            # category with YAML frontmatter (module, tags,
│                            # problem_type). Relevant when implementing or
│                            # debugging in documented areas.
```

Folder numbering: `NN-` is a zero-padded two-digit sequence (`01-`, `02-`, ...) reflecting the order in which papers were added to the repo. Numbering is **global**, not per-bucket — so `papers/iv/02-...` and `papers/rdd/03-...` coexist and the numbers inside any one bucket are typically non-contiguous. This is *not* a ranking.

Methodology buckets (`<method>/`) use kebab-case lowercase names — `did`, `iv`, `rdd`, `rct`, `synthetic-control`, `causal-ai`, and so on. New buckets are created lazily when the first paper in that category lands; empty buckets are not kept in the tree.

## Language and tone

- **English** for all explainers and code comments.
- **Plain language first.** Introduce jargon via the Glossary section — never inline.
- **Analogies over algebra** in prose. Equations are allowed as a reference in the "Method walkthrough" section, but the core idea must land without them.
- **Be honest about assumptions.** Every method has failure modes. Name them.

## Per-paper `README.md` — 12-section template

Every `papers/<method>/NN-*/README.md` MUST follow this structure, in this order. Subagents enforce it.

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
11. **Runnable example** — short description of the DGP in `simulation.ipynb` and what its output shows. Mention the Colab badge so readers know they can run the simulation in-browser.
12. **Further reading** — 3–5 adjacent papers or textbook chapters.

## Notebook conventions

- Every `simulation.ipynb` uses the **R (IRkernel) kernel** (kernelspec `ir`) and opens with a **markdown title cell** that includes a one-line paper citation, an "Open in Colab" badge linking to the notebook's raw GitHub URL (branch `master`), a one-paragraph "what this simulation shows" hook, and a one-paragraph DGP summary. Readers on Colab pick *Runtime → Change runtime type → R* once per session.
- The **setup code cell** runs in this order: (1) defensive `if (!requireNamespace('X', quietly = TRUE)) install.packages('X', quiet = TRUE)` for any dep not in Colab's default R runtime (typically `AER`, `rdrobust`; `tidyverse` is pre-installed); (2) `suppressPackageStartupMessages({ library(...) })`; (3) `set.seed(20260421)`; (4) a version print block so readers can diagnose library-version drift.
- Use **tidyverse** (dplyr, ggplot2, purrr) for data manipulation and plotting. `data.table` is fine if a specific notebook benefits from it — document why at the top.
- Expose an `N_SIM` constant near the top of each notebook so readers can throttle Monte Carlo draws for quick iteration.
- Always print a **truth vs. estimate** comparison (as a `tibble` or similar structured object — Jupyter renders tibbles inline).
- Always render **at least one diagnostic plot** via `ggplot2`. Set inline plot size with `options(repr.plot.width = ..., repr.plot.height = ...)` before the plot call. Plots render inline; do **not** save to disk — the point is inline rendering in GitHub's `.ipynb` viewer.
- Re-anchor the RNG with `set.seed(20260421)` before any "representative" plot draw, because the Monte Carlo loop consumes an `N_SIM`-dependent amount of RNG state.
- **Label-safe lookups.** When an estimator returns a structured object with labeled rows (e.g. `rdrobust` returns "Conventional"/"Bias-Corrected"/"Robust" rows), index by row **name** via `rownames()` lookup with a `stopifnot()` that the expected labels exist. Never positional indexing — a future package release could reorder rows and silently return the wrong number.
- **Commit notebooks with rendered outputs.** Use `jupyter nbconvert --to notebook --execute --inplace <path>` to produce the final version; GitHub's `.ipynb` viewer shows the full reader experience without requiring execution.
- No secrets, no API keys, no hard-coded absolute paths. Everything must run on a fresh Colab R runtime after the in-notebook `install.packages(...)`, or locally with R ≥ 4.3 and `tidyverse` + `AER` + `rdrobust` installed.

## Subagent routing

Four project-scoped subagents live in `.claude/agents/`. Invoke them in this order when adding or revising a paper:

| Step | Agent | Owns | Why |
|------|-------|------|-----|
| 1 | `causal-inference-expert` | Resolve the `<method>` bucket and create `papers/<method>/` if it's the first paper in that category. Scaffold `papers/<method>/NN-*/README.md` + `references.md`. Sections 1 (Citation), 5 (Glossary), 7 (Method), 8 (Assumptions), 9 (Findings). | Technical accuracy + bucket routing. Reads the PDF or source, extracts the estimand, picks the bucket slug from the estimator, extracts identification argument, assumptions, and results. Writes to disk directly (has `Write` + `Edit`). |
| 2 | `causal-inference-professor` | Sections 2 (TL;DR), 4 (Causal question), 5 (Glossary rewrite), 6 (Core idea), 10 (Practitioner takeaway). | Pedagogy. Edits the README in place via `Edit`; keeps math minimal in prose while preserving correctness. Does NOT add new Glossary terms the expert has not defined. |
| 3 | `simulation-notebook-expert` | `simulation.ipynb` + section 11 (Runnable example) in `README.md`. | Simulation. Produces `simulation.ipynb` (R kernel) following the Notebook conventions above, runs it with `jupyter nbconvert --execute --inplace` to produce the final version with rendered outputs, writes section 11 into the README, and adds an `install.packages(...)` line in the notebook setup cell plus a bullet in the top-level `README.md` if it needs a new package. |
| 4 | `git-github-expert` | Contents table in top-level `README.md`. `.gitignore`. Commit history. | Repository hygiene. Stages only files for the paper being added, writes a conventional commit, and prepares `gh repo create` / `gh pr create` instructions when the user is ready to push. |

Pipeline order is strict: expert → professor → simulation-notebook-expert → git. The notebook-expert depends on the professor's section-6 narrative for the section-11 framing; the git agent will refuse to commit a folder with `TODO:` placeholders in any 12-section slot.

Rule of thumb: the expert drafts, the professor rewrites, the notebook-expert verifies, the git expert ships.

## Do not

- **Do not commit PDFs.** They're gitignored for copyright safety. Always link to the official or arXiv version in `references.md` instead.
- **Do not paste verbatim paper text** into explainers. Paraphrase.
- **Do not skip the Glossary** — even for "obvious" terms like *cutoff* or *instrument*.
- **Do not claim a method is "the" answer.** Every method has failure modes; name them in section 8.
- **Do not let simulation notebooks print nothing.** Readers should be able to open `simulation.ipynb` on GitHub and *see* the punchline — truth-vs-estimate DataFrame, at least one plot, and a closing markdown cell summarizing the result.

## Adding a new paper — checklist

- [ ] PDF dropped in repo root (will be gitignored).
- [ ] Folder `papers/<method>/NN-<first-authors>-<short-topic>/` created. The `causal-inference-expert` agent owns bucket resolution (picking `<method>` from the estimator) and creates `papers/<method>/` if it's the first paper in that category — you do not need to pick the slug yourself before invoking the pipeline.
- [ ] `references.md` with full citation + link.
- [ ] Subagent pipeline run end-to-end (expert → professor → simulation-notebook-expert → git).
- [ ] `jupyter nbconvert --to notebook --execute --inplace papers/<method>/NN-*/simulation.ipynb` exits 0, with rendered outputs in the committed file (for methodological papers).
- [ ] Top-level `README.md` contents table updated with a real 1-line takeaway.
- [ ] Conventional commit on its own (e.g., `feat(papers): add paper NN on <topic>`).

## Running the simulations

Two paths for the reader:

**Colab (primary — no local install).** Open any of the three paper notebooks on github.com:

- [`papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.ipynb`](papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.ipynb)
- [`papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.ipynb`](papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.ipynb)
- [`papers/rdd/03-demagalhaes-et-al-rdd-close-elections/simulation.ipynb`](papers/rdd/03-demagalhaes-et-al-rdd-close-elections/simulation.ipynb)

Each notebook has an "Open in Colab" badge at the top. Click it, pick *Runtime → Change runtime type → R* once per session, then *Runtime → Run all*. The first cell runs `install.packages(...)` for any dep not pre-installed on Colab's R runtime (typically `AER` for paper 02 and `rdrobust` for paper 03 — `tidyverse` is already there).

**Local Jupyter (escape hatch).** With R ≥ 4.3 and IRkernel registered (`R -e 'IRkernel::installspec(user = TRUE)'` once), plus `tidyverse` + `AER` + `rdrobust` installed:

```bash
jupyter lab papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.ipynb
```

Or headless re-execution (useful for CI / sanity checks):

```bash
jupyter nbconvert --to notebook --execute --inplace \
  papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.ipynb
```

Troubleshooting:

- *`there is no package called 'X'`* — run `install.packages('X')` in R, or re-run the notebook's first cell so its defensive `install.packages(...)` call fires.
- *Simulation feels slow* — each notebook exposes an `N_SIM` constant near the top; drop it to 50 for quick iteration.
- *Different numbers than expected* — verify `set.seed(20260421)` hasn't been changed, and check the version-print cell at the top for library-version drift.

## Committing, pushing, and publishing

Claude **should commit at each milestone, not at session end**, and **push after each commit once the remote exists**. This authorization is durable and lives here so Claude does not need to re-confirm it each session.

### What counts as a milestone

One commit per logical change, landed as soon as the change is coherent and verified:

| Trigger | Example commit message |
|---|---|
| Repo scaffold lands (a new convention in `CLAUDE.md`, a new `shared/` helper, a `.gitignore` update) | `feat(repo): ...`  ·  `chore(repo): ...` |
| A subagent definition is added or meaningfully reshaped | `feat(agents): ...`  ·  `fix(agents): ...` |
| A paper folder is complete (`README.md` + `simulation.ipynb` + `references.md`, all sections filled, notebook executes clean with rendered outputs) | `feat(papers/<method>/NN): add paper NN — <short topic>` |
| A review-fix batch lands (one batch per ce:review run, not one per finding) | `fix: apply ce:review batch N (...)` |
| A new learning is captured via ce:compound | `docs(solutions): ...` |
| A plan is added or its checkboxes are flipped | `chore(repo): mark plan units complete`  ·  `docs(plans): ...` |
| Landing `README.md` contents table gains a row | `docs(readme): add paper NN to contents` |

Stage only the files that belong in the commit — never `git add .`, never `git add -A`, never `git commit -am`. Scope the commit message. One logical change per commit.

### Pre-commit checklist

Before running `git commit`, Claude verifies:

- The relevant `simulation.ipynb` files execute 0 under `jupyter nbconvert --to notebook --execute --inplace` (for changes that touch simulations), and the re-rendered outputs are staged alongside source edits.
- No `TODO:` placeholder survives in any 12-section slot of a paper README.
- `git check-ignore *.pdf` confirms PDFs remain untracked.
- Hooks are not bypassed: `--no-verify`, `-c commit.gpgsign=false`, and similar are off-limits. If a hook fails, fix the underlying issue and make a new commit.

### Pushing

- Check `git remote -v`. If `origin` exists, `git push` after every milestone commit without asking. If no remote exists yet, skip the push silently — the commit is enough until `gh repo create` has been run.
- Never `git push --force` or `git push --force-with-lease` without explicit user confirmation.
- Never push commits whose subject starts with `WIP` or contains unresolved merge conflict markers.

### First-time publish to GitHub

When the repo is ready to go public (or private) for the first time:

```bash
# Public
gh repo create papers-explainer --public --source=. --remote=origin --push

# Or private
gh repo create papers-explainer --private --source=. --remote=origin --push
```

After that, subsequent work uses plain `git push origin <branch>`. For shared branches or feature branches destined for a pull request, the `git-github-expert` agent will help compose PR bodies that follow the repo's conventional-commit style — but the one-commit-per-milestone + push-on-remote-exists cadence above applies regardless of whether a PR is opened.

## Future extensions (not in scope yet)

- Spanish translations of explainers (dual-language folders).
- CI that re-runs `simulation.ipynb` notebooks on PR (via `jupyter nbconvert --execute`) to catch broken notebooks.
- Notebook companions (`.Rmd` / Quarto) rendered to HTML for blog-style reading.
