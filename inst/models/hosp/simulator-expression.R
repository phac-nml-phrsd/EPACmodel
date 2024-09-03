model$simulators$tmb(
  time_steps = values$time.steps,
  state = values$state,
  flow = flow,
  transmission. = transmission,
  contact. = contact,
  N.lb0 = macpan2::empty_matrix,
  N.lb5 = macpan2::empty_matrix,
  N.lb10 = macpan2::empty_matrix,
  N.lb15 = macpan2::empty_matrix,
  N.lb20 = macpan2::empty_matrix,
  N.lb25 = macpan2::empty_matrix,
  N.lb30 = macpan2::empty_matrix,
  N.lb35 = macpan2::empty_matrix,
  N.lb40 = macpan2::empty_matrix,
  N.lb45 = macpan2::empty_matrix,
  N.lb50 = macpan2::empty_matrix,
  N.lb55 = macpan2::empty_matrix,
  N.lb60 = macpan2::empty_matrix,
  N.lb65 = macpan2::empty_matrix,
  N.lb70 = macpan2::empty_matrix,
  N.lb75 = macpan2::empty_matrix,
  N.lb80 = macpan2::empty_matrix,
  I.lb0 = macpan2::empty_matrix,
  I.lb5 = macpan2::empty_matrix,
  I.lb10 = macpan2::empty_matrix,
  I.lb15 = macpan2::empty_matrix,
  I.lb20 = macpan2::empty_matrix,
  I.lb25 = macpan2::empty_matrix,
  I.lb30 = macpan2::empty_matrix,
  I.lb35 = macpan2::empty_matrix,
  I.lb40 = macpan2::empty_matrix,
  I.lb45 = macpan2::empty_matrix,
  I.lb50 = macpan2::empty_matrix,
  I.lb55 = macpan2::empty_matrix,
  I.lb60 = macpan2::empty_matrix,
  I.lb65 = macpan2::empty_matrix,
  I.lb70 = macpan2::empty_matrix,
  I.lb75 = macpan2::empty_matrix,
  I.lb80 = macpan2::empty_matrix,
  N. = macpan2::empty_matrix,
  scaled_infected. = macpan2::empty_matrix,
  infection. = macpan2::empty_matrix,
  infected. = macpan2::empty_matrix,
  dummy. = macpan2::empty_matrix
  , .mats_to_return = c("state", "total_inflow", "transmission.", "contact.", "flow")
  , .dimnames = list(total_inflow = list(names(values$state), ""))

  ## This is a hack. It is only necessary because I have not moved the
  ## better indexing functionality in the insert objects to the parsing
  ## of the derivation files.
)$insert$expressions(
  dummy ~ assign(flow, c(
    infection.lb0, infection.lb5, infection.lb10, infection.lb15,
    infection.lb20,infection.lb25, infection.lb30, infection.lb35,
    infection.lb40, infection.lb45, infection.lb50, infection.lb55,
    infection.lb60, infection.lb65, infection.lb70, infection.lb75,
    infection.lb80
  ), 0, infection.)
  , .at = 21L
  , .phase = "during"
  , .vec_by_flows = ""
)
