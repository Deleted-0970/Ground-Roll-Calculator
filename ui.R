ui <- fluidPage(
  h1("Ground Roll Calculator"),
  
  selectInput("select_motor", label = "select motor", 
              choices = list(
                "AT7215 kv200" = "AT7215KV200.xlsx",
                "AT5330 kv220" = "AT5330KV220.xlsx"
                ),
              selected = "AT7215 kv200"),
  selectInput("select_prop", label = "select propeller", 
              choices = list(
                "18*10" = "18*10",
                "19*10" = "19*10",
                "20*10" = "20*10",
                "21*10" = "21*10"
              ), 
              selected = "19*10"),
  
  
  numericInput("input_volt", label = textOutput("range_label"), value = 45, step = 0.1),
  p("note~ step size is 0.1"),
  
  h4("closest voltage: ", textOutput("voltage")),
  h4("corresponding rpm: ", textOutput("rpm")),
  h4("note on prop stats: ", textOutput("prop_note"))
)