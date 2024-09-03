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
