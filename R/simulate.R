#' Simulate from a simulator
#'
#' @param simulator Simulator object, initialized using [make_simulator()]
#'
#' @return A data frame with the simulation results
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
