test_that("simulator is initialized for model that doesn't have helper functions", {
  expect_true("TMBSimulator" %in% class(make_simulator(model.name = "old-and-young")))
})

test_that("simulator is initialized for model that has functions", {
  expect_true("TMBSimulator" %in% class(make_simulator(model.name = "five-year-age-groups")))
})

test_that("value gets updated from default", {
  updated.values = list(
    transmissibility = 0
  )

  expect_true(
    all(
    make_simulator(
      model.name = "five-year-age-groups",
      updated.values = updated.values)$tmb_model$data_arg()$mats[[3]] == 0
    )
  )
})
