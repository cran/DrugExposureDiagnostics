% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkVerbatimEndDate.R
\name{checkVerbatimEndDate}
\alias{checkVerbatimEndDate}
\title{Check the verbatim_end_date field}
\usage{
checkVerbatimEndDate(cdm, drugRecordsTable = "drug_exposure", byConcept = TRUE)
}
\arguments{
\item{cdm}{CDMConnector reference object}

\item{drugRecordsTable}{drug exposure table}

\item{byConcept}{whether to get result by concept}
}
\value{
a table with the stats about the verbatim_end_date
}
\description{
Check the verbatim_end_date field
}
