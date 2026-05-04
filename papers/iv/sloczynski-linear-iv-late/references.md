# References

## The paper

Słoczyński, T. (2022). *When Should We (Not) Interpret Linear IV Estimands as LATE?* arXiv:2011.06695 (this version v8, April 2026; forthcoming in *Quantitative Economics*).

- [arXiv](https://arxiv.org/abs/2011.06695)
- [Google Scholar search](https://scholar.google.com/scholar?q=When+Should+We+%28Not%29+Interpret+Linear+IV+Estimands+as+LATE+Sloczynski)

*Update this entry when a stable journal DOI becomes available.*

## Related reading

1. Imbens, G. W., & Angrist, J. D. (1994). Identification and estimation of local average treatment effects. *Econometrica*, 62(2), 467–475. The original LATE theorem; defines monotonicity and identification under what Słoczyński calls Strong Monotonicity. [Google Scholar search](https://scholar.google.com/scholar?q=Imbens+Angrist+1994+Identification+estimation+local+average+treatment+effects)
2. Angrist, J. D., & Imbens, G. W. (1995). Two-stage least squares estimation of average causal effects in models with variable treatment intensity. *Journal of the American Statistical Association*, 90(430), 431–442. The fully-interacted 2SLS specification (`Y ~ D·G | Z·G`) that Słoczyński's Lemma 3.1 and Theorem 3.2 characterize under WM. [Google Scholar search](https://scholar.google.com/scholar?q=Angrist+Imbens+1995+Two-stage+least+squares+variable+treatment+intensity)
3. Kolesár, M. (2013). *Estimation in an Instrumental Variables Model with Treatment Effect Heterogeneity*. Working paper. The closest antecedent: gives a generic two-step IV representation as a positively-weighted average of conditional LATEs under weak monotonicity, subject to a case-by-case verifiable condition. Słoczyński trades Kolesár's generality for transparency by specializing to the noninteracted IV and AI-interacted 2SLS. [Google Scholar search](https://scholar.google.com/scholar?q=Kolesar+2013+Estimation+Instrumental+Variables+Treatment+Effect+Heterogeneity)
4. Blandhol, C., Bonney, J., Mogstad, M., & Torgovitsky, A. (2025). *When is TSLS Actually LATE?* The sibling paper in this repository's `iv/` bucket. Same diagnosis ("linear IV with covariates is not the LATE you think it is"), different mechanism (misspecification of the implicit propensity score rather than the conditional first stage). [NBER working paper](https://www.nber.org/papers/w29709)
5. Mogstad, M., Torgovitsky, A., & Walters, C. R. (2021). The causal interpretation of two-stage least squares with multiple instrumental variables. *American Economic Review*, 111(11), 3663–3698. Sufficient conditions for TSLS with multiple instruments to admit a positively-weighted causal interpretation. [publisher page](https://www.aeaweb.org/articles?id=10.1257/aer.20190221)
6. Chao, J. C., Swanson, N. R., & Woutersen, T. (2023). *Jackknife estimation of a cluster-sample IV regression model with many weak instruments*. The FEJIV estimator implemented in Słoczyński's companion `fejiv` package. [Google Scholar search](https://scholar.google.com/scholar?q=Chao+Swanson+Woutersen+jackknife+estimation+cluster-sample+IV+many+weak+instruments)
