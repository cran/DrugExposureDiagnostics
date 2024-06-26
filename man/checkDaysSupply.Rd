% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkDaysSupply.R
\name{checkDaysSupply}
\alias{checkDaysSupply}
\title{Check if Days_supply is the same as datediff(drug_exp_start_date,drug_exp_end_date)}
\usage{
checkDaysSupply(
  cdm,
  drugRecordsTable = "ingredient_drug_records",
  byConcept = TRUE,
  sampleSize = 10000
)
}
\arguments{
\item{cdm}{CDMConnector reference object}

\item{drugRecordsTable}{a modified version of the drug exposure table, default "ingredient_drug_records"}

\item{byConcept}{whether to get result by drug concept}

\item{sampleSize}{the sample size given in execute checks}
}
\value{
a table with the stats of days supply compared to start and end date
}
\description{
Check if Days_supply is the same as datediff(drug_exp_start_date,drug_exp_end_date)
}
