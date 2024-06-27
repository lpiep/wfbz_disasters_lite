# --------------------------------
# Description: Execute Pipeline
# --------------------------------

message("Executing Pipeline")

targets::tar_make_clustermq(workers = 10)