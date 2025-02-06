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
acetaminophen_checks <- executeChecks(
  cdm = cdm,
  checks = "dose"
)

## -----------------------------------------------------------------------------
DT::datatable(acetaminophen_checks$drugDose,
  rownames = FALSE
)

