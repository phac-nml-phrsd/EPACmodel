contact.pars = mk_contact_pars(
  age.group.lower = seq(0, 80, by = 5),
  setting.weight = values$setting.weight
)

contact = contact.pars$p.mat

transmission = calculate_transmission(
  model.name, values, 
  contact.pars = contact.pars
)

flow <- calculate_flow(model.name, values)

if(scenario.name == "change-contacts"){
  contact.pars.new = mk_contact_pars(
    age.group.lower = seq(0, 80, by = 5),
    setting.weight = values$setting.weight.new
  )
}

