% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/editLink.R
\name{editLink}
\alias{editLink}
\title{Edit a link between two areas}
\usage{
editLink(from, to, hurdles_cost = NULL, transmission_capacities = NULL,
  display_comments = NULL, filter_synthesis = NULL,
  filter_year_by_year = NULL, dataLink = NULL,
  opts = antaresRead::simOptions())
}
\arguments{
\item{from}{The first area from which to create a link}

\item{to}{The second one}

\item{hurdles_cost}{Logical, which is used to state whether (linear)
transmission fees should be taken into account or not in economy and adequacy simulations}

\item{transmission_capacities}{Character, one of \code{enabled}, \code{ignore} or \code{infinite}, which is used to state whether 
the capacities to consider are those indicated in 8760-hour arrays or 
if zero or infinite values should be used instead (actual values / set to zero / set to infinite)}

\item{display_comments}{Logical}

\item{filter_synthesis}{Output synthesis}

\item{filter_year_by_year}{Output year-by-year}

\item{dataLink}{a matrix with five column corresponding to : trans. capacity (direct)
trans. capacity (indirect), impedances, hurdles cost (direct), hurdles cost (indirect).
If \code{NULL} (default), a matrix whose rows are equal to \code{1, 1, 0, 0, 0} is set. See Details}

\item{opts}{List of simulation parameters returned by the function
\code{antaresRead::setSimulationPath}}
}
\value{
An updated list containing various information about the simulation.
}
\description{
Edit a link between two areas
}
\details{
The five times-series are:
\itemize{
 \item{"NTC direct"}{the upstream-to-downstream capacity, in MW}
 \item{"NTC indirect"}{the downstream-to-upstream capacity, in MW}
 \item{"Impedances"}{virtual impedances that are used in economy simulations to give a physical meaning to raw outputs, when no binding constraints have been defined to enforce Kirchhoff's laws.}
 \item{"Hurdle cost direct"}{an upstream-to-downstream transmission fee, in euro/MWh}
 \item{"Hurdle cost indirect"}{a downstream-to-upstream transmission fee, in euro/MWh}
}
}
\note{
In Antares, areas are sorted in alphabetical order to establish links between.
For example, link between "fr" and "be" will appear under "be". 
So the areas are sorted before creating the link between them, and \code{dataLink} is
rearranged to match the new order.
}
\examples{
\dontrun{
createLink(from = "myarea", to  = "myarea2")
}
}
