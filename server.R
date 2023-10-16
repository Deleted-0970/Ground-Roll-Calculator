library(tidyverse)
library(googlesheets4) # library to read data from google sheets
options(scipen = 999) # remove scientific notation

# run to authenticate google acc
# data can be moved to an excel or CSV once it is done being edited

# gs4_auth()

sheets <- gs4_find("Battery/Motor/Prop spec")
data <- read_sheet(sheets, sheet = "Sheet2")


volt_rpm <- data %>% select("Voltage(V)", "RPM")

server <- function(input, output) {
  
}
