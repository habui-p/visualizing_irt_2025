ui <- fluidPage(
  useShinyjs(),
  
  # Customize styles
  tags$head(
    tags$style(HTML("
                    .info-toggle-btn {
        background-color: #fce303;
        border: 2px solid #f39c12;
        color: #333333;
        font-style: italic;
        font-weight: bold;
        border-radius: 8px;
        padding: 6px 12px;
        margin-top: 10px;
        margin-bottom: 5px;
        cursor: pointer;
      }
      .info-toggle-btn:hover {
        background-color: #ffe066;
      }"))
  ),
  
  titlePanel("Interactive IRT App: Motivation to Exercise"),
  
  
  tabsetPanel(
    
    # Create a scenario tab
    tabPanel("Scenario",
             br(),
             h4("Scenario: Predicting Exercise Behavior"),
             p("You surveyed 500 students about their motivation to exercise. Each item is a statement (e.g.,"),
             tags$em('"I feel more energized after exercising."'), 
             p("Participants responded with 4 options: 1 = Totally disagree, 2 = Somewhat disagree, 3 = Somewhat agree, and 4 = Totally agree."),
             p("We will explore how item response theory (IRT) can model and visualize the data."),
             br(),
             h5("Below are the five items in the survey:"),
             tags$ol(
               lapply(item_text, tags$li)
             )
    ),
    
    # Create an ICC tab
    tabPanel("Item Characteristic Curves (ICC)",
             actionButton("toggle_icc", "What is this?", class = "info-toggle-btn"),
             hidden(
               div(id = "icc_info",
                   tags$ul(
                     tags$li("ICCs show how the probability of endorsing an item/getting an item correct changes with theta (levels of ability/motivation)."),
                     tags$li("Each curve represents one item. Steeper curves show greater discrimination (a) or how an item better differentiates between individuals given a certain theta value."),
                     tags$hr()
                   )
               )
             ),
             sidebarLayout(
               sidebarPanel(
                 selectInput("model", "IRT Model", c("1PL (Rasch)", "2PL", "3PL")),
                 sliderInput("b_shift", "Ability (θ)",  -4, 4, 0, 0.1),
                 checkboxGroupInput("items", "Select Items", choices = item_names, selected = item_names),
                 
                 # Option to show the discrimination (a) slider only in 2PL or 3PL
                 conditionalPanel(
                   condition = "input.model != '1PL (Rasch)'",
                   h5("Discrimination (a)"),
                   lapply(1:5, function(i){
                     sliderInput(paste0("a", i), paste0("a", i, " (", item_names[i], ")"),
                                 min = 0.2, max = 3, value = 1, step = 0.05)
                   })
                 ),
                 
                 # Option to show the guessing (c) slider only in 3PL
                 conditionalPanel(
                   condition = "input.model == '3PL'",
                   sliderInput("c_slider", "Guessing (c)", min = 0, max = 0.5, value = 0.2, step = 0.01)
                 ),
                 
                 checkboxInput("show_params", "Show item parameters on plot", value = TRUE)
               ),
               mainPanel(plotOutput("icc_plot", height = "600px"))
             )
    ),
    
    # Create a TCC tab
    tabPanel("Test Characteristic Curve (TCC)",
             actionButton("toggle_tcc", "What is this?", , class = "info-toggle-btn"),
             hidden(
               div(id = "tcc_info",
                   tags$ul(
                     tags$li("TCC shows the summation of all ICC values, helping us understand how the overall test looks like across different ability levels."),
                     tags$hr()
                   )
               )
             ),
             plotOutput("tcc_plot", height = "500px")
    ),
    
    # Create an IIC tab
    tabPanel("Item Information Curves (IIC)",
             actionButton("toggle_iic", "What is this?", class = "info-toggle-btn"),
             hidden(
               div(id = "iic_info",
                   tags$ul(
                     tags$li("IICs show how much information (precision) a single item provides at each ability level."),
                     tags$li("A higher peak means the item is more useful/provides more information at that range of ability."),
                     tags$hr()
                   )
               )
             ),
             plotOutput("iic_plot", height = "500px")
    ),
    
    # Create a TIC tab
    tabPanel("Test Information Curve (TIC) & Standard Error (SE) Distribution",
             actionButton("toggle_tic", "What is this?", , class = "info-toggle-btn"),
             hidden(
               div(id = "tic_info",
                   tags$ul(
                     tags$li("TIC combines information from all items to show how precisely the entire test measures at different levels of ability."),
                     tags$li("SE is the inverse of information: higher information means lower error."),
                     tags$hr()
                   )
               )
             ),
             plotOutput("tif_plot", height = "500px")
    )
  )
)