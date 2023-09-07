if(scenario.name == "change-contacts"){
  model_simulator$add$matrices(
    contact_changepoints = c(0, values$intervention.day)
    # need to have "changepoint" for initial set of pars at t = 0
    , contact_pointer = 0
    , contact_values = rbind(contact.pars.initial$p.mat,
                             contact.pars.new$p.mat)
    , transmission_values = cbind(
      values$transmissibility*contact.pars.initial$c.hat,
      values$trans.factor*values$transmissibility*contact.pars.new$c.hat
    )
    , n.age.group = length(values$age.group.lower)
    , .mats_to_save = c("contact.", "transmission.")
    , .mats_to_return = c("contact.", "transmission.")
  )$insert$expressions(
    contact_pointer ~ time_group(contact_pointer, contact_changepoints)
    , contact. ~ block(contact_values, n.age.group * contact_pointer,
                       0, n.age.group, n.age.group)
    , transmission. ~ block(transmission_values,
                            0, contact_pointer,
                            n.age.group, 1)
    , .phase = "during"
  )
}
