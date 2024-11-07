values <- get_default_values("hosp")

test_that("mk_contact_pars() returns expected errors", {
  # setting weight vector without names 
  expect_snapshot(
    error = TRUE,
    local({
      mk_contact_pars(setting.weight = 1:4)
    })
  )

  # setting weight vector with wrong names
  expect_snapshot(
    error = TRUE,
    local({
      setting.weight <- 1:4
      names(setting.weight) <- letters[setting.weight]
      mk_contact_pars(setting.weight = setting.weight)
    })
  )

  # incompatible age groups and new population vector
  expect_snapshot(
    error = TRUE,
    local({
      mk_contact_pars(
        age.group.lower = c(0, 20, 60),
        setting.weight = values$setting.weight,
        pop.new = 1:2
      )
    })
  )
})

# test set of contact parameters
cp_test <- list(
  # don't aggregate over age groups or renormalize population
  mk_contact_pars(setting.weight = values$setting.weight),
  # aggregate over age groups only
  mk_contact_pars(
    age.group.lower = c(0, 20, 60),
    setting.weight = values$setting.weight
  ),
  # renormalize population only
  mk_contact_pars(
    pop.new = rep(3e5, 85),
    setting.weight = values$setting.weight
  ),
  # aggregate over age groups and renormalize population
  mk_contact_pars(
    age.group.lower = c(0, 20, 60),
    setting.weight = values$setting.weight,
    pop.new = rep(1e7, 3)
  )
)

test_that("mk_contact_pars() returns expected output under different usecases", {
  expect_snapshot(cp_test[[1]])
  expect_snapshot(cp_test[[2]])
  expect_snapshot(cp_test[[3]])
  expect_snapshot(cp_test[[4]])
})

test_that("contact probability matrices have rows that sum to 1", {
  invisible(purrr::walk2(
    purrr::map(cp_test, \(x){
      rowSums(x$p.mat)
    }),
    purrr::map(cp_test, \(x){
      rep(1, nrow(x$p.mat))
    }),
    expect_equal
  ))
})
