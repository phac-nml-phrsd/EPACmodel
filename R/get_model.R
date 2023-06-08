#' Get read macpan2 model from standard model-definition files
#'
#' @param name name of the model (see [list_models()] for options)
#'
#' @return a [macpan2::Model()] object
#' @export
get_model <- function(name){
  macpan2::Model(macpan2::ModelFiles(
    fs::path_package(file.path("models", name), package = "EPACmodel")
  ))
}
