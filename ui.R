ui <- fluidPage(
  titlePanel(strong("Ground Roll Calculator")),
  sidebarLayout(
    sidebarPanel(
      div(
        h4("Calculate Thrust", style = "color: #333; font-size: 18px; font-weight: bold; margin-bottom: 15px;")
      ),
      
      # put more data files here:
      selectInput("select_motor", label = "select motor", 
                  choices = list(
                    "AT7215 kv200" = "AT7215KV200.xlsx",
                    "AT5330 kv220" = "AT5330KV220.xlsx"
                  ),
                  selected = "AT5330KV220.xlsx"),
      
      # if more propeller sizes, put them here:
      selectInput("select_prop", label = "select propeller", 
                  choices = list(
                    "18x10" = "18x10",
                    "19x10" = "19x10",
                    "20x10" = "20x10",
                    "21x10" = "21x10"
                  ), 
                  selected = "19x10"),
      
      
      numericInput("input_volt", label = textOutput("range_label"), value = 43.7, step = 0.1),
      
      div(
        style = "border-top: 2px solid #333; margin-bottom: 15px;",
        h4("Coeffficients", style = "color: #333; font-size: 18px; font-weight: bold; margin-bottom: 15px;")
      ),
      
      numericInput("input_weight", label = "Weight lb (W)", value = 49, step = 0.1),
      numericInput("input_thrust", label = "thrust (T). Not Connected To Backend", value = 0.0, step = 0.1),
      numericInput("input_Rinf", label = "wow (R_inf)", value = 1.225, step = 0.001),
      numericInput("input_Clmax", label = "hi (C_lmax)", value = 1.2, step = 0.01),
      numericInput("input_plan", label = "PLANFORM:D (S)", value = 0.6858, step = 0.1),
      numericInput("input_CD", label = ":D (C_D)", value = 0.4, step = 0.01),
      numericInput("input_U", label = "uwu (u)", value = 0.1, step = 0.01)
      
    ),
    mainPanel(
      h4("closest voltage: ", textOutput("voltage")),
      h4("corresponding rpm: ", textOutput("rpm")),
      h4("note on prop stats: ", textOutput("prop_note")),
      h4("thrust (N): ", textOutput("thrust")),
      h3("ground roll (feet): ", textOutput("ground_roll")),
      plotlyOutput(outputId = "graph_plotly")
    )
  ),
  
)