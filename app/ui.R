library(shiny)
library(shinyMobile)
library(shinyWidgets)
source("location_data.R")


ui = f7Page(
  title = "My app",
  init = f7Init(skin = "md", theme = "light"),
  f7TabLayout(
    tags$head(
      tags$script(
        "$(function(){
$('#tapHold').on('taphold', function () {
app.dialog.alert('Tap hold fired!');
});
});
"
      )
    ),
##Panels appearing on left and right
    panels = tagList(
      f7Panel(title = "Choose date and time:",
              side = "left",
              theme = "light",
              effect = "cover",
    #Date selection
    f7DatePicker(
        inputId = "map_date",
        label = "Choose date of interest",
        value = Sys.Date(),
        multiple = FALSE
        ),
  #Time input
    f7Text(
      inputId = "map_time",
      label = "Enter time of interest",
      value = format(Sys.time(), "%H:%M")
    ),
  #Selectize to choose facilities
  f7AutoComplete(
    inputId = "map_facilities",
    placeholder = "",
    openIn = "popup",
    multiple = TRUE,
    label = "Facilities required?",
    choices = c("Any", unique(library_date_filter$facility))
  )
    ), #End of left panel

      f7Panel(title = "Right Panel", side = "right", theme = "dark", "Blabla", effect = "cover")
    ),
    navbar = f7Navbar(
      title = "Select menus on left",
      hairline = FALSE,
      shadow = TRUE,
      left_panel = TRUE,
      right_panel = TRUE
    ),
    f7Tabs(
      animated = FALSE,
      swipeable = TRUE,
      f7Tab(
        tabName = "Maps",
        icon = f7Icon("map"),
        active = TRUE,
        f7Shadow(
          intensity = 10,
          hover = TRUE,
    ##Map tab
          f7Card(
            title = "Map of Library locations",
            leafletOutput("leeds_lib_map")
          )
        )
      ),
      f7Tab(
        tabName = "Loans",
        icon = f7Icon("today"),
        active = FALSE,
        f7Shadow(
          intensity = 10,
          hover = TRUE,
          f7Card(
            title = "Numbers of library loans by year",
          plotlyOutput("lending_plot"),
          )
        )
      ),
      f7Tab(
        tabName = "Tab 3",
        icon = f7Icon("cloud_upload"),
        active = FALSE,
        f7Shadow(
          intensity = 10,
          hover = TRUE,
          f7Card(
            title = "Card header",
            f7SmartSelect(
              inputId = "variable",
              label = "Variables to show:",
              c("Cylinders" = "cyl",
                "Transmission" = "am",
                "Gears" = "gear"),
              multiple = TRUE,
              selected = "cyl"
            ),
            tableOutput("data"),
            footer = tagList(
              f7Button(label = "My button", src = "https://www.google.com"),
              f7Badge("Badge", color = "green")
            )
          )
        )
      )
    )
  )
)
