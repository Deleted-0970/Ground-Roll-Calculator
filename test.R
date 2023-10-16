library(tidyverse)
library(googlesheets4) # library to read data from google sheets
library(readxl) # library to read data from excel
options(scipen = 999) # remove scientific notation

# works. If you want to directly important data from google sheets.
# run to authenticate google acc
# data can be moved to an excel or CSV once it is done being edited

# gs4_auth()

# sheets <- gs4_find("Battery/Motor/Prop spec")
# data <- read_sheet(sheets, sheet = "Sheet2")

data <- read_excel("data/volt_rpm_test_data.xlsx")

input <- 45
kv_value <- "20*10"


if (kv_value == "19*10") {
  filtered_data <- data %>%
    filter(Propeller %in% c("19*10", "19*10b"))
} else if (kv_value == "20*10") {
  filtered_data <- data %>%
    filter(Propeller %in% c("20*10", "20*10b", "20*10c", "20*10d"))
} else if (kv_value == "21*10"){
  filtered_data <- data %>%
    filter(Propeller %in% c("21*10", "21*10a"))
}
