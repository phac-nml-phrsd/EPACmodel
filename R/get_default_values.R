#' Get named list of default values for a model
#'
#' @template param_model.name
#' @template param_local
#'
#' @return Named list of default values used to initialize a model for simulation
#' @export
get_default_values <- function(
    model.name,
    local = FALSE
){
  readRDS(get_model_path(
    model.name = model.name,
    file.name = "default_values.rds",
    local = local
  ))
}
