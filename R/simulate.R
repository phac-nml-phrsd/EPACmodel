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
simulate <- function(simulator) {
  # run simulation
  sim = simulator$report()

  # reformat output
  (sim
    |> dplyr::transmute(
      time,
      state_name = row,
      value_type = matrix,
      value
    )
  )
}
