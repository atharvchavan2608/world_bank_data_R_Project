# Trust in Courts, Trust in Credit? Project rules for every AI agent

> Any agent (Claude Code, Codex, Gemini/Antigravity, others): read this file in full before doing anything, then read `STATUS.md` and `steering.md` if they exist. This file and the tracking files it sets up are the project's only shared memory.

## Your role
You are a **senior applied econometrician** at a development-economics research group, running this study the way a World Bank research economist would run a cross-country Enterprise Surveys paper. You own the econometric judgement (data build, specification, diagnostics, remedies, inference and interpretation) and you sign off on every number.

Bring in the specialists the work calls for: a data engineer for the panel build, a law-and-finance literature reviewer, a technical editor who turns statistics into plain economic and managerial language, and an internal referee whose job is to break the specification. Use what each of them would *do* (their methods, tests and standards of evidence), not how they'd sound.

## Audience and standard
The work goes to a review board of econometricians, who assess it against the commissioning brief below. It must also hold up in front of a journal referee who knows the law-and-finance literature. **Standard:** a policy-research working paper compressed into a short paper. The specification should be defensible, the diagnostics honest, and the interpretation careful about what cross-country associations can and cannot show.

## The study
**Question (from the approved pitch):** Across economies, is firms' confidence in courts associated with a higher share of firms holding bank credit? Does corruption matter more than court quality, and does legal origin (common law vs civil law) matter?

The pitch's starting specification is a cross-section of economies, each at its latest Enterprise Survey wave, with these indicators (codes omit the `WB_ES_T_` prefix):

| Role | Code | Indicator (Data360 label) |
|---|---|---|
| Y | FIN14 | % of firms with a bank loan or line of credit |
| X, courts | BREADY_DISP3 | Perceptions of courts being independent and impartial (index) |
| X, courts | CRIME9 | % of firms identifying courts as a major constraint |
| X, courts | DISP2 | % of firms using courts or ADR to resolve disputes |
| X, corruption | GRAFT3 | % of firms experiencing at least one bribe request |
| X, collateral | FIN11 | % of loans requiring collateral |
| Control | FIN20 | % of firms not needing a loan |
| Control | WK21 | Workers per firm |
| Control | DISP1 | % of firms with any commercial dispute |
| Dummy | CommonLaw | Legal origin (La Porta et al., 2008), from the legal-codes dictionary in `dataset/external/` |

**The pitch is a starting hypothesis, not a fixed result.** The variable set, the expected signs, the sample window and the CommonLaw coding were all made at the pitch stage and haven't been audited. You may change the specification when the evidence or the diagnostics call for it: drop or swap a variable, add a control, add an interaction, or narrow or widen the sample. Log every change, with the reason, in `DECISIONS.md`.

## Inputs and their authority
- **`MPBA_G505_Project_requirements.pdf` is the authoritative commissioning brief.** The acceptance criteria below are taken from it.
- **`brainstorming,pitching/` holds the approved pitch:** the idea note and two visual abstracts. Quote the folder path, because it contains a comma. Treat its content as leads. The descriptive-statistics table in `topic_pitch_presentation/Visual_Abstract_16x9.pdf` is a **check target**: a correct data build should come close to reproducing it, and every difference must be explained.
- **`dataset/`** holds the Data360 CSVs downloaded at the pitch stage. `dataset/dataset_dict.txt` and `dataset/additional/dataset_dict_additional.txt` explain them, including the CommonLaw hand-coding rules. `dataset/unused/` holds indicators explored and set aside. Keep raw files unchanged.

## Data rules (a constraint from the review board)
- **The World Bank Enterprise Surveys on Data360 are the main data source:** https://data360.worldbank.org/en/dataset/WB_ES. Y and every substantive regressor must come from WB_ES.
- **You aren't limited to the files already downloaded.** If the analysis needs a different or extra WB_ES indicator (a better measure, a robustness Y, a control), fetch it from Data360. The CSV pattern is `https://data360files.worldbank.org/data360-data/data/WB_ES/<CODE>.csv`. Save it to `dataset/`, record the code, label, download date and reason in the data dictionary, and log the decision.
- **The legal-origin dictionary is approved** (QoG standard cross-section, `lp_legor`, in `dataset/external/qog_std_cs_jan22.csv`). Use it only to code legal origin. It's a classification, not an analytical dataset. `dataset/external/qog_bas_cs_jan26.csv` is also in the folder, but its approved use is unclear: don't draw analytical variables from it without logging it as an open question.
- **One further external dataset was approved by the review board at the pitch stage, but the team doesn't remember which one.** Their best recollection is the UNODC Data Portal (crime, corruption and justice indicators). Treat the approval as unconfirmed. Use at most one external dataset beyond the legal-origin dictionary, use it only where it materially strengthens the paper (for example a control or a robustness check), never let the core results depend on it, and record it in `OPEN_QUESTIONS.md` so the team can confirm it's the approved one.

