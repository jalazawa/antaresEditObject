% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/createBindingConstraint.R
\name{createBindingConstraint}
\alias{createBindingConstraint}
\title{Create a Binding Constraint}
\usage{
createBindingConstraint(name, id = tolower(name), values = NULL,
  enabled = TRUE, timeStep = c("hourly", "daily", "weekly"),
  operator = c("both", "equal", "greater", "less"), coefficients = NULL,
  overwrite = FALSE, opts = antaresRead::simOptions())
}
\arguments{
\item{name}{The name for the binding constraint}

\item{id}{An id}

\item{values}{Values used by the constraint.
It contains one line per time step and three columns "less", "greater" and "equal".}

\item{enabled}{Logical, is the constraint enabled ?}

\item{timeStep}{Time step the constraint applies to : \code{hourly}, \code{daily} or \code{weekly}}

\item{operator}{Type of constraint: equality, inequality on one side or both sides.}

\item{coefficients}{A named vector containing the coefficients used by the constraint.}

\item{overwrite}{If the constraint already exist, overwrite the previous value.}

\item{opts}{List of simulation parameters returned by the function
\code{antaresRead::setSimulationPath}}
}
\value{
An updated list containing various information about the simulation.
}
\description{
Create a Binding Constraint
}
\examples{
\dontrun{
createBindingConstraint(
  name = "myconstraint", 
  values = matrix(data = rep(0, 8760 * 3), ncol = 3), 
  enabled = FALSE, 
  timeStep = "hourly",
  operator = "both",
  coefficients = c("fr\%myarea" = 1)
)
}
}
