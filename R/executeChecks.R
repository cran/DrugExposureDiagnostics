# Copyright 2022 DARWIN EU®
#
# This file is part of IncidencePrevalence
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Execute all checks on Drug Exposure.
#'
#' @param cdm CDMConnector reference object
#' @param ingredients vector of ingredients, by default: acetaminophen
#' @param checks the checks to be executed, by default everything
#' @param minCellCount minimum number of events to report- results
#' lower than this will be obscured. If NULL all results will be reported.
#' @param sample the number of samples, default 1 million
#' @param tablePrefix The stem for the permanent tables that will
#' be created when running the diagnostics. Permanent tables will be created using
#' this prefix, and any existing tables that start with this will be at risk of
#' being dropped or overwritten. If NULL, temporary tables will be
#' used throughout.
#' @param earliestStartDate the earliest date from which a record can be included
#' @param verbose verbose, default FALSE
#'
#' @return named list with results
#' @export
#'
#' @examples
#' \dontrun{
#' db <- DBI::dbConnect(" Your database connection here ")
#' cdm <- CDMConnector::cdm_from_con(
#'   con = db,
#'   cdm_schema = "cdm schema name"
#' )
#' result <- executeChecks(
#'   cdm = cdm,
#'   ingredients = c(1125315))
#' }
executeChecks <- function(cdm,
                          ingredients = c(1125315),
                          checks = c("missing", "exposureDuration", "type", "route",
                                     "sourceConcept", "daysSupply", "verbatimEndDate",
                                     "dose", "sig", "quantity", "histogram"),
                          minCellCount = 5,
                          sample = 1000000,
                          tablePrefix = NULL,
                          earliestStartDate = "2010-01-01",
                          verbose = FALSE) {

  errorMessage <- checkmate::makeAssertCollection()
  checkDbType(cdm = cdm, type = "cdm_reference", messageStore = errorMessage)
  checkmate::assertNumeric(ingredients, min.len = 1, add = errorMessage)
  checkmate::assertTRUE(is.numeric(minCellCount) || is.null(minCellCount), add = errorMessage)
  checkmate::assertNumeric(sample, len = 1, add = errorMessage)
  checkmate::assertCharacter(tablePrefix, len = 1, add = errorMessage, null.ok = TRUE)
  checkmate::assertDate(as.Date(earliestStartDate), add = errorMessage, null.ok = FALSE)
  checkLogical(verbose, messageStore = errorMessage)
  checkmate::reportAssertions(collection = errorMessage)

  resultList <- NULL
  for (ingredient in ingredients) {
    newResultList <- executeChecksSingleIngredient(cdm = cdm,
                                                   ingredient = ingredient,
                                                   checks = checks,
                                                   minCellCount = minCellCount,
                                                   sample = sample,
                                                   tablePrefix = tablePrefix,
                                                   earliestStartDate = earliestStartDate,
                                                   verbose = verbose)
    if (is.null(resultList)) {
      resultList <- newResultList
    } else {
      checkNames <- names(resultList)
      resultList <- lapply(checkNames, FUN = function(name) {
        rbind(resultList[[name]], newResultList[[name]])
      })
      names(resultList) <- checkNames
    }
  }
  return(resultList)
}

