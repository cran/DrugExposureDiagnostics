% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkDrugSourceConcepts.R
\name{getDrugSourceConcepts}
\alias{getDrugSourceConcepts}
\title{Check drug exposure source types}
\usage{
getDrugSourceConcepts(
  cdm,
  drugRecordsTable = "ingredient_drug_records",
  sampleSize = 10000
)
}
\arguments{
\item{cdm}{CDMConnector reference object}

\item{drugRecordsTable}{modified drug exposure table}

\item{sampleSize}{the sample size given in execute checks}
}
\value{
a table with the drug source concepts
}
\description{
Check drug exposure source types
}
