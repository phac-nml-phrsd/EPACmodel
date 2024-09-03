#' Simulate from a simulator
#'
#' @param simulator Simulator object, initialized using [make_simulator()]
#' @param values Complete list of model values to update the model simulator before generating the simulation. Must match format of `params` list from default (output of [get_default_values()] for desired model). If `NULL`, use values as currently attached to the model simulator.
#'
#' @return A data frame containing simulation results with columns
#'  - `time`: time in days from simulation start
#'  - `state_name`: compartment name
#'  - `value_type`: type of values, such as `state` (count of individuals in a compartment) and `total_inflow` (total inflow into a compartment)
#'  - `value`
#' @export
simulate <- function(simulator, values = NULL) {

  if (is.null(values)) {
    sim = simulator$report()
  } else {
    message("Updating simulator values in `simulate` only supported for the `hosp` model currently.")
    # sim with new input values
    mats <- unique(simulator$current$params_frame()$mat)
    pvec = make_pvec(values, mats)
    sim = simulator$report(pvec)
  }

  # reformat output
  data.frame(
    time = sim$time,
    state_name = sim$row,
    value_type = sim$matrix,
    value = sim$value
  )
}
