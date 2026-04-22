# Selection and Parallel Trends

*Paper 01 — Difference-in-Differences*

## 1. Citation

Ghanem, D., Sant'Anna, P. H. C., & Wüthrich, K. (2024). *Selection and Parallel Trends*. arXiv:2203.09001.

- Paper: <https://arxiv.org/abs/2203.09001>
- See [`references.md`](references.md) for adjacent reading.

## 2. TL;DR

Difference-in-differences (DiD) relies on the **parallel trends** assumption: absent treatment, treated and control groups would have moved in parallel. This paper shows that parallel trends is not a loose statement about trends — it is a **specific restriction on how people decide (or get decided) to be treated**. The authors derive necessary and sufficient conditions for parallel trends under broad classes of selection mechanisms, and show that the most intuitive kind of selection — units that expect to benefit most opt in — *usually* breaks parallel trends, unless you also assume that untreated outcomes are time-stationary in a precise sense.

The practical consequence: if you do DiD and haven't thought about *why* your treated units are treated, you're probably using an assumption you haven't actually defended.

## 3. Why this paper matters

DiD is everywhere — every week a new paper, new policy evaluation, new causal claim is built on top of a two-way-fixed-effects regression and a sentence of the form *"we assume parallel trends"*. The field's working checklist for defending that assumption has been dominated by **event-study plots** and pretrend tests. Those check whether trends *looked* parallel in the past; they do not check whether the *mechanism that put units into treatment* implies parallel trends going forward.

Ghanem, Sant'Anna & Wüthrich reframe the conversation: rather than testing trends, **name the selection mechanism** (why is unit *i* treated?) and ask what that mechanism implies about potential outcomes. When the paper's classification is applied to a real DiD, the required auxiliary assumptions become visible — and sometimes uncomfortable.

## 4. The causal question

You have two groups (treated and control) observed over two (or more) time periods. You want the **average treatment effect on the treated (ATT)**: how much better off were treated units because of the treatment, compared to the world where they hadn't been treated?

The observable comparison — "change for treated minus change for control" — is only a valid estimate of the ATT if the counterfactual trend for the treated group (what would have happened absent treatment) equals the realized trend for the control group. That equality is parallel trends.

This paper asks: **what has to be true about the selection rule (the reason units ended up in the treated group) for parallel trends to hold?**

## 5. Glossary

- **ATT (average treatment effect on the treated)** — the average change in outcomes caused by treatment, among units that actually received treatment. Not the same as the population ATE.
- **Parallel trends (PT)** — the assumption that, absent treatment, the *average* outcome for the treated group would have moved over time in parallel to the control group. Formally: `E[Y(0, post) − Y(0, pre) | D=1] = E[Y(0, post) − Y(0, pre) | D=0]`.
- **Potential outcomes `Y(0), Y(1)`** — the outcome unit *i* would have under control (`Y(0)`) or treatment (`Y(1)`). Only one is observed per unit per period; the other is counterfactual.
- **Selection mechanism** — the rule (stochastic or deterministic) that determines which units end up treated. Key classes:
  - *Selection on levels* — treatment depends on time-invariant characteristics.
  - *Selection on gains (Roy-style)* — treatment depends on the individual expected gain `Y(1) − Y(0)`.
  - *Random assignment* — treatment is independent of both potential outcomes.
- **Two-way fixed effects (TWFE)** — regression spec `y ~ treat:post + fixed effects for unit and period`. In a 2-group / 2-period design it equals the 2×2 DiD.
- **Stationarity** — property of a time series whose distribution does not change over time. In this paper, stationarity of `Y(0)` restricts how the untreated outcome's distribution evolves and is a natural partner to parallel-trends assumptions.
- **Time-homogeneous selection** — the rule used to pick treated units does not change over time.

## 6. Core idea

Here is the analogy. Two schools, Alpha and Beta, are otherwise identical. A job-training program opens at Alpha. A year later Alpha's graduates earn more than Beta's.

