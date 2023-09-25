#' List models available either locally or in the [EPACmodel] package
#'
#' These are the names available for use in [get_model()]
#'
#' @template param_local
#'
#' @return character vector of model names
#' @export
list_models <- function(local = FALSE){
  list.files(get_model_path(
    model.name = NULL,
    file.name = NULL,
    local = local
  ))
}
