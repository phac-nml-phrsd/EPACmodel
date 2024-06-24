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

# decode parameters into model flows (use same rates for all ages)
flow <- init_flow_vec(
  epi_names = c("progression_to_I_R", "progression_to_I_A", "progression_to_I_D",  "admission_to_A", "death_from_I_D", "death_from_A","recovery_from_I_R", "discharge_from_A"),
  age_groups = age.group.lower
)

values$flow <- (flow 
  # progression of illness 
  |> update_flow(
    pattern = "^progression_to_I_R\\.",
    value = 1/values$days_incubation*(1-values$prop_hosp)*(1-values$prop_death_outside_hosp)
  )
  |> update_flow(
    pattern = "^progression_to_I_A\\.",
    value = 1/values$days_incubation*values$prop_hosp
  )
  |> update_flow(
    pattern = "^progression_to_I_D\\.",
    value = 1/values$days_incubation*(1-values$prop_hosp)*values$prop_death_outside_hosp
  )
  # hospitalizations
  |> update_flow(
    pattern = "^admission_to_A\\.",
    value = 1/values$days_infectious_I_A
  )
  # deaths
  |> update_flow(
    pattern = "^death_from_I_D\\.",
    value = 1/values$days_infectious_I_D
  )
  |> update_flow(
    pattern = "^death_from_A\\.",
    value = 1/values$days_LOS_acute_care_to_death
  )
  # recoveries
  |> update_flow(
    pattern = "^recovery_from_I_R\\.",
    value = 1/values$days_infectious_I_R
  )
  |> update_flow(
    pattern = "^discharge_from_A\\.",
    value = 1/values$days_LOS_acute_care_to_recovery
  )
)