Did the program cause it? Maybe. But consider *why* students enrolled at Alpha:

1. **Level-based selection.** Alpha is closer to downtown, so commuter students enroll there. Being close to downtown doesn't interact with the passage of time — both Alpha and Beta students would have seen the same earnings growth absent the program. **Parallel trends holds.**
2. **Gain-based (Roy) selection.** Students who foresee the highest earnings bump from training opt into Alpha's program. These are exactly the students on steeper counterfactual earnings trajectories. **Parallel trends fails**, because treated students would have grown faster than controls even without the program.

Ghanem et al.'s insight: the parallel-trends *test* we usually run (did the pre-period look parallel?) is entirely silent on the difference between these two worlds. You need to say out loud what rule put Alpha's students in the treated group.

## 7. Method walkthrough

The paper proceeds in four steps.

**Step 1 — Factorize the DiD identifying condition.**
Let `D ∈ {0,1}` indicate treatment and `t ∈ {pre, post}` the period. The ATT is identified by the 2×2 DiD if and only if
```
E[Y(0, post) − Y(0, pre) | D = 1] = E[Y(0, post) − Y(0, pre) | D = 0].
```
This is the standard PT condition. The authors write it as a function of two objects: the **selection distribution** `P(D | Y(0, pre), Y(0, post), …)` and the **time-series properties** of `Y(0)`.

**Step 2 — Define classes of selection mechanisms.**
Covering three canonical cases:
- selection on *time-invariant unobservables* (levels);
- selection on *time-varying* potential-outcome components, including Roy-style gains;
- selection that is independent of `Y(0)`.

**Step 3 — Derive necessary and sufficient conditions.**
For each class, the paper characterizes when PT holds. Headline results:

- If selection depends only on time-invariant characteristics, PT holds **whenever the control group's untreated trend is the treated group's untreated trend** — which it is, because those characteristics don't interact with the passage of time.
- If selection depends on time-varying shocks (e.g., someone opts in today because they had a bad year and expect to bounce back), PT requires **additional restrictions on the time-series behavior of `Y(0)`**, typically some form of stationarity or mean-reversion condition.
- Roy-style selection on expected gains typically *breaks* PT, because the same unobserved factors that drive gains also drive untreated-outcome trends.

**Step 4 — Map selection mechanisms to testable implications.**
The paper shows what kinds of pre-trends tests, placebo checks, and auxiliary restrictions identify (or fail to identify) PT under each selection class. Importantly: some selection mechanisms that are compatible with PT *also* imply specific patterns in pre-periods that can be *tested*; others don't.

## 8. Assumptions and when they fail

The strongest through-line: **PT is never free**. You are always making *some* joint assumption about how units are selected and how untreated outcomes evolve. The paper makes that joint assumption explicit.

Failure modes:

