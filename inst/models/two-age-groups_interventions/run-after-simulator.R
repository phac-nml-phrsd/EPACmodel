# modifications to the base model to incorporate time-varying, age-based interventions

trans_times <- c(0,40,50) # time of interventions
transval_o <- model_simulator$get$initial("transmission_o")[1,1]
transfactors_o <- c(1,0.5,0.3) # multiple of transmission rate for old

transvec_o <- transval_o*transfactors_o

transval_y <- model_simulator$get$initial("transmission_y")[1,1]
transfactors_y <- c(1,0.5,0.3) # multiple of transmission rate for young

transvec_y <- transval_y*transfactors_y

model_simulator$add$matrices(transmission_o_changepoints = trans_times)
model_simulator$add$matrices(transmission_y_changepoints = trans_times)

model_simulator$add$matrices(transmission_y_values = transvec_y)
model_simulator$add$matrices(transmission_o_values = transvec_o)

model_simulator$add$matrices(transmission_y_pointer = 0)
model_simulator$add$matrices(transmission_o_pointer = 0)

model_simulator$insert$expressions(
  transmission_y_pointer ~ time_group(transmission_y_pointer, transmission_y_changepoints)
  , transmission_o_pointer ~ time_group(transmission_o_pointer, transmission_o_changepoints)
  , .phase = "during"
)

model_simulator$insert$expressions(
  transmission_y ~ transmission_y_values[transmission_y_pointer]
  , transmission_o ~ transmission_o_values[transmission_o_pointer]
  , .phase = "during"
)
