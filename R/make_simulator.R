#' Construct a simulator for a package model
#'
#' @template param_model.name
#' @param scenario.name Optional. Name of scenario to simulate. See README for `model.name` for options. If NULL, use base model.
#' @param updated.values Optional. List containing updates to variables + values used to initialize the model simulator. If NULL, use default list is read from disk and used as is.
#'
#' @return a [macpan2::TMBSimulator()] object
#' @export
make_simulator <- function(
  model.name,
  scenario.name = NULL,
  updated.values = NULL
){

  # convert NULL scenario.name to empty string to make
  # if statements cleaner
  if(is.null(scenario.name)) scenario.name = ""

  # load model
  model = get_model(model.name)

  # source helpers, if need be
  helpers_filename = system.file(
    file.path("models", model.name, "helpers.R"),
    package = "EPACmodel")
  if(file.exists(helpers_filename)){
    eval(parse(text = readLines(
      helpers_filename
    )))
  }

  # get default values required to initialize model simulator + make model modifications
  values = get_default_values(model.name)

  # update values from default, as requested
  if(!is.null(updated.values)){
    names.to.replace = intersect(names(updated.values), names(values))

    for(name in names.to.replace){
      values[[name]] = updated.values[[name]]
    }
  }

  # expressions to run before initializing the simulator,
  # if present
  before_sim_filename = system.file(
    file.path("models", model.name, "run-before-simulator.R"),
    package = "EPACmodel")
  if(file.exists(before_sim_filename)){
    eval(parse(text = readLines(
      before_sim_filename
    )))
  }

  # load in simulator expression and evaluate
  model_simulator = eval(parse(text = readLines(
    fs::path_package(file.path("models", model.name, "simulator-expression.R"), package = "EPACmodel")
  )))

  # expressions to run after initializing simulator (model modifications),
  # if present
  after_sim_filename = system.file(file.path("models", model.name, "run-after-simulator.R"), package = "EPACmodel")
  if(file.exists(after_sim_filename)){
    eval(parse(text = readLines(
      after_sim_filename
    )))
  }

  return(model_simulator)
}