- **Roy selection on gains.** Units who expect the biggest bump from treatment opt in. If those units have anything in common with their untreated trend (the typical case in labor, education, health), PT fails. This is the main violation the simulation below demonstrates.
- **Time-varying selection.** The rule for who gets treated today differs from the rule that operated in the pre-period. Pre-trends tests are uninformative here — the thing that would break PT hasn't activated yet.
- **Mean-reverting untreated outcomes.** If `Y(0)` mean-reverts and selection depends on a bad pre-period shock, treated units are on a steeper counterfactual trajectory than controls (Ashenfelter's dip).
- **Time-varying confounders.** Even under otherwise innocuous selection, if something *other* than the treatment changes for the treated group in the post-period, PT fails.

## 9. What the authors find

- PT has a clean characterization as a joint assumption on selection and `Y(0)` dynamics. Neither half is testable alone.
- Standard pre-trend checks are informative only under a subset of selection mechanisms and can be falsely reassuring under Roy-style selection.
- Several familiar defenses of DiD (conditioning on pre-period outcomes, matching, synthetic control) are best understood as ways of neutralizing a *specific* selection mechanism — and they fail silently if the mechanism is different.
- In two empirical case studies (a job-training program and a Medicaid expansion), the authors show that the choice among reasonable selection mechanisms materially changes the estimated effect — sometimes flipping its sign.

## 10. What this means for a practitioner

Three practical moves you should make on your next DiD project:

1. **Write one paragraph naming the selection mechanism.** Why are treated units treated? Self-selection? Policy eligibility? Quasi-random administrative assignment? This paragraph is an assumption, not a result — but putting it on paper forces discipline.
2. **Pick auxiliary assumptions that fit the mechanism.** If selection plausibly depends on expected gains (Roy), pre-trends tests alone will not rescue you — consider a design (IV, synthetic control, dynamic DiD with mean-reversion controls) that targets that specific violation.
3. **Stop treating pre-period tests as conclusive.** A flat pre-period under Roy selection is easy to generate and still consistent with a violated PT. The authors make this point formally; the simulation below makes it visceral.

## 11. Runnable example

[`simulation.ipynb`](simulation.ipynb) builds a 2-period × 2-group DGP where the true ATT is a well-defined average gain. The notebook has an "Open in Colab" badge at the top — one click runs it in a free cloud kernel, no install required. It runs two scenarios:

- **Scenario A** — `rho = 0`. Selection is still Roy-style (units opt in on expected gains), but the gain-driving factor `v` is *independent* of the untreated trend, so the DiD is unbiased.
- **Scenario B** — `rho = 1`. Same selection rule, but now the gain-driving factor *also* drives the untreated trend. DiD is biased upward by roughly 2 units across 300 Monte-Carlo draws.

The bias decomposes cleanly: `bias = rho · (E[v | D=1] − E[v | D=0])`. Both `rho > 0` *and* selection correlated with `v` are required — remove either ingredient and the DiD is unbiased. That joint dependence is exactly Ghanem, Sant'Anna & Wüthrich's point: parallel trends is neither "a property of the trends" nor "a property of the selection rule", but a property of their interaction.

A second note about the numbers: with `TAU = 1.5` and `v ~ N(0, 1)` the treatment share is roughly 93% — an intentionally imbalanced split that amplifies the Scenario B bias. Setting `TAU = 0` in the notebook gives a 50/50 split and shrinks the bias accordingly without changing the qualitative story.

The notebook prints a summary DataFrame and renders an inline matplotlib figure showing treated/control group means plus the treated group's counterfactual `Y(0)` trend, so you can see exactly where the "trend gap" emerges in Scenario B.

Run it — two options:

```bash
# Preferred: click the Colab badge at the top of simulation.ipynb. No install needed.

# Or locally, from the repo root:
pip install -r requirements.txt
jupyter nbconvert --to notebook --execute --inplace \
  papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.ipynb
```

Representative output (seed `20260421`, numpy RNG):

```
Scenario A: mean_DiD_estimate ≈ 1.65   mean_bias ≈ -0.002
Scenario B: mean_DiD_estimate ≈ 3.61   mean_bias ≈  1.96
```

Numerical values differ slightly from the retired R version's output (preserved at the [`v0-r-era`](../../../) tag) because numpy's MT19937 and R's Mersenne Twister diverge bit-for-bit at the same seed. The qualitative pattern — A unbiased, B biased by ~2 — reproduces faithfully.

## 12. Further reading

1. Roth, Sant'Anna, Bilinski & Poe (2023) — survey of recent DiD econometrics.
2. Callaway & Sant'Anna (2021) — DiD with multiple time periods and heterogeneous effects.
3. de Chaisemartin & d'Haultfœuille (2020) — when TWFE weighting goes wrong.
4. Goodman-Bacon (2021) — the staggered-adoption decomposition.
5. Heckman, Ichimura & Todd (1997) — the classic selection-and-matching reference.

See [`references.md`](references.md) for full citations.
