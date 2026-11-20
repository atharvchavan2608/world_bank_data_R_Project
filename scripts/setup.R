packages <- c(
  rmarkdown = "Render the analysis appendix through Pandoc and LaTeX.",
  knitr = "Execute appendix chunks and format reproducible tables."
)

local_library <- normalizePath(".study-library", winslash = "/", mustWork = FALSE)
if (dir.exists(local_library)) .libPaths(c(local_library, .libPaths()))
available <- vapply(names(packages), requireNamespace, logical(1), quietly = TRUE)
message(paste(names(packages), packages, sep = " - ", collapse = "\n"))
if (any(!available)) {
  dir.create(local_library, showWarnings = FALSE)
  .libPaths(c(local_library, .libPaths()))
  install.packages(names(packages)[!available], lib = local_library,
                   repos = "https://cloud.r-project.org")
}
stopifnot(all(vapply(names(packages), requireNamespace, logical(1), quietly = TRUE)))
