# - - - - - - - - - - - - - - - - -
# Helper functions to help initialize the five-year-age-groups model
# - - - - - - - - - - - - - - - - -

# Utilities for using Mistry contact matrices
# - - - - - - - - - - - - - - - - -

#' Make contact matrix from Mistry et al. data
#'
#' @param age.group.lower (optional) Numeric vector. Lower bounds for aggregated age groups, if desired.
#' @template param_setting.weight
#' @param pop.new (optional) Numeric vector. Specifies new population sizes by age with which to renormalize contact matrices. Must match up with age groups given in `age.group.lower` (if provided) or original Mistry age groups (one year age groups up to 84, with a single age group for 85+).
#'
#' @return A list with:
#'  - `p.mat`: the row-normalized matrix of contact probabilities
#'  - `c.hat`: the vector of row sums from the contact rate matrix, giving the average contact rate per age group; used to set up the transmission vector to maintain the contact balance condition
#' @export
mk_contact_pars <- function(
    age.group.lower = NULL,
    setting.weight,
    pop.new = NULL
){
  # Arg checks
  if (!is.null(age.group.lower) & !is.null(pop.new)) {
    if (length(age.group.lower) != length(pop.new)) stop("Population sizes given in `pop.new` must be compatible with age groups requested using `age.group.lower`. Currently, the lengths of these two vectors does not match.")
  }

  if (is.null(names(setting.weight))) stop("`setting.weight` vector must be named. Names should be 'school', 'work', 'household', and 'community'.")
  
  if (any(names(setting.weight) != c("school", "work", "household", "community"))) stop("Names of `setting.weight` should be 'school', 'work', 'household', and 'community'.")
  
  # Pull population data
  pop.orig = mk_pop_table() # original population
  if(!is.null(age.group.lower)) pop.orig.age = mk_pop_table(age.group.lower) # original pops aggregated by age

  # Load component matrices (default with age groups 0, 1, ..., 83, 84+)
  setting.list = c("school", "work", "household", "community")
  c.mat.list = lapply(setting.list, function(setting){
    c.mat = as.matrix(readr::read_csv(
      system.file(
        file.path("input-data", "contact-matrices",
                  paste0("Canada_country_level_F_", setting,
                         "_setting_85.csv")),
        package = "EPACmodel"
      ),
      col_names = FALSE, show_col_types = FALSE))
    colnames(c.mat) = NULL

    # Aggregate age groups in contact matrix, if requested
    if(!is.null(age.group.lower)){
      # Multiply each row of each c.mat by corresponding age-specific population
      c.mat = c.mat * pop.orig$count # rowwise multiplication

      colnames(c.mat) = 0:84
      c.mat = (tibble::as_tibble(cbind(
        age_susceptible = 0:84,
        c.mat
      ))
      # Pivot to long form to aggregate age groups
      |> tidyr::pivot_longer(
        -age_susceptible,
        names_to = "age_infectious"
      )
      |> dplyr::mutate(dplyr::across(
        dplyr::starts_with("age"),
        \(x) as.numeric(x)
      ))
      |> dplyr::mutate(dplyr::across(
        dplyr::starts_with("age"),
        \(x) cut(x, breaks = c(age.group.lower, Inf),
                 include.lowers = TRUE, right = FALSE)
      ))
      |> dplyr::group_by(age_susceptible, age_infectious)
      |> dplyr::summarise(value = sum(value), .groups = "drop")
      # Attach new aggregated population counts and row-normalise
      |> dplyr::left_join(pop.orig.age, by = dplyr::join_by(age_susceptible == age_group))
      |> dplyr::transmute(
        age_susceptible,
        age_infectious,
        value = value/count
      )
      # Reshape back into matrix
      |> tidyr::pivot_wider(
        id_cols = age_susceptible,
        names_from = age_infectious
      )
      |> dplyr::select(-age_susceptible)
      |> as.matrix()
      )
    }

    # Strip dimnames attribute, even though it's (basically) empty because it
    # causes macpan to error
    attr(c.mat, "dimnames") = NULL

    return(c.mat)
  })

  names(c.mat.list) = setting.list

  # Sum from components weighted by setting weights
  c.mat = Reduce("+", lapply(setting.list, function(setting){
    c.mat.list[[setting]] * setting.weight[setting]
  }))

  # Population re-normalize, if desired
  if(!is.null(pop.new)){
    # get population data corresponding to current c.mat indices
    if (!is.null(age.group.lower)) pop.orig <- pop.orig.age
    # renormalize each row
    c.mat <- c.mat * pop.orig$count / pop.new
  }

  # Return row-normalized matrix, as well as original row sums (avg contacts
  # by age group)
  c.hat = rowSums(c.mat)
  return(list(
    p.mat = c.mat / c.hat,
    c.hat = c.hat
  ))
}

#' Make population table using Mistry et al. data
#'
#' @inheritParams mk_contact_pars
#'
#' @return A data frame with columns
#'  - `age`: age group
#'  - `count`: population count
mk_pop_table = function(
    age.group.lower = NULL
){
  # Flag whether any aggregation needs to be done across ages
  aggregate <- !is.null(age.group.lower)

  # Check requested age groups for compatibility with original data source
  if(aggregate){
    if(max(age.group.lower) > 84){
      stop(paste0(
        "Requested age groups are not compatible with original Mistry data.
Age group lower bounds cannot exceed 84.
Lower bounds requested were: ", age.group.lower))
    }
  }

  # Get original population data
  population = readr::read_csv(
    system.file(
      file.path("input-data", "population", "Canada_country_level_age_distribution_85.csv"),
      package = "EPACmodel"
    ),
    col_names = c("age", "count"),
    col_types = readr::cols(
      .default = readr::col_double()
    ), show_col_types = FALSE)

  # Aggregate into new age groups, if requested
  if (aggregate) {
    population <- (population
      |> dplyr::mutate(
       age_group
       = cut(age, breaks = c(age.group.lower, Inf),
             include.lowers = TRUE, right = FALSE)
      )
      |> dplyr::group_by(age_group)
      |> dplyr::summarise(count = sum(count))
    )
  }

  return(population)
}
