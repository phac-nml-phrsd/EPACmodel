
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EPACmodel

<!-- badges: start -->
<!-- badges: end -->

This package implements the Early Pandemic Age-Structured Compartmental
(EPAC) model developed by [Michael WZ Li](https://github.com/wzmli) and
[Irena Papst](https://github.com/papsti) from the [Public Health Risk
Sciences Division](https://github.com/phac-nml-phrsd) of the Public
Health Agency of Canada using
[`macpan2`](https://github.com/canmod/macpan2) modelling software.

The goal of this package is to catalogue, document, and version
iterations of the Early Pandemic Age-structured Compartmental model so
that they can be pulled easily into project-specific pipelines to
produce modelling outputs.

## Installation

If you're on a Windows system, please install `Rtools` matching your R version from [here](https://cran.r-project.org/bin/windows/Rtools/). This ensures you have a C++ compiler, which is required to install `macpan2`, a dependency of `EPACmodel`.

Versioned releases of `EPACmodel` can be installed with

``` r
remotes::install_github("phac-nml-phrsd/EPACmodel@vx.y.z")
```

where `x.y.z` is the version number. Available version numbers can be
found [here](https://github.com/phac-nml-phrsd/EPACmodel/releases).

The development version of `EPACmodel` can be installed with:

``` r
remotes::install_github("phac-nml-phrsd/EPACmodel")
```

## Getting started

A getting started guide can be found in `vignette("EPACmodel")`.
