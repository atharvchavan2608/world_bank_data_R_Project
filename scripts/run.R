if (!file.exists("AGENTS.md")) stop("Run this command from the project root.")
source("scripts/setup.R")
source("scripts/build.R")
if (!rmarkdown::pandoc_available()) stop("Pandoc was not found.")
if (!nzchar(Sys.which("pdflatex"))) stop("pdfLaTeX was not found on PATH.")

dir.create("output", showWarnings = FALSE)
run <- new.env(parent = globalenv())
build_analysis(run)
run$built_by_pipeline <- TRUE

rmarkdown::render(
  "appendix/appendix.Rmd", output_dir = normalizePath("output"),
  knit_root_dir = normalizePath("."), envir = run, clean = TRUE
)