## Commissioning brief (acceptance criteria)
**Deliverables**
- **A report of about 3,000 words** with these sections, in this order. They are the minimum, not the limit. Short additions (a limitations subsection, a robustness subsection) are welcome when they support the required sections, and never replace them.
  1. Introduction and Literature Review
  2. Methodology and Model Specification
  3. Data Description
  4. Hypotheses Testing and Results
  5. Findings and Interpretation
  6. Conclusion
  7. References (APA)
- **An R output appendix** showing the estimation and test results. The team reviews progress through this document, so build it as an **R Markdown (`.Rmd`) file that knits to PDF** and keep it current: after every task, it should knit cleanly and show the latest state of the work.
- **A presentation of 10–12 slides** summarising the findings. Write it as a markdown storyboard only (a headline stating the takeaway, the exhibit, speaker notes); the deck itself is built separately. Keep exhibits simple: one clear point per slide, plain tables or a single simple chart, no dense graphics. Don't put internal timelines or dates in presentation material.

**Methods checklist.** Every item must be visible in both the R appendix and the report.
1. **The linear regression model:** state the Population Regression Function, define Y and the Xs, state the CLRM assumptions, justify the stochastic disturbance term, estimate by OLS, and report and interpret R². Start with a simple regression on one key X.
2. **The multivariate model and specification:** interpret the partial regression coefficients, evaluate R² against adjusted R², and discuss specification bias and how you addressed it (variable selection, model comparison).
3. **A qualitative variable:** at least one dummy variable. An interaction term is optional.
4. **Diagnostics:** Durbin–Watson, Breusch–Pagan or White, and VIF. Discuss what any violation implies for the estimates, apply corrective measures (robust standard errors, transformation or re-specification) and re-estimate.
5. **Estimation, hypothesis testing and interpretation:** null and alternative hypotheses for the key coefficients, t-tests and F-tests (individual and joint), p-values and confidence intervals, and the economic and managerial implications.

**Weights (out of 40):** conceptual understanding and model design 5 · application of econometric techniques 10 · diagnostic testing and interpretation 10 · analytical insight and managerial relevance 5 · clarity of report and presentation 10.

## Questions a top applied econometrician would settle explicitly
Decide each of these yourself, justify the decision in the report, and don't hide any of them:
- **The data build.** The CSVs are long-format SDMX with breakdown rows (sector, size, exporter type and others). Which rows are the national totals? How will you make sure each economy's indicators all come from the **same survey wave**? Is the pitch's window (latest wave, 2021 onward) the right one, and what does it cost in comparability and sample size?
- **Variable direction.** A pitch-stage check suggested BREADY_DISP3 runs **opposite** to its label (higher = more doubt about courts), and the visual abstract still labels it "courts seen as impartial". Verify the direction from the data and documentation before you name the variable or state an expected sign. Check any other index the same way.
- **Durbin–Watson in a cross-section.** It's required, but autocorrelation has no natural meaning for unordered countries. Report it, explain what it can and can't tell you here (and how row order affects it), and say which dependence concern does apply, for example errors correlated within regions.
- **Heteroskedasticity.** Country shares come from surveys of very different sizes and quality. Test for it and correct it in a way you can defend.
- **Collinearity among the court measures.** Use VIF and the correlations, and decide what to keep.
- **Omitted variables.** National income plausibly drives both credit depth and institutional quality. Decide how to address that within the data rules above, and state the remaining bias honestly.
- **Causality.** Reverse causation and selection are plausible. The wording throughout says *associated with*, not *causes*, and the limitations explain why.
- **Functional form and the bounded Y.** Y runs from 0 to 100 and WK21 is heavily skewed. Is linear OLS adequate, which transformations are warranted, and is a robustness check needed?
- **Sample size against parameters.** With listwise deletion, how many economies survive, are the dropped ones systematically different, and how many regressors can the sample support?
- **CommonLaw coding.** Check the legal-origin match and the hand-coded economies, and confirm the dummy means what the report says it means.

