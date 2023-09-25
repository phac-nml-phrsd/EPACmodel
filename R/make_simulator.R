#' Construct a simulator for a package model
#'
#' @template param_model.name
#' @param scenario.name Optional. Name of scenario to simulate. See README for `model.name` for options. If NULL, use base model.
#' @param updated.values Optional. List containing updates to variables + values used to initialize the model simulator. If NULL, use default list is read from disk and used as is.
#' @template param_local
#'
#' @return a [macpan2::TMBSimulator()] object
#' @export
make_simulator <- function(
  model.name,
  scenario.name = NULL,
  updated.values = NULL,
  local = FALSE
){

  # convert NULL scenario.name to empty string to make
  # if statements cleaner
  if(is.null(scenario.name)) scenario.name = ""

  # load model
  model = get_model(model.name, local = local)

  # source helpers, if need be
  helpers.file.name = get_model_path(
    model.name = NULL,
    file.name = paste0("helpers_", model.name, ".R"),
    dir.name = "R",
    local = local
  )
  if(!is.null(helpers.file.name)){
    eval(parse(text = readLines(
      helpers.file.name
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
  before.sim.file.name = get_model_path(
    model.name = model.name,
    file.name = "run-before-simulator.R",
    local = local
  )
  if(!is.null(before.sim.file.name)){
    eval(parse(text = readLines(
      before.sim.file.name
    )))
  }

  # load in simulator expression and evaluate
  model_simulator = eval(parse(text = readLines(
    get_model_path(
      model.name = model.name,
      file.name = "simulator-expression.R",
      local = local
    )
  )))

  # expressions to run after initializing simulator (model modifications),
  # if present
  after.sim.file.name = get_model_path(
    model.name = model.name,
    file.name = "run-after-simulator.R",
    local = local
  )
  if(!is.null(after.sim.file.name)){
    eval(parse(text = readLines(
      after.sim.file.name
    )))
  }

  return(model_simulator)
}
