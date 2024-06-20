# UPDATE flows.csv FIRST BY HAND AND THEN FILL IN
# CORRESPONDING ATOMIC LABELS BELOW

# UPDATE run-before-simulator.R and default_values.rds
# (BY HAND) IF UPDATING PARAMETRIZATION FOR FLOWS

# UPDATE derivations.json BY HAND WITH NEW FULL STATE VEC
# IN N.x CALCULATION

# UPDATE derivations.json IF INSERTING ANY EXPRESSIONS
# --> BE SURE TO ADD NEW DERIVED VARIABLES TO variables.csv
# --> BE SURE TO UPDATE VALUE IN 
# $insert$expressions(.at = 4L) IN simulator_expression.R
# IN CASE ADDITION OF EXPRESSIONS TO derivations.json CHANGES
# LOCATION OF THIS INSERTION (FROM 4L TO SOMETHING ELSE)

model.name <- "hosp"

# atomic labels
# - - - - - - - - - - - - - - -

state <- c("S", "E", "I_R", "I_H", "I_D", "R", "H", "D")
age <- seq(0, 80, by = 5)
flow <- c("infection", "progression_to_R", "progression_to_H", "progression_to_D", "recovery_from_R", "hospitalization", "death_from_I", "recovery_from_H", "death_from_H")

model.path <- file.path("inst", "models", model.name)

# update to variables.csv
# - - - - - - - - - - - - - - -

epi_vec <- c(state, "N", flow)
age_vec <- paste0("lb", age) 
vars_agg <- c("N", "transmission", "scaled_infected", "contact", "infection", "infected", "dummy")
variables <- rbind(
    expand.grid(Epi = epi_vec, Age = age_vec),
    data.frame(
        Epi = vars_agg,
        Age = rep("", length(vars_agg))
    )
)
write.csv(
    variables, 
    file = file.path(model.path, "variables.csv"),
    quote = FALSE, row.names = FALSE
)


# update values.csv
# - - - - - - - - - - - - - - -

# expanded labels
expand_labels <- function(v1, v2, sep){
    as.vector(outer(v1, v2, paste, sep=sep))
}
state_vec <- expand_labels(state, age, sep = ".lb")
flow_vec <- expand_labels(flow, age, sep = ".lb")

default_state <- rep(0, length(state_vec))
default_state[grepl("^S\\.", state_vec)] <- c(
    1881099, 2062572, 2126905, 2124972,
    2520278, 2703647, 2782998, 2718849,
    2573624, 2405593, 2423627, 2635125,
    2640008, 2308096, 1879942, 1381797, 
    1760770)
default_state[grepl("^E\\.", state_vec)] <- rep(1, length(age))
default_state[grepl("^I", state_vec)] <- rep(1, length(age))

default_flow <- rep(0, length(flow_vec))
default_flow[grepl("^(infection|progression|recovery)", flow_vec)] <- 0.2
default_flow[grepl("^(hospitalization)", flow_vec)] <- 0.05
default_flow[grepl("^(discharge)", flow_vec)] <- 0.1
default_flow[grepl("^(death)", flow_vec)] <- 0.001

verbose_type <- c(
    rep("initial value of state variable", length(default_state)),
    rep("per-capita flow rate", length(default_flow))
)

values <- tibble::tibble(
    Variable = c(state_vec, flow_vec),
    Default = c(default_state, default_flow),
    `Verbose Type` = verbose_type
)

write.csv(
    values, 
    file = file.path(model.path, "values.csv"),
    quote = FALSE, row.names = FALSE
)

# update settings.json
# - - - - - - - - - - - - - - -
settings <- list(
    required_partitions = c("Epi", "Age"),
    null_partition = c("Null"),
    state_variables = state_vec,
    flow_variables = flow_vec
)

jsonlite::write_json(settings, file.path(model.path, "settings.json"))

# update initial state in default_values.rds
state_init <- values$Default[1:length(state_vec)]
names(state_init) <- values$Variable[1:length(state_vec)]
default_values <- readRDS(file.path(model.path, "default_values.rds"))
default_values$state <- state_init
saveRDS(default_values, file.path(model.path, "default_values.rds"))
