# For calculating macpan matrices from
# epi parameters
# - - - - - - - - - - - - - -

# mats to make/update
# - state (leave for last?)
# - contact
# - time steps?

calculate_transmission_hosp <- function(values, contact.pars = NULL){
    if(is.null(contact.pars)){
        contact.pars <- mk_contact_pars(
            age.group.lower = seq(0, 80, by = 5),
            setting.weight = values$setting.weight
        )
    }

    (values$transmissibility)*(contact.pars$c.hat)
}

calculate_flow_hosp <- function(values){
    flow <- init_flow_vec(
        epi_names = c(
            "progression_to_I_R", "progression_to_I_A", "progression_to_I_D", 
            "recovery_from_I_R", 
            "death_from_I_D", 
            "admission_to_A_R", "admission_to_A_CR",
            "admission_to_A_CD", "admission_to_A_D", 
            "discharge_from_A_R",
            "admission_to_C_R", "admission_to_C_D", 
            "death_from_A_D",
            "discharge_from_C_R",
            "death_from_C_D"
        ),
        age_groups = seq(0, 80, by = 5)
    )

    (flow 
        # progression of illness 
        |> update_flows_progression(
            values$days_incubation, values$prop_hosp, values$prop_nonhosp_death
        )
        # leaving I_x states
        |> update_flow(
            pattern = "^recovery_from_I_R\\.",
            value = hosp_recovery_from_I_R(values$days_infectious_I_R)
        )
        |> update_flow(
            pattern = "^death_from_I_D\\.",
            value = hosp_recovery_from_I_D(values$days_infectious_I_D)
        )
        # entering acute care states
        |> update_flows_admission_to_A(values$days_infectious_I_A, values$prop_hosp_crit, values$prop_hosp_death)
        # leaving acute care states
        |> update_flow(
            pattern = "^discharge_from_A_R\\.",
            value = hosp_discharge_from_A_R(values$days_LOS_acute_care_to_recovery)
        )
        |> update_flow(
            pattern = "^admission_to_C_R\\.",
            value = hosp_admission_to_C_R(values$days_LOS_acute_care_to_critical)
        )
        |> update_flow(
            pattern = "^admission_to_C_D\\.",
            value = hosp_admission_to_C_D(values$days_LOS_acute_care_to_critical)
        )
        |> update_flow(
            pattern = "^death_from_A_D\\.",
            value = hosp_death_from_A_D(values$days_LOS_acute_care_to_death)
        )
        # leaving critical care states
        |> update_flow(
            pattern = "^discharge_from_C_R\\.",
            value = hosp_discharge_from_C_R(values$days_LOS_critical_care_to_recovery)
        )
        |> update_flow(
            pattern = "^death_from_C_D\\.",
            value = hosp_death_from_C_D(values$days_LOS_critical_care_to_death)
        )
    )
}

# Formulas for calculating flows

# flows as a group

update_flows_progression <- function(flow, days_incubation, prop_hosp, prop_nonhosp_death, age_suffix = ""){
    (flow
        |> update_flow(
            pattern = paste0("^progression_to_I_R\\.", age_suffix),
            value = hosp_progression_to_I_R(days_incubation, prop_hosp, prop_nonhosp_death)
        )
        |> update_flow(
            pattern = paste0("^progression_to_I_A\\.", age_suffix),
            value = hosp_progression_to_I_A(days_incubation, prop_hosp)
        )
        |> update_flow(
            pattern = paste0("^progression_to_I_D\\.", age_suffix),
            value = hosp_progression_to_I_D(days_incubation, prop_hosp, prop_nonhosp_death)
        )
    )
}

update_flows_admission_to_A <- function(flow, days_infectious_I_A, prop_hosp_crit, prop_hosp_death, age_suffix = ""){
    (flow
        |> update_flow(
            pattern = paste0("^admission_to_A_R\\.", age_suffix),
            value = hosp_admission_to_A_R(days_infectious_I_A, prop_hosp_crit, prop_hosp_death)
        )
        |> update_flow(
            pattern = paste0("^admission_to_A_CR\\.", age_suffix),
            value = hosp_admission_to_A_CR(days_infectious_I_A, prop_hosp_crit, prop_hosp_death)
        )
        |> update_flow(
            pattern = paste0("^admission_to_A_CD\\.", age_suffix),
            value = hosp_admission_to_A_CD(days_infectious_I_A, prop_hosp_crit, prop_hosp_death)
        )
        |> update_flow(
            pattern = paste0("^admission_to_A_D\\.", age_suffix),
            value = hosp_admission_to_A_D(days_infectious_I_A, prop_hosp_crit, prop_hosp_death)
        )
    )
}

