#' Get a [macpan2] model from package models
#'
#' @template param_model.name
#' @template param_local
#'
#' @return a [macpan2::Model()] object
#' @export
get_model <- function(model.name, local = FALSE){
  macpan2::Model(macpan2::ModelFiles(
    get_model_path(
      model.name = model.name,
      file.name = NULL,
      local = local
    )
  ))
}
