
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EPAC model

<!-- badges: start -->
<!-- badges: end -->

This package implements the Early Pandemic Age-Structured Compartmental
(EPAC) model developed by [@wzmli](https://github.com/wzmli) and
[@papsti](https://github.com/papsti) at
[@phac-nml-phrsd](https://github.com/phac-nml-phrsd) using
[`macpan2`](https://github.com/canmod/macpan2) modelling software.

The goal of this package is to document the iterations of this model, so
that they can be pulled into project-specific pipelines to produce
modelling outputs.

## Installation

You can install the development version of `EPACmodel` like so:

``` r
remotes::install_github("papsti/EPACmodel")
```

## Getting started guide

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
`macpan2` is an object that includes model structure (state names, flow
expressions, etc.) along with a set of variable values (such as
components of flow rates, initial states).

This package includes several models whose simulators can quickly and
easily be retrieved. Available models include:

``` r
list_models()
#> [1] "five-year-age-groups" "two-age-groups"
```

To get this model’s simulator, we simply call:

``` r
model.name <- "two-age-groups"
model_simulator <- make_simulator(
  model.name = model.name
)
```

By default, `make_simulator()` will attach a set of default values for
variables in the model (components of flow rates, initial states, etc.)
to the model structure. It will also set a default number of time steps.
You can see all default values easily as follows:

``` r
# load default values (initial state, params, etc.)
default.values = get_default_values(model.name)
```

The definition of each default value is documented in each model’s
README (appended below in the [Available models](#available-models)
section).

Any of these values can be changed by passing the optional
`update.values` argument to `make_simulator()`. We recommend first
loading the entire list of default values and extracting the specific
value (list element) that you want to update, editing the numeric
quantity as desired, and then passing the modified list element to
`make_simulator()` via the `update.values` argument, to ensure that
format of value is preserved to remain compatible with the model
definition and `macpan2`:

``` r
# get default initial state
default.state = default.values$state
print("default state:")
#> [1] "default state:"
print(default.state)
#>      S_y      R_y      E_y      I_y      H_y      D_y      S_o      R_o 
#> 31400000        0        1        1        0        0  6900000        0 
#>      E_o      I_o      H_o      D_o 
#>        1        1        0        0

# move some young susceptibles to the recovered class
new.state = default.state # copy over default value to preserve format
new.state["R_y"] = 1000 # modify specific elements
new.state["S_y"] = new.state["S_y"] - new.state["R_y"] # modify specific elements
print("new state:")
#> [1] "new state:"
print(new.state)
#>      S_y      R_y      E_y      I_y      H_y      D_y      S_o      R_o 
#> 31399000     1000        1        1        0        0  6900000        0 
#>      E_o      I_o      H_o      D_o 
#>        1        1        0        0

# use updated state to make a new simulator 
new_model_simulator = make_simulator(
  model.name = model.name,
  updated.values = list(state = new.state)
)
```

### Simulate a model

To simulate a model, just use the `simulate()` function:

``` r
sim_output = simulate(model_simulator)
```

Since the model simulator already has all required values attached, all
required calculations can be performed to produce the simulation
results. Simulation outputs may include several items, such as the count
of individuals in each state (`value_type == "state"`) or the total
inflow into each compartment (`value_type == "total inflow"`) at each
time.

For instance, here is the number of individuals in each state,
stratified by the two age groups `y` (young) and `o` (old), at time 10:

``` r
(sim_output
 |> dplyr::filter(value_type == 'state', time == 10)
)
#>    time state_name value_type        value
#> 1    10        S_y      state 3.139988e+07
#> 2    10        E_y      state 7.888172e+01
#> 3    10        I_y      state 2.644023e+01
#> 4    10        H_y      state 5.068467e+00
#> 5    10        R_y      state 7.329988e+00
#> 6    10        D_y      state 7.329988e-01
#> 7    10        S_o      state 6.899959e+06
#> 8    10        E_o      state 2.621033e+01
#> 9    10        I_o      state 9.945527e+00
#> 10   10        H_o      state 2.328352e+00
#> 11   10        R_o      state 3.674943e+00
#> 12   10        D_o      state 3.674943e-01
```

The total inflow can be used to extract disease incidence over time:

``` r
(sim_output
 |> dplyr::filter(
   stringr::str_detect(state_name, "^I"),
   value_type == 'total_inflow'
 )
 |> head()
)
#>   time state_name   value_type     value
#> 1    1        I_y total_inflow 0.1000000
#> 2    1        I_o total_inflow 0.1000000
#> 3    2        I_y total_inflow 0.0990000
#> 4    2        I_o total_inflow 0.0990000
#> 5    3        I_y total_inflow 0.1455143
#> 6    3        I_o total_inflow 0.1195285
```

Simulation outputs are documented in each model’s README (appended below
in the [Available models](#available-models) section).

We can plot the results using standard data manipulation and plotting
tools, like `dplyr` and `ggplot2`:

<img src="man/figures/README-sim-output-1-1.png" width="75%" style="display: block; margin: auto;" />

### Scenarios

By default, `make_simulator()` will initialize a base model. Some model
definitions include optional scenarios on top of the base model, such as
interventions modelled through time-varying model parameters. For
instance, one could simulate a stay-at-home order by reducing the
transmission rate on a given date by some amount.

One can specify the `scenario.name` argument in `make_simulator()` to
attach the required model structure to simulate a given scenario type.
Scenario options and descriptions are catalogued in each model’s README
(appended below in the [Available models](#available-models) section).

Here we demonstrate the `two-age-groups` model with the
`transmission-intervention` scenario. By default, this scenario reduces
the transmission rate in each age group to 50% then 10% of its original
value on days 30 and 40, respectively:

``` r
values = get_default_values("two-age-groups")

values[
  c("intervention.day", "trans.factor.young", "trans.factor.old")
]
#> $intervention.day
#> [1] 40 50
#> 
#> $trans.factor.young
#> [1] 0.5 0.1
#> 
#> $trans.factor.old
#> [1] 0.5 0.1
```

We specify that we want to use the `change-transmission` scenario in the
call to `make_simulator()`:

``` r
model_simulator <- make_simulator(
  model.name = "two-age-groups",
  scenario.name = "change-transmission"
)

sim_output = simulate(model_simulator)
```

<img src="man/figures/README-sim-output-2-1.png" width="75%" style="display: block; margin: auto;" />

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

The solid lines indicate flows between compartments and the dashed lines
indicate when a compartment is involved in calculating a flow rate.

The force of infection for age group $i$, $\lambda_i$, which is the
per-capita rate of flow of age $i$ susceptibles into the exposed class,
is modelled as

$$
\lambda_i = \sum_{j} c_{ij} \beta_j \frac{I_j}{N_j}
$$

where

- $c_{ij}$ is the contact rate of a susceptible in age group $i$ with an
  infected in age group $j$,
- $\beta_j$ is the transmission rate for age group $j$,
- $I_j$ is the number of infectious individuals in age group $j$,
- $N_j$ is the population size of age group $j$.

#### Available scenarios

- `transmission-intervention`:
  - This scenario simulates two changes in the age-dependent
    transmission rates on specific days.
  - Intervention days are specified through the `intervention.day`
    value. The default values yield changes on days 40 and 50.
  - Scalar multiples of the original transmission rates are specified
    via the `trans.factor.young` and `trans.factor.old` values, for the
    young and old, respectively. The default values reduce the
    transmission rate to 50% then 30% of the original value across both
    age groups.

### “five-year-age-group” model

This version of the model features a basic epidemiological structure
stratified with five-year age groups up to age 80.

The lower bound of each age group is captured in the `age.group.lower`
value. This age-structure is currently hard-coded into the model
definition, though future versions of the model will flexibly generate
age groupings on request (once product models are fully implemented in
[`macpan2`](https://github.com/canmod/macpan2)).

The epidemiological compartments of this model are:

- $S$: susceptible
- $E$: exposed
- $I$: infected
- $H$: hospitalized
- $R$: recovered
- $D$: dead

The flows within each age group are as follows:

![](man/figures/README-two-age-groups_flow-diagram.png)

The solid lines indicate flows between compartments and the dashed lines
indicate when a compartment is involved in calculating a flow rate.

#### Age-based transmission

Transmission occurs in an age-based way, as a proxy for population
heterogeneity. The transmission rate for susceptibles of age `i` and
infectious individuals of age `j` is calculated as

$$
\tau \cdot \hat{c}_i \cdot p_{ij}
$$

where

- $\tau$ is the transmissibility of the pathogen, as quantified as the
  proportion of contacts between a susceptible and an infectious
  individual that yield transmission (independent of age),
- $\hat{c}_i$ is the average contact rate for individuals of age $i$
  (with all ages),
- $p_{ij}$ is the proportion of age group $i$’s contacts that occur with
  age group $j$.

The average contact rate vector ($\hat{c}$) and the contact proportion
matrix ($\[p_{ij}\]$) are both generated using a weighted average of
four setting-based component contact matrices, derived by [Mistry et al
(2021)](https://www.nature.com/articles/s41467-020-20544-y), which
reflect contacts in households, workplaces, schools, and community (all
other contacts outside of the three previous settings). A vector of
weights, indicating the average overall contact rate per setting is
specified by the `setting.weight` value. The weighted average generates
an overall contact matrix. The row sums of this matrix give the average
contact rate vector, $\hat{c}$, and the row-normalized version of this
matrix is the contact proportion matrix ($\[p_{ij}\]$).

The transmissibility of the disease is specified with the
`transmissibility` value.

#### Available scenarios

- `"contact-intervention"`:
  - This scenario enables the simulation of an intervention that affects
    the age-based contact patterns starting on a specified day from the
    start of the simulation (“intervention day”).
  - The intervention day is specified in the `intervention.day` value.
    The default value simulates a stay-at-home order starting on day 25.
  - In intervention involves using a new contact matrix starting on the
    intervention day, which is generated with new setting weights,
    specified in the `setting.weight.new` value. The default values
    reflect closing all schools, 50% of workplaces, and reducing
    community contacts by 75% from the default values for the
    `setting.weight`s.
  - The user can also change overall transmissibility of the pathogen
    starting on the intervention day to some scalar multiple of the
    original value via the `trans.factor` value. The default values
    include `trans.factor = 1`, so no change to underlying
    transmissibility.
