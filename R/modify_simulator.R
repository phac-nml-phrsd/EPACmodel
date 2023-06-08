modify_simulator <- function(
    model_simulator,
    mods_name,
    model_name){
  # load in simulator expression and evaluate
  source(fs::path_package(file.path("models", model_name, "model-mods",
                               paste0(mods_name, ".R")), package = "EPACmodel"))

  return(model_simulator)
}
