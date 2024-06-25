# 1: UPDATE flows.csv FIRST BY HAND AND THEN FILL IN CORRESPONDING ATOMIC LABELS BELOW

# 2: UPDATE derivations.json BY HAND WITH NEW FULL STATE VEC IN N.x CALCULATION

# 3: IF UPDATING FLOW NAMES AND/OR PARAMETRIZATION FOR FLOWS
# --> UPDATE run-before-simulator.R BY HAND WITH NEW PARAMS (REFERRING TO ATOMIC VECS BELOW)
# --> UPDATE CODE TO REGENERATE default_values.rds BELOW

# 4: IF INSERTING EXPRESSIONS FOR NEW DERIVED QUANTITIES
# --> UPDATE derivations.json WITH NEW EXPRESSIONS
# --> ADD NEW DERIVED VARIABLES TO variables.csv
# --> PASS macpan2::empty_matrix FOR ANY NEW DERIVED VARIABLES IN model$simulators$tmb() CALL IN simulator_expression.R
# --> UPDATE INTEGER VALUE IN 
# $insert$expressions(.at = 4L) IN simulator_expression.R IN CASE ADDITION OF EXPRESSIONS TO derivations.json CHANGES LOCATION OF THIS INSERTION (FROM 4L TO SOMETHING ELSE)

# 5: RUN THIS SCRIPT TO UPDATE ALL OTHER MODEL DEFINITION FILES

model.name <- "hosp"

# atomic labels
# - - - - - - - - - - - - - - -

state <- c("S", "E", "I_R", "I_A", "I_D", "A_R", "A_CR", "A_CD", "A_D", "C_R", "C_D", "R", "D")
age <- seq(0, 80, by = 5)
flow <- c(
    "infection", 
    # progression of illness
    "progression_to_I_R", "progression_to_I_A", "progression_to_I_D",
    # leaving I_x states
    "recovery_from_I_R", 
    "death_from_I_D", 
    # entering acute care states
    "admission_to_A_R", "admission_to_A_CR",
    "admission_to_A_CD", "admission_to_A_D",
    # leaving acute care states
    "discharge_from_A_R",
    "admission_to_C_R", "admission_to_C_D", 
    "death_from_A_D",
    # leaving critical care states
    "discharge_from_C_R",
    "death_from_C_D"
)

model.path <- file.path("inst", "models", model.name)

# update to variables.csv
# - - - - - - - - - - - - - - -

epi_vec <- c(state, "N", "I", flow)
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
default_flow[grepl("^(infection|progression|recovery)", flow_vec)] <- 0.1
default_flow[grepl("^(admission_to_A)", flow_vec)] <- 0.05
default_flow[grepl("^(discharge_from_A)", flow_vec)] <- 0.01
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

# update to default_values.rds
# - - - - - - - - - - - - - - -

default_values <- readRDS(file.path(model.path, "default_values.rds"))

# update initial state
state_init <- values$Default[1:length(state_vec)]
names(state_init) <- values$Variable[1:length(state_vec)]

# construct new default values list with only what's needed for this model
default_values <- list(
    time.steps = default_values$time.steps,
    state = state_init,
    # update parameterization
    transmissibility = 0.015, # final size 80%, which maps to R0 = 2 in the heterogeneous SEIR model
    days_incubation = 6,
    days_infectious_I_R = 10,
    days_infectious_I_A = 6,
    days_infectious_I_D = 10,
    days_LOS_acute_care_to_recovery = 15,
    days_LOS_acute_care_to_critical = 10,
    days_LOS_acute_care_to_death = 15,
    days_LOS_critical_care_to_recovery = 15,
    days_LOS_critical_care_to_death = 10,
    prop_hosp = 0.05, # proportion of infections that are hospitalised
    prop_nonhosp_death = 0.1, # proportion of non-hospitalized infections that end in death
    prop_hosp_crit = 0.05, # proportion of hospitalizations that receive critical care
    prop_hosp_death = 0.01, # proportion of hospitalizations that end in death
    setting.weight = default_values$setting.weight,
    intervention.day = default_values$intervention.day,
    setting.weight.new = default_values$setting.weight.new,
    trans.factor = default_values$trans.factor
)

saveRDS(default_values, file.path(model.path, "default_values.rds"))
