library(data.table)
library(ggplot2)
library(leaflet)
library(janitor)
library(dplyr)
library(lubridate)
library(stringr)

#Map Leeds libraries----
##Download dataset
library_leeds_raw <- data.table::fread("https://datamillnorth.org/download/leeds-libraries/cfc9f345-4916-4b74-aa9e-cecc78db9075/library%20locations.csv")
library_leeds_raw <- janitor::clean_names(library_leeds_raw)

##Dummy time variable
now_time <- as.numeric(gsub("\\:", "", "13:30"))

#Tidy opening time data to allow filtering based on it
library_date_filter <- library_leeds_raw %>%
  tidyr::gather(day, time, monday_opening_hours:sunday_opening_hours) %>%
#Tidy facilities data
  tidyr::gather(facility, available, assistive_technology:writers_group) %>%
##Mutate day to just keep day name
  dplyr::mutate(day = gsub("_opening_hours", "", day)) %>%
#Create upper and lower band times
  tidyr::separate(time, into = c("time_morning", "time_afternoon"), sep = ",", remove = FALSE) %>%
  tidyr::separate(time_morning, into = c("time_morning_from", "time_morning_to"), sep = "-") %>%
  tidyr::separate(time_afternoon, into = c("time_afternoon_from", "time_afternoon_to"), sep = "-") %>%
#Gather all times into one column and trim whitespace/convert to times
  tidyr::gather(variable, hour, time_morning_from:time_afternoon_to) %>%
  dplyr::mutate(hour = as.numeric(gsub("\\:| ", "", hour))) %>%
##Spread times back out
  tidyr::spread(variable, hour) %>%
  #Filter out only today's values
  dplyr::filter(day == "monday") %>%#tolower(weekdays(lubridate::today()))) %>%
#Set colour based on whether library is open on at that time or not
  #If lunchtime shutting is NA, just check if time now is greater than opening and less than closing
  dplyr::mutate(open_colour = dplyr::case_when(
    is.na(time_afternoon_from) & now_time > time_morning_from & now_time < time_morning_to ~ "#228B22",
  #If it is closed at lunchtime, does it fall between the open periods
    (now_time > time_morning_from & now_time < time_morning_to) | (now_time > time_afternoon_from & now_time < time_afternoon_to) ~ "#228B22",
  #Otherwise closed
    TRUE ~ "#FF0000")) %>%
  #Remove duplicates based on facilities
  dplyr::select(-facility, available) %>%
  unique()


leeds_libraries <- leaflet(library_date_filter) %>%
#Select tiles we want to use
  addProviderTiles(providers$OpenStreetMap.Mapnik) %>%  # use the default base map which is OpenStreetMap tiles
#Give long, lat and custom popup details
  addCircleMarkers(lng= ~longitude,
              lat = ~latitude,
              color = ~open_colour,
              popup = ~paste0(library,
                              "<br/>Opening hours: ",
                              time))
leeds_libraries
