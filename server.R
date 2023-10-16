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


server <- function(input, output) {
  input_prop <- reactive({input$select_prop})
  user_input <- reactive({input$input_volt})
  
  filtered_data <- reactive({
    kv_value <- input_prop()
    
    if (kv_value == "19*10") {
      filtered_data <- data %>%
        filter(Propeller %in% c("19*10", "19*10b"))
    } else if (kv_value == "20*10") {
      filtered_data <- data %>%
        filter(Propeller %in% c("20*10", "20*10b", "20*10c", "20*10d"))
    } else if (kv_value == "21*10"){
      filtered_data <- data %>%
        filter(Propeller %in% c("21*10", "21*10b"))
    } else {
      filtered_data <- data %>%
        filter(Propeller == kv_value)
    }
    
    filtered_data
  })
  
  voltage_range <- reactive({
    filtered <- filtered_data()
    
    if (nrow(filtered) == 0) {
      return("No data available")
    }
    
    min_volt <- min(filtered$`Voltage(V)`, na.rm = TRUE)
    max_volt <- max(filtered$`Voltage(V)`, na.rm = TRUE)
    
    if (is.finite(min_volt) && is.finite(max_volt)) {
      return(paste("volts (", min_volt, ", ", max_volt, ")"))
    } else {
      return("No valid voltage range")
    }
  })
  
  output$range_label <- renderText({
    voltage_range()
  })
  
  output$voltage <- renderText({
    input <- user_input()
    
    result_voltage <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%
      pull("Voltage(V)")
    result_voltage
  })
  
  output$rpm <- renderText({
    input <- user_input()
    
    result_rpm <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%   
      pull("RPM")
    result_rpm
  })
  
  output$prop_note <- renderText({
    input <- user_input()
    
    result_prop <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%   
      pull("Propeller")
    result_prop
  })
}
