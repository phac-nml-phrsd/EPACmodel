# For calculating macpan matrices from
# epi parameters
# - - - - - - - - - - - - - -

# mats to make/update
# - state (leave for last?)
# - contact
# - stuff for change-contacts

calculate_transmission_hosp <- function(values){
    (values$transmissibility)*(values$contact.pars$c.hat)
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

hosp_death_from_C_D <- function(days_LOS_critical_care_to_death) {
    1 / days_LOS_critical_care_to_death
}

calculate_contact_changepoints <- function(values){
    c(0, values$intervention.day)
}

calculate_contact_values <- function(values){
    rbind(values$contact.pars$p.mat, values$contact.pars.new$p.mat)
}

calculate_transmission_values <- function(values){
  cbind(
    values$transmissibility*values$contact.pars$c.hat,
    values$trans.factor*values$transmissibility*values$contact.pars.new$c.hat
  )
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

# to make the largest possible parameter vec to pass to the simulator
# including all pars, like the change-contacts scenario 
# (even if it's not present, will filter down later)
make_pvec <- function(values, mats){

    # recalculate contact parameters
    values$contact.pars <- mk_contact_pars(
        age.group.lower = seq(0, 80, by = 5),
        setting.weight = values$setting.weight,
        pop.new = values$pop
    )
    
    # allow user to pass flow directly and avoid recalculation from
    # epi parameters (_e.g._ if tailoring certain params by age)
    if ("flow" %in% names(values)) {
        warning("ignoring epi parameters for flows in `values` and using `values$flow` directly")
        flow <- values$flow
    } else {
        # recalculate flow
        flow <- unname(calculate_flow_hosp(values))
    }

    # **vector** with updated parameter values
    # ORDER MATTERS: the order of entries in this vector
    # must match order of params in `pf` initialized in run_after_simulator.R!
    # this will also be the order of entries in
    # simulator$current$params_frame()
    out <- c(
        # state
        unname(values$state),
        # flows
        flow,
        # transmission. matrix
        calculate_transmission_hosp(values),
        # contact. matrix
        c(values$contact.pars$p.mat)
    )

    # if "contact_changepoints" is in mats
    # this model has parameters for the change-contacts scenario
    # in its parameters frame, so we should refresh
    # and attach these values as well (otherwise we will have the wrong length in our pvec)

    if("contact_changepoints" %in% mats){
        # recalculate new contact parameters
        values$contact.pars.new <- mk_contact_pars(
            age.group.lower = seq(0, 80, by = 5),
            setting.weight = values$setting.weight.new,
            pop.new = values$pop
        )

        out <- c(
            out,
            calculate_contact_changepoints(values),
            c(calculate_contact_values(values)),
            c(calculate_transmission_values(values))
        )
    }

    out
}

# For plotting and parsing
# - - - - - - - - - - - - - -

#' Aggregate simulation results into age groups
#'
#' @param df simulation output, data frame with columns `scenario`, `time`, `var`, `age`, and `value`, where `age` gives the lower bound of the original five-year age groups
#' @param breaks lower bounds for new (aggregated) age groups
#'
#' @return data frame with new aggregated `age_group` column
aggregate_across_age_groups = function(df, breaks = c(20, 60)){
  if(!all(breaks %in% seq(0, 80, by = 5))) stop("age breaks must be multiples of 5 between 0 and 80 (inclusive)")

  # pad if necessary
  if(!(0 %in% breaks)) breaks = c(0, breaks)

  # order from smallest to largest
  breaks = sort(breaks)

  age_group_labels = paste0(breaks, dplyr::lead(paste0("-", as.character(breaks-1)), default = "+"))

  (df
    |> dplyr::mutate(age = as.numeric(age))
    |> dplyr::arrange(age) # to ensure lookup that gets joined below
    # is created with the right matches of (cut) age to age group label
    |> dplyr::mutate(
      age = cut(age,
                breaks = breaks,
                right = FALSE, include.lowest = TRUE)
    )
    |> (\(x) {dplyr::left_join(x, tibble::tibble(
      age = unique(x$age),
      age_group = age_group_labels
    ),
    by = dplyr::join_by(age))})()
    |> dplyr::transmute(
      time,
      var,
      age = age_group,
      value
    )
    |> dplyr::mutate(age = forcats::as_factor(age))
    |> dplyr::group_by(
      time, var, age
    )
    |> dplyr::summarise(value = sum(value), .groups = "drop")
  )
}

#' Aggregate simulation results into overall epi categories
#'
#' @param df simulation output, data frame with columns `scenario`, `time`, `var`, `age`, and `value`, where `age` gives the lower bound of the original five-year age groups
#'
#' @return data frame with values aggregated across epidemiological subcategories
aggregate_across_epi_subcats <- function(df) {
    (df
    |> tidyr::separate(var,
            into = c("var", "var_subcat"),
            sep = "_", extra = "merge", fill = "right"
        )
        |> dplyr::mutate(var = forcats::as_factor(var))
        |> dplyr::group_by(time, var, age)
        |> dplyr::summarise(value = sum(value), .groups = "drop")
    )
}

#' Aggregate simulation results into overall epi categories
#'
#' @param output simulation output from [simulate()]
#' @param value_type value type to keep in tidied output
#'
#' @return data frame with values aggregated across epidemiological subcategories
tidy_output = function(output, value_type = "state") {
    if (!is.null(value_type)) {
        output <- (output
        |> dplyr::filter(value_type %in% !!value_type)
        )
    }

    output <- (output
    # parse state names
    |> tidyr::separate(
            state_name,
            into = c("var", "age"),
            sep = ".lb"
        )
        # enforce order of states
        |> dplyr::mutate(
            var = forcats::as_factor(var)
        )
    )

    output
}

#' Plot tidied simulation output
#'
#' @param output tidied simulation output from [tidy_output()]
#' @param var_colour variable name for the colour aesthetic
#' @param var_facet_row variable name for facet rows
#' @param var_facet_col variable name for facet columns
#' @param ylim y-axis limits
#' @param facet_scales scales for facets (input into `scales` argument of [ggplot2::facet_wrap()])
#'
#' @return a [ggplot2::ggplot] object
plot_output <- function(
    df,
    var_colour = "age",
    var_facet_row = "var",
    var_facet_col = "",
    ylim = NULL,
    facet_scales = "free_y") {
    facet_formula <- paste(var_facet_col, "~", var_facet_row)

    pp <- (df
    |> ggplot2::ggplot()
        +
        ggplot2::geom_line(ggplot2::aes(x = time, y = value, colour = !!ggplot2::sym(var_colour)),
            linewidth = 1.25
        )
        # bugged for some examples
        # Error in break_suffix[bad_break][improved_break & !power10_break] <- names(lower_break[improved_break &  :
        # NAs are not allowed in subscripted assignments
        #  + ggplot2::scale_y_continuous(
        #  limits = ylim,
        #  labels = scales::label_number(scale_cut = scales::cut_short_scale())
        #  )
        +
        ggplot2::labs(
            x = "Days since start of outbreak",
            y = "Number of individuals",
            colour = stringr::str_to_sentence(gsub("_", " ", var_colour))
        )
        +
        ggplot2::theme_bw(
            base_size = 16
        )
        +
        ggplot2::theme(
            axis.title.y = ggplot2::element_blank(),
            legend.position = "top",
            legend.background = ggplot2::element_rect(fill = NA),
            legend.title = ggplot2::element_blank()
        )
    )

    if (nchar(facet_formula) > 3) {
        pp <- pp + ggplot2::facet_wrap(as.formula(facet_formula), scales = facet_scales)
    }

    pp
}
