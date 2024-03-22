# model.R
library(dplyr)
library(readr)
library(lubridate)
library(tigris)
library(sf)

options(tigris_class = "sf")

# Function to read and preprocess the data
load_data <- function() {
  # Read the CSV file only once and use it throughout the app
  accidents <- read.csv("C:/Users/JANA/Downloads/part1-xaa.csv/part1-xaa.csv")
  
  # Process the date and time
  accidents$Start_Time <- as.POSIXct(accidents$Start_Time, format = "%Y-%m-%d %H:%M:%S")
  
  accidents$Weather_Condition <- as.character(accidents$Weather_Condition)
  
  return(accidents)
}

categorize_weather <- function(weather_condition) {
  if (grepl("rain|drizzle|shower", weather_condition, ignore.case = TRUE)) {
    "Rain"
  } else if (grepl("storm|squalls", weather_condition, ignore.case = TRUE)) {
    "Thunderstorm"
  } else if (grepl("clear", weather_condition, ignore.case = TRUE)) {
    "Clear"
  } else if (grepl("fair", weather_condition, ignore.case = TRUE)) {
    "Fair"
  } else if (grepl("snow", weather_condition, ignore.case = TRUE)) {
    "Snow"
  } else if (grepl("cloud|fog", weather_condition, ignore.case = TRUE)) {
    "Cloud"
  } else if (grepl("hail|haze|dust|sand|smoke", weather_condition, ignore.case = TRUE)) {
    "Haze"
  } else {
    "Others"
  }
}

process_weather_data <- function(accidents) {
  accidents %>%
    mutate(Weather_Category = sapply(Weather_Condition, categorize_weather)) %>%
    group_by(Weather_Category) %>%
    summarise(Count = n()) %>%
    mutate(Percentage = Count / sum(Count) * 100)
}

# Function to aggregate accidents by county
aggregate_accidents_by_county <- function(data) {
  data %>%
    group_by(County) %>%
    summarise(NumberOfAccidents = n())
}

prepare_county_geo <- function() {
  counties_geo <- counties(class = "sf") %>%
    st_transform(crs = 4326)
  return(counties_geo)
}
