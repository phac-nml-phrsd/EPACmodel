#' Simulate from a simulator
#'
#' @param simulator Simulator object, initialized using [make_simulator()]
#'
#' @return A data frame containing simulation results with columns
#'  - `time`: time in days from simulation start
#'  - `state_name`: compartment name
#'  - `value_type`: type of values, such as `state` (count of individuals in a compartment) and `total_inflow` (total inflow into a compartment)
#'  - `value`
#' @export
simulate <- function(simulator, values = NULL) {

  if(is.null(values)){
    sim = simulator$report()
  } else{
    # calculate new input values
    pvec = make_pvec(values)
    sim = simulator$report(pvec)
  }

  # reformat output
#   data.frame(
#     time = sim$time,
#     state_name = sim$row,
#     value_type = sim$matrix,
#     value = sim$value
#   )
}
