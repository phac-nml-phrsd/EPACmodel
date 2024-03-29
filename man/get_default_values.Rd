% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_default_values.R
\name{get_default_values}
\alias{get_default_values}
\title{Get named list of default values for a model}
\usage{
get_default_values(model.name, local = FALSE)
}
\arguments{
\item{model.name}{name of the model (see \code{\link[=list_models]{list_models()}} for options)}

\item{local}{logical. if TRUE, use local model definition (in \code{models} subdirectory of main project repo). if FALSE, use package models.}
}
\value{
Named list of default values used to initialize a model for simulation
}
\description{
Get named list of default values for a model
}
