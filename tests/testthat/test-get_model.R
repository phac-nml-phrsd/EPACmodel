test_that("get_model() returns a macpan2 model object", {
  model <- get_model("two-age-groups")
  expect_true("Model" %in% class(model))
})
