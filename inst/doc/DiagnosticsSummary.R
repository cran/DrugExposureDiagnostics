## ---- include = FALSE---------------------------------------------------------
options(rmarkdown.html_vignette.check_title = FALSE)
knitr::opts_chunk$set(
  warning = FALSE,
  message = FALSE,
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(DrugExposureDiagnostics)
library(DT)
library(dplyr)

# acetaminophen concept id is 1125315
acetaminophen <- 1125315
cdm <- mockDrugExposure()
acetaminophen_checks <- executeChecks(cdm = cdm, 
                                      ingredients = acetaminophen, 
                                      checks = c("missing", "exposureDuration", "type","route","dose","quantity", "diagnosticsSummary"))

## -----------------------------------------------------------------------------
datatable(acetaminophen_checks$diagnosticsSummary,
  rownames = FALSE
)

