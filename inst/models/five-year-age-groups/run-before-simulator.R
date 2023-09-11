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
