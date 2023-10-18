old_files_src <- list.files(file.path(getwd(), "src", "contrib"), full.names = TRUE)

old_files_to_rm <- c(old_files_src, "tmp.csv")
unlink(old_files_to_rm, recursive = TRUE, force = TRUE)
