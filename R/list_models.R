#' List models available in the [EPACmodel] package
#'
#' These are the names available for use in [get_model()]
#'
#' @return character vector of model names
#' @export
list_models <- function(){
  list.files(fs::path_package("models", package = "EPACmodel"))
}
