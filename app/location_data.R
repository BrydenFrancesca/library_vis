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
  tidyr::spread(variable, hour)
