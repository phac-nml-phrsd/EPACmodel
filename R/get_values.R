#' Get values for a package model
#'
#' @template model_name
#' @param values_file name of the file from which we're loading the values
#'
#' @return values from file
get_values <- function(model_name, values_file){
  (fs::path_package(file.path("models", model_name, values_file), package = "EPACmodel")
   |> readr::read_csv(show_col_types = FALSE)
   |> with(setNames(Default, Variable))
  )
}

#' Get default parameters for a package model
#'
#' @template model_name
#'
#' @return Named numeric vector
#' @export
get_params <- function(model_name){
  get_values(model_name, "params.csv")
}

#' Get default initial state for a package model
#'
#' @template model_name
#'
#' @return Named numeric vector
#' @export
get_state <- function(model_name){
  get_values(model_name, "state.csv")
}
