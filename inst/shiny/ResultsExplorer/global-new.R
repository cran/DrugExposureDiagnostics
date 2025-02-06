#### PACKAGES -----
library(shiny)
library(bslib)
library(here)
library(readr)
library(dplyr)
library(stringr)
library(checkmate)
library(DT)
library(shinycssloaders)
library(shinyWidgets)
library(glue)
library(ggplot2)
library(plotly)
library(shinyjs)
source("ShinyModule.R")
source("ShinyApp.R")

cdm <- DrugExposureDiagnostics::mockDrugExposure()
ded <- DrugExposureDiagnostics::executeChecks(
  cdm = cdm,
  ingredients = c(1125315),
  checks = c("missing", "exposureDuration", "type", "route", "sourceConcept", "daysSupply", "verbatimEndDate", "dose", "sig", "quantity"),
  minCellCount = 5,
  earliestStartDate = "2000-01-01"
)

dp <- DrugExposureDiagnostics$new(resultList = ded, database_id = "Eunomia")

ui <- shiny::fluidPage(
  shiny::tagList(
    dp$UI()
  )
)

server <- function(input, output, session) {
  dp$server(input, output, session)
}

shiny::shinyApp(ui, server)
