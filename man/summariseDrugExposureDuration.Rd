% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkDrugExposureDuration.R
\name{summariseDrugExposureDuration}
\alias{summariseDrugExposureDuration}
\title{Summarise drug exposure record durations}
\usage{
summariseDrugExposureDuration(
  cdm,
  drugRecordsTable = "ingredient_drug_records",
  byConcept = TRUE,
  sampleSize = 10000
)
}
\arguments{
\item{cdm}{CDMConnector reference object}

\item{drugRecordsTable}{a modified version of the drug exposure table, default "ingredient_drug_records"}

\item{byConcept}{by individual drug Concept}

\item{sampleSize}{the sample size given in execute checks}
}
\value{
a table with the drug exposure record durations
}
\description{
Summarise drug exposure record durations
}
