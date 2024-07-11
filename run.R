# --------------------------------
# Description: Execute Pipeline
# --------------------------------

message("Executing Pipeline")

targets::tar_make_clustermq(workers = parallel::detectCores() - 1L)