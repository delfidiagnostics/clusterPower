# Parameters -------------------------------------------------------------------
local_cran_repo <- "ds-cran-local"
r_version <- "4.2"

# Checks -----------------------------------------------------------------------
if (nchar(Sys.getenv("ARTIFACTORY_PUBLISHER_USER")) == 0) {
  stop("Artifactory Username (`ARTIFACTORY_PUBLISHER_USER`) Not Found in R Environment")
}

if (nchar(Sys.getenv("ARTIFACTORY_PUBLISHER_PASS")) == 0) {
  stop("Artifactory Token (`ARTIFACTORY_PUBLISHER_PASS`) Not Found in R Environment")
}

# Create dataset ---------------------------------------------------------------
file_paths <- tibble::tribble(
  ~os, ~path, ~pattern,
  "linux", "src/contrib", "*.tar.gz"
) |>
  dplyr::mutate(
    file_path = NA_character_,
    base_url = dplyr::case_when(
      os == "linux" ~ glue::glue("https://delfi-artifactory.dev.delfidx.io/artifactory/api/cran/{local_cran_repo}/sources"),
      TRUE ~ NA_character_
    )
  )

for (i in seq_along(file_paths$os)) {
  os_oi <- file_paths[[i, 1]]
  archive_path <- list.files(
    path = subset(file_paths, os == file_paths[[i, 1]])$path,
    pattern = subset(file_paths, os == file_paths[[i, 1]])$pattern,
    full.names = TRUE,
    recursive = FALSE
  )
  file_paths <- file_paths |>
    dplyr::mutate(file_path = dplyr::if_else(os == os_oi, archive_path, file_path))
}

to_run <- file_paths |>
  dplyr::mutate(
    post_url = dplyr::case_when(
      os == "linux" ~ glue::glue("{base_url}"),
      TRUE ~ NA_character_
    ),
    sh_command = glue::glue("{Sys.getenv('ARTIFACTORY_PUBLISHER_USER')}:{Sys.getenv('ARTIFACTORY_PUBLISHER_PASS')}")
  ) |>
  dplyr::select(os, file_path, post_url, sh_command)

readr::write_csv(to_run, "tmp.csv")
