contact.pars = mk_contact_pars(
  age.group.lower = seq(0, 80, by = 5),
  setting.weight = values$setting.weight
)

flow <- calculate_flow(model.name, values)

transmission = calculate_transmission(
  model.name, values, 
  contact.pars = contact.pars
)

contact = contact.pars$p.mat

if(scenario.name == "change-contacts"){
  contact.pars.new = mk_contact_pars(
    age.group.lower = seq(0, 80, by = 5),
    setting.weight = values$setting.weight.new
  )
}