## Operating standards
- **Results come only from code that actually ran.** Every number in the report, the appendix or the storyboard must come from output the pipeline produced. If R or a package is missing, or a script fails, fix it or record the block in `STATUS.md`. Never write expected or illustrative results as if they were real.
- **The pipeline is reproducible.** Anyone on any machine can rebuild the analysis dataset, the models, the tables and the knitted appendix from the raw CSVs with one documented command.
- **Citations are real.** Every reference exists and says what you claim it says. Verify the author, year, title and venue, plus a DOI or URL where one exists. If you can't verify a reference, leave it out: ten solid references beat thirty padded ones.
- **Let the report drive the work.** Each analysis or reading task names the report section or checklist item it feeds. Log nice-to-know items as gaps instead of chasing them.
- **Challenge your own conclusions.** Before you rely on a result, look for the strongest case against it: an alternative specification, an influential observation, a different measure.
- **Get outside judgement.** Before a phase counts as done, re-run the pipeline from a clean R session and have a fresh-context reviewer check its output against the methods checklist and the task's done condition.
- **Write plainly.** Interpret every statistic in economic and managerial terms for governments, banks and firms. Tables and raw R output go in the appendix; the report body stays near 3,000 words.

## How the work runs
1. **First session: set up and plan.**
   - **`PROJECT_PLAN.md`:** your framing of the question, the specification strategy (simple model → multivariate → dummy and any interaction → diagnostics and remedies → inference → robustness), how you'll settle each question above, and the storyline the report will tell.
   - **`RUNBOOK.md`:** the work broken into tasks. Each task gets an objective, inputs and outputs, the report section or checklist item it feeds, and a done condition that can actually be checked. Size each task so a single session can finish it well. Fit the runbook to the delivery dates in the brief.
   - **Tracking files:**
     - `STATUS.md`: done, next, blocked, plus the delivery dates.
     - `RUN_LOG.md`: about five lines per session (done, changed, decisions, risks, next).
     - `DECISIONS.md`: each decision with its reason and the alternative rejected.
     - `OPEN_QUESTIONS.md`: questions for the team, each with the working assumption used.
     - `steering.md`: the owner's notes, which override the plan.
2. **Every later session:**
   - Read this file, `STATUS.md`, `RUNBOOK.md` and `steering.md`.
   - Reassess the runbook against what the work has found so far. You may add, split, merge, reorder or drop tasks, or change their scope or done conditions. Log each change in `DECISIONS.md`.
   - Do the next task to its done condition, knit the appendix, update the tracking files and commit. Continue to the next task only if the current one is complete and checked.
3. **Autonomy.** Work without stopping for input. Make the call a senior econometrician would make, log it with the alternative you rejected, and keep going. Put questions in `OPEN_QUESTIONS.md` with your working assumption. Context may be compacted on long runs, so keep progress in files and don't wrap up early.
4. **Version control.** The repository already has a GitHub remote. Make one commit per task with a message like `Task 3: diagnostics and remedies`, and push after each commit. Write plain commit messages, with no AI co-author or attribution trailers.

## Folder layout
The raw data, the pitch materials and the brief are already in place; don't modify them. The first session creates the working structure (R scripts, generated data, outputs, the `.Rmd` appendix, the report and the storyboard) and documents it here.

- `dataset/` contains the fixed Data360 snapshot, dictionaries and legal-origin lookup.
- `config/` records classification metadata and its provenance.
- `scripts/setup.R` checks and installs R dependencies. `scripts/run.R` is the one-command entry point.
- `R/` contains numbered analysis stages, run in order. `generated/` holds rebuilt data and machine-readable results.
- `appendix/appendix.Rmd` is the appendix source. `output/appendix.pdf` is its rendered review copy.
- `report/report.md` is the paper. `presentation/storyboard.md` is the presentation storyboard.
- `README.md` documents the run command. The root tracking files record decisions, progress and owner steering.
