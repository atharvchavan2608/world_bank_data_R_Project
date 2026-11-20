# Decisions

| Task | Decision and reason | Alternative considered |
|---|---|---|
| 0 | Keep the pitch snapshot fixed and use the latest observed FIN14 economy-year to anchor merges. This retains visible missingness and prevents inter-wave joins. | Taking the latest year in each source independently, or selecting a complete wave before measuring attrition. |
| 0 | Treat the printed delivery years as unresolved and plan for November 2026, consistent with the brief's academic session and pitch date. | Silently correcting the source dates. |
| 0 | Use equal economy weights and separate firm-level weighting from cross-economy inference. | Population or interview-count weights without a corresponding estimand or indicator-level design variances. |
| 0 | Keep the headline specification parsimonious and test potentially selected or jointly determined pitch measures in additional models. | Making the full pitch equation the primary model on theoretical grounds alone. |
| 0 | Use the two installed rendering packages and transparent base R calculations with verification identities for the statistical work. | Requiring tidyverse, car, lmtest and sandwich installations for operations that can be checked directly with R. |
| 0 | Incorporated the independent review by checking the outcome anchor against a union roster, requiring an observable attrition profile, specifying a signed standardized contrast with joint covariance, and adding region omissions and cluster-count checks. | Treating the pitch roster as automatically complete, comparing p-values across coefficients, or interpreting a small-cluster test without coverage checks. |
