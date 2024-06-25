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
  epi_names = c(
    "progression_to_I_R", "progression_to_I_A", "progression_to_I_D", 
    "recovery_from_I_R", 
    "death_from_I_D", 
    "admission_to_A_R", "admission_to_A_CR",
    "admission_to_A_CD", "admission_to_A_D", 
    "discharge_from_A_R",
    "admission_to_C_R", "admission_to_C_D", 
    "death_from_A_D",
    "discharge_from_C_R",
    "death_from_C_D"
  ),
  age_groups = age.group.lower
)

values$flow <- (flow 
  # progression of illness 
  |> update_flow(
    pattern = "^progression_to_I_R\\.",
    value = 1/values$days_incubation*(1-values$prop_hosp)*(1-values$prop_nonhosp_death)
  )
  |> update_flow(
    pattern = "^progression_to_I_A\\.",
    value = 1/values$days_incubation*values$prop_hosp
  )
  |> update_flow(
    pattern = "^progression_to_I_D\\.",
    value = 1/values$days_incubation*(1-values$prop_hosp)*values$prop_nonhosp_death
  )
  # leaving I_x states
  |> update_flow(
    pattern = "^recovery_from_I_R\\.",
    value = 1/values$days_infectious_I_R
  )
  |> update_flow(
    pattern = "^death_from_I_D\\.",
    value = 1/values$days_infectious_I_D
  )
  # entering acute care states
  |> update_flow(
    pattern = "^admission_to_A_R\\.",
    value = 1/values$days_infectious_I_A*(1-values$prop_hosp_crit)*(1-values$prop_hosp_death)
  )
  |> update_flow(
    pattern = "^admission_to_A_CR\\.",
    value = 1/values$days_infectious_I_A*(values$prop_hosp_crit)*(1-values$prop_hosp_death)
  )
  |> update_flow(
    pattern = "^admission_to_A_CD\\.",
    value = 1/values$days_infectious_I_A*(values$prop_hosp_crit)*(values$prop_hosp_death)
  )
  |> update_flow(
    pattern = "^admission_to_A_D\\.",
    value = 1/values$days_infectious_I_A*(1-values$prop_hosp_crit)*(values$prop_hosp_death)
  )
  # leaving acute care states
  |> update_flow(
    pattern = "^discharge_from_A_R\\.",
    value = 1/values$days_LOS_acute_care_to_recovery
  )
  |> update_flow(
    pattern = "^admission_to_C_R\\.",
    value = 1/values$days_LOS_acute_care_to_critical
  )
  |> update_flow(
    pattern = "^admission_to_C_D\\.",
    value = 1/values$days_LOS_acute_care_to_critical
  )
  |> update_flow(
    pattern = "^death_from_A_D\\.",
    value = 1/values$days_LOS_acute_care_to_death
  )
  # leaving critical care states
  |> update_flow(
    pattern = "^discharge_from_C_R\\.",
    value = 1/values$days_LOS_critical_care_to_recovery
  )
  |> update_flow(
    pattern = "^death_from_C_D\\.",
    value = 1/values$days_LOS_critical_care_to_death
  )
)

