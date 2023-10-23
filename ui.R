ui <- fluidPage(
  h1("Ground Roll Calculator"),
  
  # put more data files here:
  selectInput("select_motor", label = "select motor", 
              choices = list(
                "AT7215 kv200" = "AT7215KV200.xlsx",
                "AT5330 kv220" = "AT5330KV220.xlsx"
                ),
              selected = "AT7215 kv200"),
  
  # if more propeller sizes, put them here:
  selectInput("select_prop", label = "select propeller", 
              choices = list(
                "18x10" = "18x10",
                "19x10" = "19x10",
                "20x10" = "20x10",
                "21x10" = "21x10"
              ), 
              selected = "19x10"),
  
  
  numericInput("input_volt", label = textOutput("range_label"), value = 45, step = 0.1),
  p("note~ step size is 0.1"),
  
  h4("closest voltage: ", textOutput("voltage")),
  h4("corresponding rpm: ", textOutput("rpm")),
  h4("note on prop stats: ", textOutput("prop_note")),
  h4("thrust (Nm): ", textOutput("thrust")),
  h5("note that currently \"thrust\" is currently just displaying thrust at 1000rpm for the selected prop")
  
)