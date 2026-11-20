if (!file.exists("AGENTS.md")) stop("Run this command from the project root.")
source("scripts/setup.R")
if (!rmarkdown::pandoc_available()) stop("Pandoc was not found.")

dir.create("output", showWarnings = FALSE)
rmarkdown::render(
  "notebook/notebook.Rmd",
  output_dir = normalizePath("output"),
  knit_root_dir = normalizePath("."),
  envir = new.env(parent = globalenv()),
  clean = TRUE
)
