#' Get a [macpan2] model from package models
#'
#' @template param_model.name
#'
#' @return a [macpan2::Model()] object
#' @export
get_model <- function(model.name){
  macpan2::Model(macpan2::ModelFiles(
    fs::path_package(file.path("models", model.name), package = "EPACmodel")
  ))
}
