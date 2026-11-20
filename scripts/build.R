build_analysis <- function(target) {
  if (!file.exists("AGENTS.md")) stop("Run the analysis from the project root.")
  if (.Platform$OS.type == "windows") {
    invisible(Sys.setlocale("LC_CTYPE", ".UTF-8"))
  }
  dir.create("generated", showWarnings = FALSE)
  stages <- sort(list.files("R", pattern = "^[0-9][0-9]_.*[.]R$", full.names = TRUE),
                 method = "radix")
  if (!length(stages)) stop("No analysis stages were found.")
  for (script in stages) sys.source(script, envir = target)
  invisible(target)
}
