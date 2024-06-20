# works for models with the same age-structure as "five-year-age-groups"

devtools::load_all()

# helper functions
source(file.path("dev", "helpers.R"))

# build model and simulate

model <- make_simulator(
  model.name = "hosp"
)

sim = model$simulate()

(sim
    |> tidy_output() 
    |> aggregate_into_age_groups()
    |> plot_output()
)
