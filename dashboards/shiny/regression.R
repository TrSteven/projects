library(shiny)

ui <- fluidPage(
  # Give the page a title
  titlePanel("Regression models applied to the cars dataset"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      helpText("The cars dataset contains the speed of cars and the distances taken to stop. 
                With this Shiny app, it is possible to apply a linear or a local regression method to the dataset. 
                For the local regression method, the degree of smoothing can be choosen with a slider."),
      selectInput(inputId = "regression_method",
                  label = "Regression method:",
                  choices = c("Linear Regression", "Local Polynomial Regression"),
                  selected = "Linear Regression"),
      conditionalPanel(condition = "input.regression_method == 'Local Polynomial Regression'",
                       sliderInput("degree_smoothing", "Degree of smoothing:", 
                                   min = 0.2, max = 2.5, value = 1, step = 0.1)),
      selectInput(inputId = "colour",
                  label = "Line colour:",
                  choices = c("Blue", "Green", "Red"),
                  selected = "Blue")
    ),
    
    # Create a spot for the barplot
    mainPanel(
      plotOutput("regression_plot"),
      hr(),
      helpText("Summary statistics of residuals:"),
      verbatimTextOutput("summary_residuals")
    )
  )
)

server <- function(input, output) {
  my_model <- reactive({
    x <- cars$speed
    y <- cars$dist
    
    if(input$regression_method == "Linear Regression"){
      lm(y ~ x)
    } else if (input$regression_method == "Local Polynomial Regression") {
      loess(y ~ x, span = input$degree_smoothing)
    }
    
  })
  
  output$regression_plot <- renderPlot({
    plot(cars$speed, cars$dist, xlab = "Speed (mph)", ylab = "Stopping distance (ft)")
    
    if(input$regression_method == "Linear Regression"){
      abline(my_model(), col = input$colour)
    } else if (input$regression_method == "Local Polynomial Regression") {
      x_new <- seq(1, 25, 0.05)
      lines(x_new, predict(my_model(), newdata = x_new), col = input$colour)
    }
  })
  
  output$summary_residuals <- renderPrint({
    summary(my_model()$residuals)
  })
  
}

shinyApp(ui = ui, server = server)