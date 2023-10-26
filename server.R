library(tidyverse)
library(stringr)
library(dplyr)
library(plotly)
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
  rpm <- reactive({
    input <- user_input()
    
    result_rpm <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%   
      pull("RPM")
    result_rpm
  })
  
  output$rpm <- renderText({
    rpm()
  })
  
  # since the data sets are weird for propellers (e.g. multiple 19*10 data)
  output$prop_note <- renderText({
    input <- user_input()
    
    result_prop <- filtered_data() %>%
      mutate(Difference = abs(`Voltage(V)` - input)) %>%
      filter(Difference == min(Difference)) %>%   
      pull("Propeller")
    result_prop
  })
  
  prop_data <- reactive({
    prop <- input_prop()
    # Read the entire .dat file with fill = TRUE, skipping rows 22 and 23
    prop_data <- read.table(paste0("data/PER3_", prop, "E.dat"), header = TRUE, 
                            fill = TRUE, skip = 21, nrows = 372)
    
    # expected columns from dat file
    expected_columns <- 15
    
    # Check and correct the number of columns
    if (ncol(prop_data) < expected_columns) {
      prop_data <- cbind(
        prop_data, 
        matrix(NA, nrow = nrow(prop_data), 
               ncol = expected_columns - ncol(prop_data)
        )
      )
    }
    
    # Create a vector of rows to remove
    rows_to_remove <- c(1, unlist(sapply(seq(3, nrow(prop_data), 33), 
                                         function(start) start + 0:31)))
    prop_data <- prop_data[-rows_to_remove, ]
    
    # Reset row names
    rownames(prop_data) <- NULL
    
    # add a column for RPM    
    prop_data <- prop_data %>% mutate(RPM = row_number() * 1000)
    # Create a row of zeros with the same number of columns as prop_data
    zero_row <- rep(0.00, ncol(prop_data))
    
    # Add the zero row to the top of prop_data
    prop_data <- rbind(zero_row, prop_data)
    prop_data
  })
  
  # takes propeller and RPM and turns it to thrust
  # currently all it does is take a propeller and return thrust at 1000 rpm
  thrust <- reactive({

    
    prop_data <- prop_data()
    rpm <- rpm()
    rounded_num <- round(rpm / 1000, 0)
    higher_RPM <- (rounded_num + 1) * 1000
    lower_RPM <- (rounded_num) * 1000
    higher_thrust <- prop_data %>% filter(RPM == higher_RPM) %>% pull(Thrust.1)
    higher_thrust <- as.numeric(higher_thrust)
    lower_thrust <- prop_data %>% filter(RPM == lower_RPM) %>% pull(Thrust.1)
    lower_thrust <- as.numeric(lower_thrust)
    
    RPM_diff <- higher_RPM - lower_RPM 
    thrust <- ((rpm - lower_RPM) * (higher_thrust - lower_thrust) / RPM_diff) + lower_thrust
    
    coefficient <- 2
    
    thrust <- thrust * coefficient
    thrust
  })
  
  output$thrust <- renderText({
    thrust()
  })
  
  ground_roll <- reactive({
    stall_Vel <- sqrt(2 * input$input_weight / (input$input_Rinf * input$input_plan * input$input_Clmax))
    D <- 0.5 * input$input_Rinf * input$input_plan * input$input_CD * ((0.7 * stall_Vel) ^ 2) 
    L <- 0.5 * input$input_Rinf * input$input_plan * input$input_Clmax * ((0.7 * stall_Vel) ^ 2)
    numerator <- 1.44 * (input$input_weight ^ 2)
    denominator <- 9.8 * input$input_Rinf * (thrust() - (D + (input$input_U * (input$input_weight - L))))
    ground_roll <- numerator / denominator
    
    # convert meters to feet
    ground_roll <- ground_roll * 3.2808399
    
    ground_roll
  })
  
  output$ground_roll <- renderText({
    ground_roll()
  })
  
  output$graph_plotly <- renderPlotly({
    prop_data <- prop_data()
    prop_data$Thrust.1 <- as.numeric(prop_data$Thrust.1)
    p <- ggplot(prop_data, aes(x = RPM, y = Thrust.1)) +
      geom_point() +  
      labs(x = "RPM", y = "Thrust", title = "Graph !!")
    
    plotly_plot <- ggplotly(p)
    
    plotly_plot
  })
}
