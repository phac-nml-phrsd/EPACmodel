# works for models with the same age-structure as "five-year-age-groups"

# helper functions
source(file.path("dev", "helpers.R"))

# re-load model files
devtools::load_all()

# build model and simulate
model <- make_simulator(
  model.name = "hosp"
)

sim = model$simulate()

(sim
    # |> dplyr::filter(time < 30)
    |> tidy_output() 
    |> aggregate_into_age_groups()
    |> plot_output()
)
