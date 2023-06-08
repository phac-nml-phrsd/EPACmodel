test_that("list_models() returns a list of model names", {
  model_list <- list_models()
  expect_equal(class(model_list), "character")
})
