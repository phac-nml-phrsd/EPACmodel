# lower bounds for age groups
age.group.lower = seq(0, 80, by = 5)

# contact parameters
contact.pars.initial = mk_contact_pars(
  age.group.lower = age.group.lower,
  setting.weight = values$setting.weight
)

transmission = (values$transmissibility)*(contact.pars.initial$c.hat)

if(scenario.name == "change-contacts"){
  contact.pars.new = mk_contact_pars(
    age.group.lower = age.group.lower,
    setting.weight = values$setting.weight.new
  )
}

# decode parameters into model flows
flow <- init_flow_vec(
  epi_names = c("progression", "recovery", "hospitalization", "discharge", "death_H", "death_I"),
  age_groups = age.group.lower
)

values$flow <- (flow 
  # outflow for E 
  |> update_flow(
    pattern = "^progression",
    value = 1/values$days_incubation
  )
  # outflows for I
  |> update_flow(
    pattern = "^recovery",
    value = (1-values$prop_hosp-1/(1/values$prop_IFR_all - 1/values$prop_IFR_hosp))*1/values$days_infectious
  )
  |> update_flow(
    pattern = "^hospitalization",
    value = values$prop_hosp*1/values$days_infectious
  )
  |> update_flow(
    pattern = "^death_I",
    value = 1/(1/values$prop_IFR_all - 1/values$prop_IFR_hosp)*1/values$days_infectious
  )
  # outflows for H
  |> update_flow(
    pattern = "^discharge",
    value = (1-values$prop_IFR_hosp)*1/values$days_hosp
  )
  |> update_flow(
    pattern = "^death_H",
    value = values$prop_IFR_hosp*1/values$days_hosp
  )
)

