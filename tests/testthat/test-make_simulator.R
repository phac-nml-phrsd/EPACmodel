test_that("simulator is initialized", {
  expect_true("TMBSimulator" %in% class(make_simulator("five-year-age-groups")))
})

test_that("value gets updated from default", {
  updated_values = list(
    transmissibility = 0
  )

  expect_true(
    all(
    make_simulator("five-year-age-groups",
                   updated_values = updated_values)$tmb_model$data_arg()$mats[[3]] == 0
    )
  )
})
