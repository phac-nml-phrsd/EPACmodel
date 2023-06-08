#' Construct a simulator for a package model
#'
#' @template model_name
#' @param params Optional. If NULL, load a default set of parameters
#' @param state Optional. If NULL, load a default set of initial states
#' @param time_steps Number of time steps for which to run a simulation
#'
#' @return
#' @export
#'
#' @example make_simulator(model_name = "two-age-groups")
make_simulator <- function(
  model_name,
  params = NULL,
  state = NULL,
  time_steps = 100
){

  # load model
  model = get_model(model_name)

  # retrieve defaults if params and state are not provided
  if(is.null(params)) params = get_params(model_name)
  if(is.null(state)) state = get_state(model_name)

  # load in simulator expression and evaluate
  eval(parse(text = readLines(
    fs::path_package(file.path("models", model_name, "simulator-expression.R"), package = "EPACmodel")
  )))
}
