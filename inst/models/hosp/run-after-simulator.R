# set up model simulator to accept updated parameter values
pf <- (data.frame()
  |> add_to_pf("state", values$state)
  |> add_to_pf("flow", flow)
  |> add_to_pf("transmission.", transmission)
  |> add_to_pf("contact.", contact)
)

if (scenario.name == "change-contacts") {
  contact_changepoints_to_fill <- calculate_contact_changepoints(values)
  contact_values_to_fill <- calculate_contact_values(values)
  transmission_values_to_fill <- calculate_transmission_values(values)

  model_simulator$add$matrices(
    contact_changepoints = contact_changepoints_to_fill
    # need to have "changepoint" for initial set of pars at t = 0
    , contact_pointer = 0,
    contact_values = contact_values_to_fill,
    transmission_values = transmission_values_to_fill,
    n.age.group = length(seq(0, 80, by = 5)),
    .mats_to_save = c("contact.", "transmission."),
    .mats_to_return = c("contact.", "transmission.")
  )$insert$expressions(
    contact_pointer ~ time_group(contact_pointer, contact_changepoints),
    contact. ~ block(
      contact_values, n.age.group * contact_pointer,
      0, n.age.group, n.age.group
    ),
    transmission. ~ block(
      transmission_values,
      0, contact_pointer,
      n.age.group, 1
    ),
    .phase = "during"
  )

  # set up to accept updated scenario parameters
  pf <- (pf
    |> add_to_pf("contact_changepoints", contact_changepoints_to_fill)
    |> add_to_pf("contact_values", contact_values_to_fill)
    |> add_to_pf("transmission_values", transmission_values_to_fill)
  )
}

model_simulator$replace$params_frame(pf)
