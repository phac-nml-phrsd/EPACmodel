#' List models available in the EPACmodel package
#' (these are the names available for use in [get_model()])
#'
#' @return character vector of model names
list_models <- function(){
  list.files(fs::path_package("models", package = "EPACmodel"))
}
