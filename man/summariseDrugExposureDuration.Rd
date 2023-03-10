% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drugRecordChecks.R
\name{summariseDrugExposureDuration}
\alias{summariseDrugExposureDuration}
\title{Summarise drug exposure record durations}
\usage{
summariseDrugExposureDuration(
  cdm,
  drugRecordsTable = "drug_exposure",
  byConcept = TRUE
)
}
\arguments{
\item{cdm}{CDMConnector reference object}

\item{drugRecordsTable}{drugRecordsTable}

\item{byConcept}{byConcept}
}
\value{
a table with the drug exposure record durations
}
\description{
Summarise drug exposure record durations
}
