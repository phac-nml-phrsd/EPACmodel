#' List available models
#'
#' These are the names available for use in [get_model()]
#'
#' @template param_local
#'
#' @return Character vector of model names
#' @export
list_models <- function(
    local = FALSE
){
  list.files(get_model_path(
    model.name = NULL,
    file.name = NULL,
    local = local
  ))
}
