# works for models with the same age-structure as "five-year-age-groups"

model.name = "hosp"

# helper functions
source(file.path("dev", "helpers.R"))

# re-load model files
devtools::load_all()

# build model and simulate
model <- make_simulator(
  model.name = model.name,
  values = list(
    time.steps = 450
  )
)

# simulate with default values
sim1 = simulate(model)

# play with updating values
values = get_default_values(model.name)

# update transmissibility
# values$transmissibility <- 0.03

# update contact matrix
setting.weight <- values$setting.weight
setting.weight[["school"]] <- 0 # school closure
values$setting.weight <- setting.weight

# update initial state
state <- values$state
susc.indx <- grepl("^S\\.",names(state))
state[susc.indx] <- round(state[susc.indx]/2)
values$state <- state
sim2 = simulate(model, values)

df1 <- (sim1
  |> tidy_output() 
  |> aggregate_across_age_groups()
  |> aggregate_across_epi_subcats()
)
plot_output(df1)

df2 <- (sim2
  |> tidy_output() 
  |> aggregate_across_age_groups()
  |> aggregate_across_epi_subcats()
)
plot_output(df2)

# other inspection
final_size(2)
report_final_size(df1)
final_size(4)
report_final_size(df2)
