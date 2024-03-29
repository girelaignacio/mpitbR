% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mpitb.set.R
\name{mpitb.set}
\alias{mpitb.set}
\alias{mpitb.set.survey.design2}
\alias{mpitb.set.data.frame}
\title{Set the specification of the Multidimensional Poverty Measurement and Analysis project}
\usage{
mpitb.set(data, ...)

\method{mpitb.set}{survey.design2}(data, indicators, ..., name = "unnamed", desc = "desc.")

\method{mpitb.set}{data.frame}(data, indicators, ..., name = "unnamed", desc = "desc.")
}
\arguments{
\item{data}{a "survey.design2"-class object where a complex survey design was previously specified. Can be a "data.frame" but it is coerced to "survey.design2" class assuming equal probabilities.}

\item{...}{other arguments}

\item{indicators}{a list or character vector containing the names of the indicators. If it is a list, the element represents the dimension which character vector with their corresponding indicators. At most 10 dimensions are allowed. The indicators should belong to columns names of `data`. See Details below.}

\item{name}{a character containing a desired specification of the project name. It also serves as an ID and it is recommended to use short names (at most 10 characters are permitted).}

\item{desc}{a character containing a desired specification of the project description.}
}
\value{
"mpitb_set"-class object
}
\description{
Set the specification of the Multidimensional Poverty Measurement and Analysis project
}
\details{
The data passed to \code{data} argument assumes that the indicators columns is the
deprivation matrix \eqn{\mathbf{g}^0 = [g_{ij}^0]}, where \eqn{g_{ij}^0 = 1} if
the \eqn{i}-th person is deprived in the \eqn{j}-th indicator and
\eqn{g_{ij}^0 = 0} otherwise, for \eqn{i = 1,\ldots,n} and \eqn{j = 1,\ldots,d}.
This argument should be a "survey.design2"-class object in which the complex survey design
structure was previously specified using \code{svydesign} of survey package. If
\code{data} is a "data.frame", it is coerced to a "survey.design2"-class object
assuming equal probabilities, which is rarely used in household surveys.

These columns should not contain any missing value. For estimating the multidimensional
poverty measures, the R survey package supports missing values for calculating the point
estimation but it would not be able to calculate the standard error and, therefore,
the confidence intervals.

The \code{indicators} argument should contain the names of indicators corresponding
to the columns names in \code{data}. It is advisable to pass a list object where each
element is the dimension and contain the character string with the indicators name
because the package can calculate the nested equal weights automatically in the
subsequent estimations. At most 10 dimensions are allowed. It can also be a character
string. In this later case, if nested weights across dimensions is used, the user
should be careful and specified later the corresponding weights by hand.

Finally, \code{name} and \code{desc} arguments are useful for identifying each
MPI setting while working in a multidimensional poverty measurement and analysis project.
Names with more than 10 characters are not allowed for tidiness purposes.
}
\examples{
library(mpitbR)

data <- subset(syn_cdta, t==1)
data <- na.omit(data)

svydata <- survey::svydesign(id=~psu, weights = ~weight, strata = ~stratum, data = data)

indicators <- list(d1 = c("d_nutr","d_cm"),
                   d2 = c("d_satt","d_educ"),
                   d3 = c("d_elct","d_sani","d_wtr","d_hsg","d_ckfl","d_asst"))

set <- mpitb.set(svydata, indicators = indicators, name = "myname", desc = "pref. desc")
}
\references{
\emph{Alkire, S., Foster, J. E., Seth, S., Santos, M. E., Roche, J., & Ballon, P. (2015). Multidimensional poverty measurement and analysis. Oxford University Press.}

             \emph{Alkire, S., Roche, J. M., & Vaz, A. (2017). Changes over time in multidimensional poverty: Methodology and results for 34 countries. World Development, 94, 232-249}. \doi{10.1016/j.worlddev.2017.01.011}

             \emph{Suppa, N. (2023). mpitb: A toolbox for multidimensional poverty indices. The Stata Journal, 23(3), 625-657}. \doi{10.1177/1536867X231195286}
}
\seealso{
\code{mpitb.est} function.
}
\author{
Ignacio Girela
}
