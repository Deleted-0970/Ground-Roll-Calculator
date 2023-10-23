library(tidyverse)
library(stringr)
library(readxl) # library to read data from excel
options(scipen = 999) # remove scientific notation

# datasets go here
AT7215KV200_data <- read_excel("data/AT7215KV200.xlsx")
AT5330LV220_data <- read_excel("data/AT5330KV220.xlsx")


server <- function(input, output) {
  input_motor <-reactive({input$select_motor})
  input_prop <- reactive({input$select_prop})
  user_input <- reactive({input$input_volt})
  
  # add an if else statement here if more datasets are added
  data <- reactive({
    selected <- input_motor()
    data <- read_excel(paste0("data/", selected))
    data
  })
  
  filtered_data <- reactive({
    prop <- input_prop()
    
    prop_pattern <- gsub("\\*", "\\\\*", prop) # esc seq since * is special char
    
    filtered_data <- data() %>%
      filter(str_detect(Propeller, prop_pattern))
    
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
      return(paste0("volts (", min_volt, ", ", max_volt, "): "))
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
