test_that("test dropTables function", {
  cdm <- mockDrugExposure()
  attr(cdm, "write_schema") <- "main"

  ingredientDescendantsInDb(cdm = cdm,
                            ingredient = 1125315,
                            drugRecordsTable = "drug_exposure",
                            tablePrefix = "result")

  # we have the stem tables in our write schema
  tables <- CDMConnector::listTables(attr(cdm, "dbcon"),
                           schema = attr(cdm, "write_schema"))
  tables <- tables[grepl("result_", tables)]

  expect_true(length(tables) == 5)

  dropTables(cdm, name = tables)

  # and now we don´t
  expect_false(any(grepl(
    "result",
    CDMConnector::listTables(attr(cdm, "dbcon"),
                             schema = attr(cdm, "write_schema")
    ),
  )))

  expect_error(dropTables("cdm", name = c("result")))
  expect_error(dropTables(cdm, name = 1))

  DBI::dbDisconnect(attr(cdm, "dbcon"), shutdown = TRUE)
})
