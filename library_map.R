library(data.table)
library(ggplot2)
library(leaflet)
library(janitor)

#Map Leeds libraries----
##Download dataset
library_leeds_raw <- data.table::fread("https://datamillnorth.org/download/leeds-libraries/cfc9f345-4916-4b74-aa9e-cecc78db9075/library%20locations.csv")
library_leeds_raw <- janitor::clean_names(library_leeds_raw)

#
library_date_filter

leeds_libraries <- leaflet(library_leeds_raw) %>%
#Select tiles we want to use
  addProviderTiles(providers$OpenStreetMap.Mapnik) %>%  # use the default base map which is OpenStreetMap tiles
#Give long, lat and custom popup details
   addMarkers(lng= ~longitude,
              lat= ~latitude,
              popup = ~paste0(library,
                              "<br/>Address: ",
                              address_line_1))
leeds_libraries