#' Execute all checks on Drug Exposure for a single ingredient.
#'
#' @param cdm CDMConnector reference object
#' @param ingredient ingredient, by default: acetaminophen
#' @param checks the checks to be executed, by default everything
#' @param minCellCount minimum number of events to report- results
#' lower than this will be obscured. If NULL all results will be reported.
#' @param sample the number of samples, default 1 million
#' @param tablePrefix The stem for the permanent tables that will
#' be created when running the diagnostics. Permanent tables will be created using
#' this prefix, and any existing tables that start with this will be at risk of
#' being dropped or overwritten. If NULL, temporary tables will be
#' used throughout.
#' @param earliestStartDate the earliest date from which a record can be included
#' @param verbose verbose, default FALSE
#'
#' @return named list with results
executeChecksSingleIngredient <- function(cdm,
                                          ingredient = 1125315,
                                          checks = c("missing", "exposureDuration", "type", "route",
                                                     "sourceConcept", "daysSupply", "verbatimEndDate",
                                                     "dose", "sig", "quantity", "histogram"),
                                          minCellCount = 5,
                                          sample = 1000000,
                                          tablePrefix = NULL,
                                          earliestStartDate = "2010-01-01",
                                          verbose = FALSE) {

  errorMessage <- checkmate::makeAssertCollection()
  checkDbType(cdm = cdm, type = "cdm_reference", messageStore = errorMessage)
  checkIsIngredient(cdm = cdm, conceptId = ingredient, messageStore = errorMessage)
  checkmate::assertTRUE(is.numeric(minCellCount) || is.null(minCellCount), add = errorMessage)
  checkmate::assertNumeric(sample, len = 1, add = errorMessage)
  checkmate::assertCharacter(tablePrefix, len = 1, add = errorMessage, null.ok = TRUE)
  checkmate::assertDate(as.Date(earliestStartDate), add = errorMessage, null.ok = FALSE)
  checkLogical(verbose, messageStore = errorMessage)
  checkmate::reportAssertions(collection = errorMessage)

  if (verbose == TRUE) {
    start <- Sys.time()
    message(glue::glue("Progress: getting descendant concepts of ingredient ({ingredient}) used in database"))
  }

  cdm[["ingredient_concepts"]] <- ingredientDescendantsInDb(
    cdm = cdm,
    ingredient = ingredient,
    verbose = verbose,
    tablePrefix = tablePrefix
  )

  if (verbose == TRUE) {
    start <- printDurationAndMessage("Progress: getting drug strength for ingredient", start)
  }

  cdm[["ingredient_drug_strength"]] <- getDrugStrength(
    cdm = cdm,
    ingredient = ingredient,
    includedConceptsTable = "ingredient_concepts",
    tablePrefix = tablePrefix
  )

  if (verbose == TRUE) {
    start <- printDurationAndMessage("Progress: getting drug records for ingredient", start)
  }
  cdm[["ingredient_drug_records"]] <- getDrugRecords(
    cdm = cdm,
    ingredient = ingredient,
    includedConceptsTable = "ingredient_concepts",
    tablePrefix = tablePrefix
  )

  if (verbose == TRUE) {
    start <- printDurationAndMessage("Progress: get concepts used", start)
  }

  conceptsUsed <- cdm[["ingredient_drug_records"]] %>%
    dplyr::group_by(.data$drug_concept_id) %>%
    dplyr::tally(name = "n_records") %>%
    dplyr::inner_join(cdm[["ingredient_concepts"]],
                      by=c("drug_concept_id" = "concept_id")) %>%
    dplyr::rename("drug" = "concept_name") %>%
    dplyr::relocate("drug", .after = "drug_concept_id") %>%
    dplyr::relocate("ingredient_concept_id", .after = "drug") %>%
    dplyr::relocate("ingredient", .after = "ingredient_concept_id") %>%
    dplyr::relocate("numerator_unit", .after = "numerator_unit_concept_id") %>%
    dplyr::relocate("denominator_unit", .after = "denominator_unit_concept_id") %>%
    dplyr::collect()

  if (verbose == TRUE) {
    start <- printDurationAndMessage("Progress: get ingredient overview", start)
  }
  drugIngredientOverview <- getIngredientOverview(cdm, "ingredient_drug_records",
                                                  "ingredient_drug_strength") %>% dplyr::collect()


  # sample
  # the ingredient overview is for all records
  # all other checks for sampled records
  if (!is.null(sample)) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: sampling drug records", start)
    }
    if (dplyr::pull(dplyr::tally(dplyr::filter(cdm[["ingredient_drug_records"]], .data$drug_exposure_start_date > .env$earliestStartDate)), .data$n) < sample) {
      message("population after earliestStartDate smaller than sample, ignoring date for sampling")
      cdm[["ingredient_drug_records"]] <- cdm[["ingredient_drug_records"]] %>%
        dplyr::slice_sample(n = sample)
    } else{
      cdm[["ingredient_drug_records"]] <- cdm[["ingredient_drug_records"]] %>%
        dplyr::filter(.data$drug_exposure_start_date > .env$earliestStartDate) %>%
        dplyr::slice_sample(n = sample)
    }
  }
  drugIngredientPresence <- getIngredientPresence(cdm, "ingredient_drug_records",
                                                  "ingredient_drug_strength") %>% dplyr::collect()

  missingValuesOverall <- missingValuesByConcept <- NULL
  if ("missing" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugsMissing", start)
    }

    missingValuesOverall <- getDrugMissings(cdm, "ingredient_drug_records",
                                           byConcept = FALSE) %>% dplyr::collect()
    missingValuesByConcept <- getDrugMissings(cdm, "ingredient_drug_records",
                                             byConcept = TRUE) %>% dplyr::collect()
  }

  drugExposureDurationOverall <- drugExposureDurationByConcept <- NULL
  if ("exposureDuration" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check ExposureDuration", start)
    }

    drugExposureDurationOverall <- summariseDrugExposureDuration(cdm,
                                                                 "ingredient_drug_records",
                                                                 byConcept = FALSE)  %>% dplyr::collect()
    drugExposureDurationByConcept <- summariseDrugExposureDuration(cdm,
                                                                   "ingredient_drug_records",
                                                                   byConcept = TRUE) %>% dplyr::collect()
  }

  drugTypesOverall <- drugTypesByConcept <- NULL
  if ("type" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugTypes", start)
    }

    drugTypesOverall <- getDrugTypes(cdm, "ingredient_drug_records",
                                     byConcept = FALSE) %>% dplyr::collect()
    drugTypesByConcept <- getDrugTypes(cdm, "ingredient_drug_records",
                                       byConcept = TRUE) %>% dplyr::collect()
  }

  drugRoutesOverall <- drugRoutesByConcept <- NULL
  if ("route" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugRoutes", start)
    }

    drugRoutesOverall <- getDrugRoutes(cdm, "ingredient_drug_records",
                                       byConcept = FALSE) %>% dplyr::collect()
    drugRoutesByConcept <- getDrugRoutes(cdm, "ingredient_drug_records",
                                         byConcept = TRUE) %>% dplyr::collect()
  }

  drugSourceConceptsOverall <- drugSourceConceptsByConcept <- NULL
  if ("sourceConcept" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugSourceConcepts", start)
    }

    drugSourceConceptsOverall <- getDrugSourceConcepts(cdm, "ingredient_drug_records",
                                                       byConcept = FALSE) %>% dplyr::collect()
    drugSourceConceptsByConcept <- getDrugSourceConcepts(cdm, "ingredient_drug_records",
                                                         byConcept = TRUE) %>% dplyr::collect()
  }

  drugDaysSupply <- drugDaysSupplyByConcept <- NULL
  if ("daysSupply" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugDaysSupply", start)
    }

    drugDaysSupply <- checkDaysSupply(cdm, "ingredient_drug_records", byConcept = FALSE) %>% dplyr::collect()
    drugDaysSupplyByConcept <- checkDaysSupply(cdm, "ingredient_drug_records", byConcept = TRUE) %>% dplyr::collect()
  }

  drugVerbatimEndDate <- drugVerbatimEndDateByConcept <- NULL
  if ("verbatimEndDate" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugVerbatimEndDate", start)
    }

    drugVerbatimEndDate <- checkVerbatimEndDate(cdm, "ingredient_drug_records", byConcept = FALSE) %>% dplyr::collect()
    drugVerbatimEndDateByConcept <- checkVerbatimEndDate(cdm, "ingredient_drug_records", byConcept = TRUE) %>% dplyr::collect()
  }

  drugDose <- drugDoseByConcept <- NULL
  if ("dose" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugDose", start)
    }

    drugDose <- checkDrugDose(cdm, "ingredient_drug_records",
                              "drug_strength", byConcept = FALSE) %>% dplyr::collect()

    drugDoseByConcept <- checkDrugDose(cdm, "ingredient_drug_records",
                                       "drug_strength", byConcept = TRUE) %>% dplyr::collect()
  }

  drugSig <- drugSigByConcept <- NULL
  if ("sig" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugSig", start)
    }

    drugSig <- checkDrugSig(cdm, "ingredient_drug_records", byConcept = FALSE) %>% dplyr::collect()
    drugSigByConcept <- checkDrugSig(cdm, "ingredient_drug_records", byConcept = TRUE) %>% dplyr::collect()
  }

  drugQuantity <- drugQuantityByConcept <- NULL
  if ("quantity" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: check drugQuantity", start)
    }

    drugQuantity <- summariseQuantity(cdm, "ingredient_drug_records", byConcept = FALSE) %>% dplyr::collect()
    drugQuantityByConcept <- summariseQuantity(cdm, "ingredient_drug_records", byConcept = TRUE) %>% dplyr::collect()
  }

  drugDaysSupplyHistogram <- drugQuantityHistogram <- drugDurationHistogram <- NULL
  if ("histogram" %in% checks) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Progress: create histograms", start)
    }
    drugDaysSupplyHistogram <- createHistogram(cdm, "ingredient_drug_records", type = "days_supply")
    drugQuantityHistogram <- createHistogram(cdm, "ingredient_drug_records", type = "quantity")
    drugDurationHistogram <- createHistogram(cdm, "ingredient_drug_records", type = "duration")
  }

  if (!is.null(tablePrefix)) {
    if (verbose == TRUE) {
      start <- printDurationAndMessage("Cleaning up tables", start)
    }
    tables <- CDMConnector::listTables(attr(cdm, "dbcon"),
                                       schema = attr(cdm, "write_schema"))
    tables <- tables[grepl(tablePrefix, tables)]
    CDMConnector::dropTable(cdm, tables, verbose)
  }

  if (verbose == TRUE) {
    start <- printDurationAndMessage("Finished", start)
  }

  result <- list("conceptSummary" = conceptsUsed,
                 "missingValuesOverall" = missingValuesOverall,
                 "missingValuesByConcept" = missingValuesByConcept,
                 "drugExposureDurationOverall" = drugExposureDurationOverall,
                 "drugExposureDurationByConcept" = drugExposureDurationByConcept,
                 "drugTypesOverall" = drugTypesOverall,
                 "drugTypesByConcept" = drugTypesByConcept,
                 "drugRoutesOverall" = drugRoutesOverall,
                 "drugRoutesByConcept" = drugRoutesByConcept,
                 "drugSourceConceptsOverall" = drugSourceConceptsOverall,
                 "drugSourceConceptsByConcept" = drugSourceConceptsByConcept,
                 "drugDaysSupply" = drugDaysSupply,
                 "drugDaysSupplyByConcept" = drugDaysSupplyByConcept,
                 "drugVerbatimEndDate" = drugVerbatimEndDate,
                 "drugVerbatimEndDateByConcept" = drugVerbatimEndDateByConcept,
                 "drugDose" = drugDose,
                 "drugDoseByConcept" = drugDoseByConcept,
                 "drugSig" = drugSig,
                 "drugSigByConcept" = drugSigByConcept,
                 "drugQuantity" = drugQuantity,
                 "drugQuantityByConcept" = drugQuantityByConcept,
                 "drugIngredientOverview" = drugIngredientOverview,
                 "drugIngredientPresence" = drugIngredientPresence,
                 "drugDaysSupplyHistogram" = drugDaysSupplyHistogram,
                 "drugQuantityHistogram" = drugQuantityHistogram,
                 "drugDurationHistogram" = drugDurationHistogram)

  # add summary table
  result[["diagnostics_summary"]] <- summariseChecks(resultList = result)

  return(Filter(Negate(is.null), sapply(names(result),
                                        FUN = function(tableName) {
                                          table <- result[[tableName]]
                                          if (!is.null(table)) {
                                            if (grepl("Histogram", tableName)) {
                                              table %>% hist2DataFrame()
                                            } else {
                                              obscureCounts(table = table,
                                                            tableName = tableName,
                                                            minCellCount = minCellCount,
                                                            substitute = NA)
                                            }
                                          }
                                        },
                                        simplify = FALSE,
                                        USE.NAMES = TRUE)))
}
