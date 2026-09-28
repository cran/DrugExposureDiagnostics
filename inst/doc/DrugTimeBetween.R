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
  checks = "daysBetween",
  sample = 10
)

## -----------------------------------------------------------------------------
knitr::kable(result$drugTimeBetween)

## ----eval=FALSE---------------------------------------------------------------
# knitr::kable(result$drugTimeBetweenByConcept)

