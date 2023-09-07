# contact parameters
contact.pars.initial = mk_contact_pars(
  age.group.lower = values$age.group.lower,
  setting.weight = values$setting.weight
)

transmission = (values$transmissibility)*(contact.pars.initial$c.hat)

if(scenario.name == "contact-intervention"){
  contact.pars.new = mk_contact_pars(
    age.group.lower = values$age.group.lower,
    setting.weight = values$setting.weight.new
  )
}
