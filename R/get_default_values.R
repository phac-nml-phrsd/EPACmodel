#' Get named list of default values for a package model
#'
#' @template param_model.name
#'
#' @return named list of default values used to initialize model
#' @export
get_default_values <- function(model.name){
  readRDS(fs::path_package(file.path("models", model.name, "default_values.rds"), package = "EPACmodel"))
}
