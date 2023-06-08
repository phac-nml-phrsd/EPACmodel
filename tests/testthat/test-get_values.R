test_that("default parameters are successfully retreived", {
  params = get_params("two-age-groups")
  expect_true("numeric" %in% class(params))
})

test_that("default state is successfully retreived", {
  state = get_state("two-age-groups")
  expect_true("numeric" %in% class(state))
})
