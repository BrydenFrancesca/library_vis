library(shiny)
library(shinyMobile)
library(data.table)
library(ggplot2)
library(leaflet)
library(janitor)
library(dplyr)
library(lubridate)
library(stringr)
library(plotly)


source("ui.R")
source("server.R")

shiny::shinyApp(ui = ui, server = server)
