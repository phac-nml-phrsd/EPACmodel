% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers_five-year-age-groups.R
\name{mk_contact_pars}
\alias{mk_contact_pars}
\title{Make contact matrix from Mistry et al. data}
\usage{
mk_contact_pars(age.group.lower, setting.weight)
}
\arguments{
\item{age.group.lower}{Numeric vector. Lower bounds for desired age groups}

\item{setting.weight}{Named numeric vector of the average contact rate by setting to reflect closures.}
}
\value{
A list with:
\itemize{
\item \code{p.mat}: the row-normalized matrix of contact probabilities
\item \code{c.hat}: the vector of row sums from the contact rate matrix, giving the average contact rate per age group; used to set up the transmission vector to maintain the contact balance condition
}
}
\description{
Make contact matrix from Mistry et al. data
}
