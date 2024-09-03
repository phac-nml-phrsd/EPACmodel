# Utilities for decoding parameters into model inputs
# - - - - - - - - - - - - - - - - -

calculate_transmission <- function(model.name, values, ...){
  if(model.name != "hosp") stop("calculate_transmission is currently only implemented for the `hosp` model")

  calculate_transmission_hosp(values, ...)
}

# Generic function to calculate flow for various models
calculate_flow <- function(model.name, values){
  if(model.name != "hosp") stop("calculate_flow is currently only implemented for the `hosp` model")

  calculate_flow_hosp(values)
}

# initialize flow vector with expanded names
init_flow_vec <- function(
  epi_names, age_groups
){

  name_combos <- expand.grid(epi_names, age_groups)
  flow_names <- sprintf('%s.lb%s', name_combos[,1], name_combos[,2])

  flow_vec <- rep(0, length(flow_names))
  names(flow_vec) <- flow_names

  flow_vec
}

# update flow vector using pattern based on names
update_flow <- function(flow, pattern, value){
  indx <- grepl(pattern, names(flow))
  flow[indx] <- value
  return(flow)
}