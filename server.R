library(shiny)
library(ggplot2)
library(ggrepel)
library(scales)
library(leaflet)
library(sf)
library(tigris)
source("models/data_model.R")  # Load the model

server <- function(input, output) {
  # Load the data once and use reactively
  accidents <- load_data()
  
  data <- reactive({
    accidents_summary <- subset(accidents, Severity == input$severity)
    counts <- as.data.frame(table(accidents_summary$State))
    colnames(counts) <- c("State", "Count")
    
    counts
  })
  
  # Horizontal Bar plot for severity
  output$severityPlot <- renderPlot({
    gg_data <- data() 
    ggplot(gg_data, aes(x = reorder(State, -Count), y = Count)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      coord_flip() +
      labs(x = "State Code", y = "Number of Accidents",
           title = paste("Number of Accidents by State with Severity Level", input$severity)) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))
  })
  
  # Line plot for time of day
  output$accidentPlot <- renderPlot({
    summary_data <- accidents %>%
      mutate(TimeOfDay = case_when(
        hour(Start_Time) >= 0 & hour(Start_Time) < 3  ~ "Late Night",
        hour(Start_Time) >= 3 & hour(Start_Time) < 6  ~ "Early Morning",
        hour(Start_Time) >= 6 & hour(Start_Time) < 12 ~ "Morning",
        hour(Start_Time) >= 12 & hour(Start_Time) < 16 ~ "Afternoon",
        hour(Start_Time) >= 16 & hour(Start_Time) < 20 ~ "Evening",
        hour(Start_Time) >= 20 | hour(Start_Time) < 0  ~ "Night"
      )) %>%
      group_by(TimeOfDay) %>%
      summarise(Accidents = n())
    
    summary_data$TimeOfDay <- factor(summary_data$TimeOfDay, levels = c("Late Night", "Early Morning", "Morning", "Afternoon", "Evening", "Night"))
    
    ggplot(summary_data, aes(x = TimeOfDay, y = Accidents / 1000, group = 1)) +
      geom_line() +
      geom_point() +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5)) +
      scale_y_continuous(labels = scales::comma) +
      scale_x_discrete(breaks = levels(summary_data$TimeOfDay),
                                              labels = c("Late Night\n(00:00 - 2:59)", "Early Morning\n(3:00 - 5:59)",
                                                         "Morning\n(6:00 - 11:59)", "Afternoon\n(12:00 - 15:59)",
                                                         "Evening\n(16:00 - 19:59)", "Night\n(20:00 - 23:59)")) +
      labs(title = "Number of Accidents by Time of Day",
           x = "Time of Day",
           y = "Number of Accidents (in thousands)")
  })
  
  # Pie for Weather Condition
  output$weatherPieChart <- renderPlot({
    weather_data <- process_weather_data(accidents)
    
    # Create a new column with combined category name and percentage
    weather_data <- weather_data %>%
      mutate(Legend_Label = paste0(Weather_Category, " (", round(Percentage, 1), "%)"))
    
    ggplot(weather_data, aes(x = "", y = Percentage, fill = Legend_Label)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      theme_void() +
      theme(legend.title = element_blank()) +
      labs(title = "Percentage of Accidents by Weather Category") +
      scale_fill_discrete(name = "", labels = weather_data$Legend_Label)  # Use custom labels
  })
  
  # Definitions for the Weather categories
  output$catRain <- renderText({ HTML("Rain: Includes 'rain', 'drizzle', 'shower'") })
  output$catThunderstorm <- renderText({ HTML("Thunderstorm: Includes 'storm', 'squalls'") })
  output$catClear <- renderText({ HTML("Clear: Includes 'clear'") })
  output$catFair <- renderText({ HTML("Fair: Includes 'fair'") })
  output$catSnow <- renderText({ HTML("Snow: Includes 'snow'") })
  output$catCloud <- renderText({ HTML("Cloud: Includes 'cloud', 'fog'") })
  output$catHaze <- renderText({ HTML("Haze: Includes 'hail', 'haze', 'dust', 'sand', 'smoke'") })
  output$catOthers <- renderText({ HTML("Others: Includes all other weather conditions") })
  
  
  # Choropleth Map
  accidents_by_county <- aggregate_accidents_by_county(accidents)
  counties_geo <- prepare_county_geo()
  
  merged_data <- merge(counties_geo, accidents_by_county, by.x = "NAME", by.y = "County")
  
  # Geographic Distribution - Choropleth Map
  output$accidentMap <- renderLeaflet({
    valid_data <- merged_data[!is.na(merged_data$NumberOfAccidents), ]
    valid_data$NumberOfAccidents <- as.numeric(valid_data$NumberOfAccidents)
    
    max_accidents <- max(valid_data$NumberOfAccidents, na.rm = TRUE)
    intervals <- seq(1, max_accidents, length.out = 6)
    pal <- colorBin("YlOrRd", valid_data$NumberOfAccidents, bins = intervals, na.color = "#808080")
    
    leaflet(valid_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal(NumberOfAccidents),
        fillOpacity = 0.8,
        color = "#BDBDC3",
        weight = 1,
        popup = ~paste(NAME, NumberOfAccidents)
      ) %>%
      setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
      addLegend(pal = pal, values = ~NumberOfAccidents, opacity = 0.7,
                title = "Number of Accidents",
                position = "bottomright",
                labFormat = labelFormat(),
                labels = c(intervals[-length(intervals)], intervals[-1] + 1)) %>%
      setMaxBounds(lng1 = -125, lat1 = 50, lng2 = -66, lat2 = 24) # Set bounds to US
  })
  }

