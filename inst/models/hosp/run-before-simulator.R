# make contact data, if not provided
if(is.null(values$contact.pars)){
  values$contact.pars = mk_contact_pars(
    age.group.lower = seq(0, 80, by = 5),
    setting.weight = values$setting.weight
  )
}

flow <- calculate_flow(model.name, values)
transmission <- calculate_transmission(model.name, values)

contact <- values$contact.pars$p.mat

# make contact data for scenario, if not provided
if(scenario.name == "change-contacts" & is.null(values$contact.pars.new)){
  values$contact.pars.new = mk_contact_pars(
    age.group.lower = seq(0, 80, by = 5),
    setting.weight = values$setting.weight.new
  )
}

