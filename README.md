# Trust in Courts, Trust in Credit?

An economy-level study of Enterprise Survey bank credit, court perceptions,
bribery exposure and legal origin.

From the repository root, run the analysis and knit the appendix in one command.

```sh
Rscript --vanilla scripts/run.R
```

On the project Windows machine, R is outside PATH. Use PowerShell.

```powershell
& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla scripts/run.R
```

Install R, Pandoc and a TeX distribution with `pdflatex` available before
running. The pipeline calls `scripts/setup.R` to check R packages and install
missing dependencies into `.study-library/`. Input CSVs ship with the project
and are read in place. The resulting PDF is `output/appendix.pdf`. The audit,
estimation and diagnostic tables are rebuilt as CSVs under `generated/`.
For example, `pitch_reconciliation.csv` compares every displayed pitch
statistic, and `sensitivity.csv` gives estimates and intervals for the
alternative specifications.

With the dependencies installed, you can also open `appendix/appendix.Rmd`
in RStudio and knit to PDF. The appendix calls the same analysis stages in a
fresh knit. For direct knitting, rmarkdown and knitr must be on RStudio's
library path. The command above handles the local library and writes the
review copy to `output/`.

The [paper](report/report.md) and [storyboard](presentation/storyboard.md)
interpret those outputs. See `AGENTS.md` for the research rules,
`STATUS.md` for the current phase and `DECISIONS.md` for analytical changes.
