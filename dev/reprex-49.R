# reprex for #49

devtools::load_all()

model.name <- "hosp"
simulator <- make_simulator(model.name)

sim.default <- simulate(simulator) # default values

# adding new contact.pars

values.default <- get_default_values(model.name)
values <- values.default
values$pop <- rep(3e5, 17)
values$contact.pars <- mk_contact_pars(age.group.lower = seq(0,80,5), setting.weight = values$setting.weight, pop.new = values$pop)
sim.newpars <- simulate(simulator, values = values)

waldo::compare(sim.default, sim.newpars) # differences now!

# what about changing a different value?

values$transmissibility <- 0.01
sim.newpars2 <- simulate(simulator, values = values)
waldo::compare(sim.default, sim.newpars2) # lots of differences so change to transmissibility caught

# what about updating values when simulator is built?
simulator2 <- make_simulator(model.name, values = values)
sim.newpars2 <- simulate(simulator2)
waldo::compare(sim.default, sim.newpars2) # should be diff; is
waldo::compare(sim.newpars, sim.newpars2) # should be the same; is
