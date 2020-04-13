# reactiveValues

library(shiny)

ui <- fluidPage(
  sliderInput(inputId = "num", 
    label = "Choose a number", 
    value = 25, min = 1, max = 100),
  submitButton("Submit!"),
  plotOutput("hist"),
  verbatimTextOutput("stats")
)

server <- function(input, output) {
  
  rv <- reactiveValues()
  observe(rv$data <- rnorm(input$num))
  
  output$hist <- renderPlot({
    hist(rv$data)
  })
  output$stats <- renderPrint({
    summary(rv$data)
  })
}

shinyApp(ui = ui, server = server)