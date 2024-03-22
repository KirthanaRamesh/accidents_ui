library(shiny)
library(shinydashboard)
library(leaflet)
library(shinycssloaders)

ui <- dashboardPage(
  dashboardHeader(title = "US Traffic Accidents Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Severity Level", tabName = "severity", icon = icon("th")),
      menuItem("Geography Based", tabName = "geography", icon = icon("globe")),
      menuItem("Weather Based", tabName = "weather", icon = icon("cloud")),
      menuItem("Time Based", tabName = "time", icon = icon("clock"))
    ),
    div(style = "position:absolute; bottom:0; width:auto; text-align:left; padding-bottom:20px; padding-left:20px; color:grey;",
         "Developed by Kirthana Ramesh using R 4.3.1 and Shiny")
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              h2("Dashboard content"),
              h4("This dashboard offers a comprehensive overview of traffic accidents, providing insights into various aspects such as severity, geographical distribution, weather conditions, and time-based trends. Navigate through the tabs to explore detailed analyses and uncover patterns that can help in understanding and mitigating road accidents effectively.")
      ),
      tabItem(tabName = "severity",
              h2("Accidents Based on Severity Level"),
              h4("This section delves into the severity of traffic accidents, categorizing them into different levels from critical to low level. Utilize the dropdown menu to select a specific severity level and view detailed statistical analyses. Charts and graphs in this tab will illustrate the distribution and trends of accidents across the selected severity, enabling a focused examination of their impact and frequency."),
              selectInput("severity", "Select severity level:",
                          choices = list("1 - Critical" = 1, "2 - Significant" = 2,
                                         "3 - Minor" = 3, "4 - Low level" = 4),
                          selected = 1),
              plotOutput("severityPlot", height = "800px") %>% withSpinner()
      ),
      tabItem(tabName = "geography",
              h2("Geographic Distribution of Accidents based on Counties"),
              h4("The Choropleth map vividly illustrates the number of traffic accidents by county. This spatial analysis enables to discern the concentration of incidents across different regions, revealing hotspots where road safety measures could be most impactful. It enhances the visualization of data, allowing for easy comparison between counties and facilitating a deeper understanding of areas with elevated accident frequencies."),
              br(),
              leafletOutput("accidentMap") %>% withSpinner()
      ),
      tabItem(tabName = "weather",
              h2("Accidents Based on Weather Conditions"),
              div(class = "container-fluid",
                  div(class = "row",
                      div(class = "col-md-4",  # Adjust the column width as needed
                          style = "padding-right: 20px;",  # Add padding to align with the pie chart
                          h4("This section offers an analytical perspective on how different weather conditions correlate with the occurrence of traffic accidents."),
                          h4("The pie chart visualization provides a clear and immediate understanding of the proportion of accidents associated with specific weather conditions. The accompanying definitions offer further insight into the categorization criteria, ensuring transparency and clarity in our analysis."),
                          br(),
                          strong("Weather Category Definitions:"),
                          tags$ul(
                            tags$li("Rain: Includes 'rain', 'drizzle', 'shower'"),
                            tags$li("Thunderstorm: Includes 'storm', 'squalls'"),
                            tags$li("Clear: Includes 'clear'"),
                            tags$li("Fair: Includes 'fair'"),
                            tags$li("Snow: Includes 'snow'"),
                            tags$li("Cloud: Includes 'cloud', 'fog'"),
                            tags$li("Haze: Includes 'hail', 'haze', 'dust', 'sand', 'smoke'"),
                            tags$li("Others: Includes all other weather conditions")
                          )
                      ),
                      div(class = "col-md-8",  
                          plotOutput("weatherPieChart") %>% withSpinner()
                      )
                  )
              )
      ),
      tabItem(tabName = "time",
              h2("Accidents Based on the Time of the Day"),
              h4("In the Time Based tab, delve into the analysis of traffic accidents occurring at various times throughout the day. This section categorizes accidents into distinct time periods: late night, early morning, morning, afternoon, evening, and night. A line graph illustrates the frequency of accidents during these intervals, providing a clear visual representation of when accidents are most and least likely to occur. "),
              plotOutput("accidentPlot") %>% withSpinner()
      )
    )
  )
)
