# works for models with the same age-structure as "five-year-age-groups"

# helper functions
source(file.path("dev", "helpers.R"))

# re-load model files
devtools::load_all()

# build model and simulate
transmissibility <- 0.015 # corresponds to final size = 80%, which maps to R0 = 2 using the formula for SEIR
transmissibility <- 0.03 # corresponds to final size = 98%, which maps to R0 = 4 using the formula for SEIR
model <- make_simulator(
  model.name = "hosp",
  updated.values = list(
    time.steps = 450
    # , transmissibility = transmissibility
  )
)

sim = model$simulate()

df <- (sim
    |> tidy_output() 
    |> aggregate_into_age_groups()
)

plot_output(df)

# other inspection
final_size(4)
report_final_size(df)
