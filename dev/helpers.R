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

aggregate_across_epi_subcats <- function(df){
  (df
    |> tidyr::separate(var, into = c("var", "var_subcat"),
                       sep = "_", extra = "merge", fill = "right")
    |> dplyr::mutate(var = forcats::as_factor(var))
    |> dplyr::group_by(time, var, age)
    |> dplyr::summarise(value = sum(value), .groups = 'drop')
  )
}

tidy_output = function(output, filter.matrix = "state"){

    if(!is.null(filter.matrix)){
    output <- (output 
      |> dplyr::filter(matrix %in% filter.matrix)
    )
  }

  output <- (output
    # parse state names
    |> tidyr::separate(
      row,
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

plot_output <- function(
  df, 
  var_colour = "age",
  var_facet_row = "var",
  var_facet_col = "",
  ylim = NULL,
  facet_scales = "free_y"
){
  facet_formula <- paste(var_facet_col, "~", var_facet_row)

  pp <- (df
   |> ggplot2::ggplot()
   + ggplot2::geom_line(ggplot2::aes(x = time, y = value, colour = !!ggplot2::sym(var_colour)),
                        linewidth = 1.25)
   + ggplot2::scale_y_continuous(
     limits = ylim,
     labels = scales::label_number(scale_cut = scales::cut_short_scale())
   )
   + ggplot2::labs(
     x = "Days since start of outbreak",
     y = "Number of individuals",
     colour = stringr::str_to_sentence(gsub("_", " ", var_colour))
   )
   + ggplot2::theme_bw(
     base_size = 16
   )
   + ggplot2::theme(
     axis.title.y = ggplot2::element_blank(),
     legend.position = "top",
     legend.background = ggplot2::element_rect(fill = NA),
     legend.title = ggplot2::element_blank()
   )
  )

  if(nchar(facet_formula)>3) {
    pp <- pp + ggplot2::facet_wrap(as.formula(facet_formula), scales = facet_scales)
  }

  pp
}

get_total <- function(df, state, time){
  dplyr::filter(df, var == state, time == !!time) |> dplyr::summarise(value = sum(value)) |> dplyr::pull(value)
}

final_size <- function(R0){
  Z <- round((1 + 1/R0*LambertW::W(-R0*exp(-R0)))*100)
  print(paste0("theoretical final size: ", Z, "%"))
}

report_final_size <- function(df){
  inf <- max(df$time)
  S_0 <- df |> get_total("S", 0)
  R_inf <- df |> get_total("R", inf)
  D_inf <- df |> get_total("D", inf)
  print(paste0("actual final size: ", round((R_inf+D_inf)/S_0*100), "%"))
}
