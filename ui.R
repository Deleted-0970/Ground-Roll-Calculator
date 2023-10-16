ui <- fluidPage(
  h1("Ground Roll Calculator"),
  
  selectInput("select_motor", label = "select motor (placeholder)", 
              choices = list(
                "AT7215" = 7215
                ),
              selected = 7215),
  
  selectInput("select_kv", label = "select kv (placeholder)", 
              choices = list(
                "kv200" = 200
                ), 
              selected = 200),
  selectInput("select_prop", label = "select propeller", 
              choices = list(
                "19*10" = "19*10",
                "20*10" = "20*10",
                "21*10" = "21*10"
              ), 
              selected = "19*10"),
  
  
  numericInput("input_volt", label = textOutput("range_label"), value = 45),
  
  h4("closest voltage: ", textOutput("voltage")),
  h4("corresponding rpm: ", textOutput("rpm")),
  h4("note on prop stats: ", textOutput("prop_note"))
)