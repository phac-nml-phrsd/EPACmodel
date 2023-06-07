
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

The goals of this package are to document the model, provide tools for
simulating and calibrating the model, as well as visualizing model
outputs.

## Installation

You can install the development version of EPACmodel like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(EPACmodel)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

``` r
plot(pressure)
```

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
