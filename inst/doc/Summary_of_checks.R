## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  warning = FALSE,
  message = FALSE,
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(DrugExposureDiagnostics)
library(dplyr)

# acetaminophen concept id is 1125315
acetaminophen <- 1125315
cdm <- getEunomiaCdm(ingredientId = acetaminophen)
acetaminophen_checks <- executeChecks(cdm = cdm, 
                                      ingredients = acetaminophen, 
                                      checks = c("missing", "exposureDuration", "type", "route", "sourceConcept", "daysSupply", "verbatimEndDate", 
                                                 "dose", "sig", "quantity", "ingredientOverview", "ingredientPresence", "histogram", "diagnosticsSummary"))

## -----------------------------------------------------------------------------
acetaminophen_checks$diagnosticsSummary %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$conceptSummary %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$missingValuesByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugExposureDurationByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugDaysSupplyByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugTypesByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugRoutesByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugSourceConceptsByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugVerbatimEndDateByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugDoseByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugSigByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugQuantityByConcept %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugIngredientOverview %>% 
  glimpse()

## -----------------------------------------------------------------------------
acetaminophen_checks$drugIngredientPresence %>% 
  glimpse()

