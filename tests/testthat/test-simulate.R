test_that("simulate() returns output and format is consistent", {
  simulator = make_simulator(model.name = "old-and-young")
  sim = simulate(simulator)
  expect_true(!is.null(sim))
  expect_equal(names(sim), c("time", "state_name", "value_type", "value"))
})
