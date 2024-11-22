## ----include = FALSE----------------------------------------------------------
options(rmarkdown.html_vignette.check_title = FALSE)
knitr::opts_chunk$set(
  warning = FALSE,
  message = FALSE,
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(DrugExposureDiagnostics)
library(dplyr)
library(DT)

# acetaminophen concept id is 1125315
acetaminophen <- 1125315
cdm <- mockDrugExposure()
acetaminophen_checks <- executeChecks(
  cdm = cdm,
  ingredients = acetaminophen,
  checks = "type"
)

## -----------------------------------------------------------------------------
datatable(acetaminophen_checks$drugTypesOverall,
  rownames = FALSE
)

## -----------------------------------------------------------------------------
datatable(acetaminophen_checks$drugTypesByConcept,
  rownames = FALSE
)

