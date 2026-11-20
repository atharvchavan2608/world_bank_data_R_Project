if (!file.exists("AGENTS.md")) stop("Run this command from the project root.")
if (.Platform$OS.type == "windows") {
  invisible(Sys.setlocale("LC_CTYPE", ".UTF-8"))
}
source("scripts/setup.R")
if (!rmarkdown::pandoc_available()) stop("Pandoc was not found.")
if (!nzchar(Sys.which("pdflatex"))) stop("pdfLaTeX was not found on PATH.")

dir.create("generated", showWarnings = FALSE)
dir.create("output", showWarnings = FALSE)
plan <- list.files("R", pattern = "^[0-9][0-9]_.*[.]R$", full.names = TRUE)
run <- new.env(parent = globalenv())
for (script in plan) sys.source(script, envir = run)

rmarkdown::render(
  "appendix/appendix.Rmd", output_dir = normalizePath("output"),
  knit_root_dir = normalizePath("."), envir = run, clean = TRUE
)
