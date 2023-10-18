if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

req_pkgs <- c(
  "devtools",
  "dplyr",
  "glue",
  "readr",
  "tibble",
  "yaml"
)

pak::pak(req_pkgs)

# Setup ------------------------------------------------------------------------
read_description <- yaml::read_yaml("DESCRIPTION")

pkg_name <- read_description$Package

# Create the src/contrib directory ---------------------------------------------
tiny_cran <- getwd()

contrib_dir <- file.path(tiny_cran, "src", "contrib")
if (!dir.exists(contrib_dir)) {
  dir.create(contrib_dir, recursive = TRUE)
}

# Repository name --------------------------------------------------------------
if (length(read_description$Repository) == 0) {
  desc_line <- paste0("Repository: ", pkg_name)
  cat(desc_line, file = "DESCRIPTION", append = TRUE, sep = "\n")
}

# Copy -------------------------------------------------------------------------
devtools::build(".", path = ".")

tar_path <- list.files(pattern = "tar.gz")

if (length(tar_path) != 1) {
  stop("Missing or multiple tar.gz files found")
}

# Copy it to the src/contrib sub-directory
file.copy(
  from = file.path(tar_path),
  to = file.path(contrib_dir, tar_path),
  overwrite = TRUE
)

# Write packages for each sub-directory ----------------------------------------
tools::write_PACKAGES(contrib_dir, type = "source")

# Delete the temp file
unlink(tar_path)
