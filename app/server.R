source("Location_data.R")

server = function(input, output) {

  filtered_library_data <- reactive({
    library_date_filter %>%
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
                       popup = ~paste0(library,
                                       "<br/>Opening hours: ",
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
