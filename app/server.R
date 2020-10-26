source("location_data.R")
source("loan_data.R")
source("wordcloud_2a.R")

server = function(input, output) {
##Library mapping----------------------
##Calculation of time from input; convert from text to numeric
  now_time <- reactive({
  as.numeric(gsub("\\:", "", input$map_time))
  })

#Reactive for library map data filtered by date and time
  date_time_library_data <- reactive({
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
    dplyr::filter(day == tolower(weekdays(input$map_date)))
  })

##Function to filter unless set to "any"
  filtered_library_data <- reactive({
  if(mean(input$map_facilities == "Any") == 1){
    date_time_library_data() %>%
      #Remove duplicates based on facilities
      dplyr::select(-facility, available) %>%
      unique()
  } else{
    date_time_library_data() %>%
      #Filter based on facilities being available
      dplyr::filter(facility %in% input$map_facilities & available == 1)  %>%
      #Remove duplicates based on facilities
      dplyr::select(-facility, available) %>%
      unique()
  }
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

  ##Library loan numbers graph----------------
  ##Filter lending numbers dataset dependent on input
  loan_numbers <- reactive({
    if(input$region == "Comparison"){
    loan_data_all %>%
      dplyr::group_by(library = region, year) %>%
      dplyr::summarise(loans = sum(loans, na.rm = T))
    } else{
    loan_data_all %>%
      dplyr::filter(region == input$region)
      }
  })

  ##Lending numbers plot
  output$lending_plot <- renderPlotly({
    plot_ly(loan_numbers(),
            x = ~year,
            y = ~loans,
            type = 'bar',
            color = ~library,
            text = ~library,
            hovertemplate = paste(
              "<b>%{text}</b><br><br>",
              "Loans: %{y:.0,f}<br>",
              "Year: %{x:.0}<br>",
              "<extra></extra>")) %>%
      layout(barmode = 'stack', showlegend = FALSE)
  })

  output$title_cloud <- wordcloud2::renderWordcloud2({
  title_words <- data.table::fread("../data/title_words.csv")

    wordcloud2a(data = title_words,
                           size=1.6,
                           color='random-light',
                           backgroundColor="black")
})
}
