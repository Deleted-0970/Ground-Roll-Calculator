library(tidyverse)
library(dplyr)
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



# Read the entire .dat file with fill = TRUE, skipping rows 22 and 23
all_data <- read.table("data/PER3_19x10E.dat", header = TRUE, fill = TRUE, skip = 21, nrows = 372)

# Define the expected number of columns in your data
expected_columns <- 15

# Check and correct the number of columns
if (ncol(all_data) < expected_columns) {
  all_data <- cbind(all_data, matrix(NA, nrow = nrow(all_data), ncol = expected_columns - ncol(all_data)))
}

# Create a vector of rows to remove based on the specified pattern
rows_to_remove <- c(1, unlist(sapply(seq(3, nrow(all_data), 33), function(start) start + 0:31)))

# Remove the specified rows
all_data <- all_data[-rows_to_remove, ]

# Reset row names
rownames(all_data) <- NULL

all_data <- all_data %>% mutate(RPM = row_number() * 1000)

all_data <- rbind(rep(0.00, ncol(all_data)), all_data)

rpm <- 4494
thrust <- 0
  rounded_num <- round(rpm / 1000, 0)
  higher_RPM <- (rounded_num + 1) * 1000
  lower_RPM <- (rounded_num) * 1000
  higher_thrust <- all_data %>% filter(RPM == higher_RPM) %>% pull(Thrust.1)
  higher_thrust <- as.numeric(higher_thrust)
  lower_thrust <- all_data %>% filter(RPM == lower_RPM) %>% pull(Thrust.1)
  lower_thrust <- as.numeric(lower_thrust)
  
  RPM_diff <- higher_RPM - lower_RPM 
  thrust <- ((rpm - lower_RPM) * (higher_thrust - lower_thrust) / RPM_diff) + lower_thrust
  thrust

# View the first few rows of the updated data
View(all_data)
                    