
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EPAC model

<!-- badges: start -->
<!-- badges: end -->

This package implements the Early Pandemic Age-Structured Compartmental
(EPAC) model developed by [@wzmli](https://github.com/wzmli) and
[@papsti](https://github.com/papsti) at
[@phac-nml-phrsd](https://github.com/phac-nml-phrsd) using
[`macpan2`](https://github.com/canmod/macpan2) modelling software.
**This package is still in development.**

The goal of this package is to document the models being used under this
framework. It is more a software record rather than a package to help
one run the model.

## Installation

You can install the development version of EPACmodel like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Getting started

``` r
library(EPACmodel)
#> 
#> Attaching package: 'EPACmodel'
#> The following object is masked from 'package:stats':
#> 
#>     simulate
```

### Set up model simulator

To work with a model, we need to load its simulator. A simulator in
`macpan2` is an object that includes model structure (state names,
flows, etc.) along with parameter values and initial states.

This package includes several models whose simulators can quickly and
easily be retrieved. Available models include:

``` r
list_models()
#> [1] "two-age-groups"               "two-age-groups_interventions"
```

To get this model’s simulator, we simply call:

``` r
model_name <- "two-age-groups"
model_simulator <- make_simulator(
  model_name = model_name
)
```

By default, `make_simulator()` will attach a set of default parameters
and initial states to the model structure. It will also set a default
number of time steps. Any of these can be changed by passing additional,
optional, arguments to `make_simulator()`. We recommend first loading
the default parameters and/or states, and then editing the values in
these lists in-session, to ensure the format of each object is
compatible with the model definition and `macpan2`:

``` r
default_params = get_params(model_name)
print("default params:")
#> [1] "default params:"
print(default_params)
#>    transmission_y       infection_y     progression_y        recovery_y 
#>              1.50              0.20              0.20              0.10 
#> hospitalization_y       discharge_y          deathH_y          deathI_y 
#>              0.10              0.10              0.01              0.01 
#>    transmission_o       infection_o     progression_o        recovery_o 
#>              1.50              0.20              0.20              0.10 
#> hospitalization_o       discharge_o          deathH_o          deathI_o 
#>              0.10              0.10              0.01              0.01 
#>              c_yy              c_yo              c_oy              c_oo 
#>              0.80              0.20              0.20              0.80

default_state = get_state(model_name)
print("default state:")
#> [1] "default state:"
print(default_state)
#>      S_y      R_y      E_y      I_y      H_y      D_y      S_o      R_o 
#> 31400000        0        1        1        0        0  6900000        0 
#>      E_o      I_o      H_o      D_o 
#>        1        1        0        0

# move some young susceptibles to the recovered class
new_state = default_state
new_state["R_y"] = 1000
new_state["S_y"] = default_state["S_y"] - new_state["R_y"]
print("new state:")
#> [1] "new state:"
print(new_state)
#>      S_y      R_y      E_y      I_y      H_y      D_y      S_o      R_o 
#> 31399000     1000        1        1        0        0  6900000        0 
#>      E_o      I_o      H_o      D_o 
#>        1        1        0        0
```

Then you can pass the modified params and/or state to
`make_simulator()`:

``` r
new_model_simulator = make_simulator(
  model_name = model_name,
  state = new_state,
  time_steps = 200
)
```

### Simulate base model

To run the simulation:

``` r
sim_output = simulate(model_simulator)
```

This output will include the value of each state at the given time
(`value_type == 'state')`:

``` r
(sim_output
 |> dplyr::filter(value_type == 'state', time == 10)
 |> head()
)
#>   time state_name value_type        value
#> 1   10        S_y      state 3.139988e+07
#> 2   10        E_y      state 7.888172e+01
#> 3   10        I_y      state 2.644023e+01
#> 4   10        H_y      state 5.068467e+00
#> 5   10        R_y      state 7.329988e+00
#> 6   10        D_y      state 7.329988e-01
```

as well as the inflow into each compartment at a given time
(`value_type == 'total_inflow')`, so that one could look at incidence,
for instance:

``` r
(sim_output
 |> dplyr::filter(value_type == 'total_inflow', time == 10)
 |> head()
)
#>   time state_name   value_type      value
#> 1   10        S_y total_inflow  0.0000000
#> 2   10        R_y total_inflow 33.1027030
#> 3   10        E_y total_inflow 11.4447547
#> 4   10        I_y total_inflow  1.8981620
#> 5   10        H_y total_inflow  2.2543761
#> 6   10        D_y total_inflow  0.2254376
```

We can plot the results using standard data manipulation and plotting
tools:

``` r
plot_output <- function(output){
  (output
 # parse state names
 |> dplyr::mutate(
   epi_state = gsub("_(y|o)", "", state_name),
   age = ifelse(grepl("_y", state_name),"young","old")
 )
 |> dplyr::filter(value_type == 'total_inflow', epi_state == 'I')
 |> ggplot2::ggplot()
 + ggplot2::geom_line(ggplot2::aes(x = time, y = value, colour = age),
                      linewidth = 1.25)
 + ggplot2::scale_y_continuous(
   labels = scales::label_number(scale_cut = scales::cut_short_scale())
 )
 + ggplot2::labs(
   x = "day",
   title = "Incidence over time by age group"
 )
 + ggplot2::theme_bw()
 + ggplot2::theme(
   axis.title.y = ggplot2::element_blank(),
   legend.position = c(1,1),
   legend.justification = c(1,1),
   legend.background = ggplot2::element_rect(fill = NA)
  )
)
}
```

``` r
plot_output(sim_output)
```

<img src="man/figures/README-sim-output-1-1.png" width="100%" />

### Model with interventions

Here is the base model with interventions to reduce the transmission
rate twice over the course of the simulation:

``` r
# simulate and create base plot
p <- ("two-age-groups_interventions"
  |> make_simulator()
  |> simulate()
  |> plot_output()
)

# annotate base plot with intervention timing
interventions <- data.frame(
  time = c(40, 50),
  y = 2.5e5,
  label = "intervention implemented"
)

(p
  + geom_vline(
    data = interventions,
    mapping = aes(xintercept = time),
    linetype = "dashed"
  )
  + geom_text(
    data = interventions,
    mapping = aes(x = time - 1, y = y, label = label),
    angle = 90,
    vjust = "inward"
  )
)
```

## Available models

### “two-age-group” model

This version of the model features a basic epidemiological structure
stratified with two age groups: young and old. The epidemiological
compartments are:

- $S$: susceptible
- $E$: exposed
- $I$: infected
- $H$: hospitalized
- $R$: recovered
- $D$: dead

The flows within each age group are as follows:

![](man/figures/README-two-age-groups_flow-diagram.png)

<img src="README-figs/flow-diagram.png" width="100%" />

The solid lines indicate flows between compartments and the dashed lines
indicate when a compartment is involved in calculating a flow rate.

### “two-age-group_interventions” model

This version of the model builds on the “two-age-group” model by
incorporating two time-based interventions that reduce the transmission
rate. The reductions occur on time steps 40 and 50 of the simulation,
and reduce the transmission rate by 50% and 30% of its original value,
respectively.
