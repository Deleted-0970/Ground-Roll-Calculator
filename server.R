library(tidyverse)
library(stringr)
library(readxl) # library to read data from excel
options(scipen = 999) # remove scientific notation

server <- function(input, output) {
  input_motor <-reactive({input$select_motor})
  input_prop <- reactive({input$select_prop})
  user_input <- reactive({input$input_volt})
  
  # selecting the data file to load
  data <- reactive({
    selected <- input_motor()
    data <- read_excel(paste0("data/", selected))
    data
  })
  
  # filtering data based on propeller selected
  filtered_data <- reactive({
    prop <- input_prop()
    
    filtered_data <- data() %>%
      filter(str_detect(Propeller, prop))
    
    filtered_data
  })
  
  # finding voltage range
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
  # helper output to display voltage range
  output$range_label <- renderText({
    voltage_range()
  })
  
  # input voltage and find closest voltage in data set
  output$voltage <- renderText({
    input <- user_input()
    
    result_voltage <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%
      pull("Voltage(V)")
    result_voltage
  })
  
  # output RPM based on input voltage
  output$rpm <- renderText({
    input <- user_input()
    
    result_rpm <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%   
      pull("RPM")
    result_rpm
  })
  
  # since the data sets are weird for propellers (e.g. mulitple 19*10 data)
  output$prop_note <- renderText({
    input <- user_input()
    
    result_prop <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%   
      pull("Propeller")
    result_prop
  })
  
  # takes propeller and RPM and turns it to thrust
  # currently all it does is take a propeller and return thrust at 1000 rpm
  output$thrust <- renderText({
    prop <- input_prop()
    # Read the entire .dat file with fill = TRUE, skipping rows 22 and 23
    prop_data <- read.table(paste0("data/PER3_", prop, ".dat"), header = TRUE, fill = TRUE, skip = 21, nrows = 372)
    
    # expected columns from dat file
    expected_columns <- 15
    
    # Check and correct the number of columns
    if (ncol(prop_data) < expected_columns) {
      prop_data <- cbind(prop_data, matrix(NA, nrow = nrow(prop_data), 
                                           ncol = expected_columns - ncol(prop_data)))
    }
    
    # Create a vector of rows to remove based on the specified pattern
    rows_to_remove <- c(1, unlist(sapply(seq(3, nrow(prop_data), 33), function(start) start + 0:31)))
    prop_data <- prop_data[-rows_to_remove, ]
    
    # Reset row names
    rownames(prop_data) <- NULL
    
    # Extract the value under the "Thrust" column in the first row
    thrust_value <- prop_data$Thrust.1[1]
    
    thrust_value
  })
}
