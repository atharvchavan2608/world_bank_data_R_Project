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
and are read in place. The resulting PDF is `output/appendix.pdf`.

See `AGENTS.md` for the layout and research rules. `STATUS.md` identifies the
current phase, and `DECISIONS.md` records analytical changes.
