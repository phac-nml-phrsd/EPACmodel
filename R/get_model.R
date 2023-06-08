#' Get a macpan2 model from package models
#'
#' @template model_name
#'
#' @return a [macpan2::Model()] object
#' @export
get_model <- function(model_name){
  macpan2::Model(macpan2::ModelFiles(
    fs::path_package(file.path("models", model_name), package = "EPACmodel")
  ))
}
