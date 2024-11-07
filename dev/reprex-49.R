# reprex for #49

devtools::load_all()

model.name <- "hosp"
simulator <- make_simulator(model.name)

sim.default <- simulate(simulator) # default values

# adding new contact.pars

values.default <- get_default_values(model.name)
values <- c(
    values.default,
    list(
        pop = rep(3e5, 17)
    )
)
sim.newpars <- simulate(simulator, values = values)

waldo::compare(sim.default, sim.newpars) # no differences, change to contact.pars not caught

# what about changing a different value?

values$transmissibility <- 0.01
sim.newpars2 <- simulate(simulator, values = values)
waldo::compare(sim.default, sim.newpars2) # lots of differences so change to transmissibility caught
