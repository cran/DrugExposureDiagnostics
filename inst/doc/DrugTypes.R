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
cdm <- mockDrugExposure()
result <- executeChecks(
  cdm = cdm,
  checks = "type"
)

## -----------------------------------------------------------------------------
DT::datatable(result$drugTypesOverall,
  rownames = FALSE
)

## ----eval=FALSE---------------------------------------------------------------
#  DT::datatable(result$drugTypesByConcept, rownames = FALSE)

