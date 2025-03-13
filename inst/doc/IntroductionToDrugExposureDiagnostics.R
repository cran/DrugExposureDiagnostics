## ----include = FALSE----------------------------------------------------------
options(rmarkdown.html_vignette.check_title = FALSE)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup,message= FALSE, warning=FALSE--------------------------------------
library(DrugExposureDiagnostics)

## -----------------------------------------------------------------------------
cdm <- mockDrugExposure()

## ----executeChecks------------------------------------------------------------
all_checks <- executeChecks(cdm,
  ingredients = c(1125315),
  subsetToConceptId = NULL,
  checks = c(
    "missing", "exposureDuration", "type", "route", "sourceConcept", "daysSupply",
    "verbatimEndDate", "dose", "sig", "quantity", "diagnosticsSummary"
  ),
  minCellCount = 5,
  sample = 10000,
  tablePrefix = NULL,
  earliestStartDate = "2010-01-01",
  verbose = FALSE,
  byConcept = TRUE,
  exposureTypeId = NULL,
  outputFolder = "output_folder",
  filename = "your_database"
)

## -----------------------------------------------------------------------------
names(all_checks)

## ----message=FALSE, warning=FALSE---------------------------------------------
DT::datatable(all_checks$conceptSummary,
  rownames = FALSE
)

## ----eval=FALSE---------------------------------------------------------------
#  writeResultToDisk(all_checks,
#    databaseId = "your_database",
#    outputFolder = "output_folder"
#  )

## ----eval=FALSE---------------------------------------------------------------
#  viewResults(
#    dataFolder = file.path(getwd(), "output_folder"),
#    makePublishable = TRUE,
#    publishDir = file.path(getwd(), "MyStudyResultsExplorer"),
#    overwritePublishDir = TRUE
#  )

## ----echo=FALSE---------------------------------------------------------------
DBI::dbDisconnect(attr(cdm, "dbcon"), shutdown = TRUE)

