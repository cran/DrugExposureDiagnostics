## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>")

## ----setup,message= FALSE, warning=FALSE--------------------------------------
library(DrugExposureDiagnostics)
library(CDMConnector)
library(dplyr)
library(DT)

## -----------------------------------------------------------------------------
cdm <- getEunomiaCdm()

## ----eval=FALSE---------------------------------------------------------------
#  executeChecks(cdm,
#                ingredients = c(1125315),
#                subsetToConceptId = NULL,
#                checks = c("missing", "exposureDuration", "type", "route", "sourceConcept", "daysSupply", "verbatimEndDate",
#                           "dose", "sig", "quantity", "ingredientOverview", "ingredientPresence", "histogram", "diagnosticsSummary"),
#                minCellCount = 5,
#                sample = 10000,
#                verbose = FALSE
#  )

## ----executeChecks------------------------------------------------------------
all_checks<-executeChecks(cdm, ingredients = 1125315)


## -----------------------------------------------------------------------------
names(all_checks)

## ----  message=FALSE, warning=FALSE-------------------------------------------
datatable(all_checks$ingredientConcepts,
  rownames = FALSE
)

## ----eval=FALSE---------------------------------------------------------------
#  writeResultToDisk(all_checks,
#                    databaseId = "your_database_id",
#                    outputFolder = "output_folder")

## ---- echo=FALSE--------------------------------------------------------------
  DBI::dbDisconnect(attr(cdm, "dbcon"), shutdown = TRUE)

