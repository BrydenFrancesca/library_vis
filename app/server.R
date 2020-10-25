source("Location_data.R")

server = function(input, output) {

##Calculation of time from input; convert from text to numeric
  now_time <- reactive({
  as.numeric(gsub("\\:", "", input$map_time))
  })

#Reactive for overall library map data
  filtered_library_data <- reactive({
    library_date_filter %>%
      #Set colour based on whether library is open on at that time or not
      #If lunchtime shutting is NA, just check if time now is greater than opening and less than closing
      dplyr::mutate(open_colour = dplyr::case_when(
        is.na(time_afternoon_from) & now_time() > time_morning_from & now_time() < time_morning_to ~ "#228B22",
        #If it is closed at lunchtime, does it fall between the open periods
        (now_time() > time_morning_from & now_time() < time_morning_to) | (now_time() > time_afternoon_from & now_time() < time_afternoon_to) ~ "#228B22",
        #Otherwise closed
        TRUE ~ "#FF0000")) %>%
    #Filter out only today's values
    dplyr::filter(day == tolower(weekdays(input$map_date))) %>%
      #Remove duplicates based on facilities
      dplyr::select(-facility, available) %>%
      unique()
  })

#Render map in leaflet
  output$leeds_lib_map <- renderLeaflet({
   leaflet(filtered_library_data()) %>%
      #Select tiles we want to use
      addProviderTiles(providers$OpenStreetMap.Mapnik) %>%  # use the default base map which is OpenStreetMap tiles
      #Give long, lat and custom popup details
      addCircleMarkers(lng= ~longitude,
                       lat = ~latitude,
                       color = ~open_colour,
                       popup = ~paste0("<b>", library, "</b>",
                                       "<br/>",address_line_1,
                                       "<br/>",address_line_2,
                                       "<br/>",postcode,
                                       "<br/><em/>Opening hours: </em>",
                                       time))
  })

  output$distPlot2 <- renderPlot({
    dist <- switch(
      input$obs2,
      norm = rnorm,
      unif = runif,
      lnorm = rlnorm,
      exp = rexp,
      rnorm
    )
    hist(dist(500))
  })
  output$data <- renderTable({
    mtcars[, c("mpg", input$variable), drop = FALSE]
  }, rownames = TRUE)
}