# individual flows

hosp_progression_to_I_R <- function(days_incubation, prop_hosp, prop_nonhosp_death){
    1/days_incubation*(1-prop_hosp)*(1-prop_nonhosp_death)
}

hosp_progression_to_I_A <- function(days_incubation, prop_hosp){
    1/days_incubation*prop_hosp
}

hosp_progression_to_I_D <- function(days_incubation, prop_hosp, prop_nonhosp_death){
    1/days_incubation*(1-prop_hosp)*prop_nonhosp_death
}

hosp_recovery_from_I_R <- function(days_infectious_I_R){
    1/days_infectious_I_R
}

hosp_recovery_from_I_D <- function(days_infectious_I_D){
    1/days_infectious_I_D
}

hosp_admission_to_A_R <- function(days_infectious_I_A, prop_hosp_crit, prop_hosp_death){
    1/days_infectious_I_A*(1-prop_hosp_crit)*(1-prop_hosp_death)
}

hosp_admission_to_A_CR <- function(days_infectious_I_A, prop_hosp_crit, prop_hosp_death){
    1/days_infectious_I_A*(prop_hosp_crit)*(1-prop_hosp_death)
}

hosp_admission_to_A_CD <- function(days_infectious_I_A, prop_hosp_crit, prop_hosp_death){
    1/days_infectious_I_A*(prop_hosp_crit)*(prop_hosp_death)
}

hosp_admission_to_A_D <- function(days_infectious_I_A, prop_hosp_crit, prop_hosp_death){
    1/days_infectious_I_A*(1-prop_hosp_crit)*(prop_hosp_death)
}

hosp_discharge_from_A_R <- function(days_LOS_acute_care_to_recovery){
    1/days_LOS_acute_care_to_recovery
}

hosp_admission_to_C_R <- function(days_LOS_acute_care_to_critical){
    1/days_LOS_acute_care_to_critical
}

hosp_admission_to_C_D <- function(days_LOS_acute_care_to_critical){
    1/days_LOS_acute_care_to_critical
}

hosp_death_from_A_D <- function(days_LOS_acute_care_to_death){
    1/days_LOS_acute_care_to_death
}

hosp_discharge_from_C_R <- function(days_LOS_critical_care_to_recovery){
    1/days_LOS_critical_care_to_recovery
}

hosp_death_from_C_D <- function(days_LOS_critical_care_to_death){
    1/days_LOS_critical_care_to_death
}

# For updating values in a simulator
# - - - - - - - - - - - - - -

# to set the simulator up
add_to_pf <- function(pf, matrix.name, matrix){

    if("matrix" %in% class(matrix)){
        # matrices
        row <- 0:(nrow(matrix)-1)
        col <- 0:(ncol(matrix)-1)
        pf_new <- cbind(
            expand.grid(
                mat = matrix.name,
                row = row,
                col = col
            ),
            default = c(matrix) # unwraps column-wise, which matches how expand.grid expands out the row and column indices
        )
    } else {
        # vectors
        if(is.null(names(matrix))){
            row <- seq_along(matrix)-1
        } else {
            row <- names(matrix)
        }

        pf_new <- data.frame(
            mat = rep(matrix.name, length(matrix)),
            row = row,
            col = rep(0, length(matrix)),
            default = unname(matrix)
        )
    }

    rbind(pf, pf_new)
}

# to make the parameter vec to pass to the simulator
make_pvec <- function(values){
    contact.pars <- mk_contact_pars(
        age.group.lower = seq(0, 80, by = 5),
        setting.weight = values$setting.weight
    )
    
    # allow user to pass flow directly and avoid recalculation from
    # epi parameters (_e.g._ if tailoring certain params by age)
    if("flow" %in% names(values)){
        warning("ignoring epi parameters for flows in `values` and using `values$flow` directly")
        flow <- values$flow
    } else {
        flow <- unname(calculate_flow_hosp(values))
    }

    # the order of this output
    # must match order of params in 
    # `pf` initialized in run_after_simulator.R!
    c(
        # state
        values$state,
        # flows
        flow,
        # transmission. matrix
        calculate_transmission_hosp(values, contact.pars = contact.pars),
        # contact. matrix
        c(contact.pars$p.mat)
    )
}

