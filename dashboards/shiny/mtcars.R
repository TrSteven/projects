# load packages
library(shiny)

# Columns for K means clustering + standardize
sel_col <- c("mpg", "disp", "hp", "drat", "wt", "qsec")
K_means_data <- as.data.frame(scale(mtcars[, sel_col]))
names(K_means_data) <- paste(names(mtcars[, sel_col]), "(standardized)")

# Define UI 
ui <- pageWithSidebar(
  headerPanel('K-means clustering for mtcars dataset'),
  sidebarPanel(
    selectInput('xcol', 'X Variable', names(K_means_data)),
    selectInput('ycol', 'Y Variable', names(K_means_data),
                selected = names(K_means_data)[[2]]),
    numericInput('clusters', 'Cluster count', 2,
                 min = 1, max = 5)
  ),
  mainPanel(
    plotOutput('plot1')
  )
)

# Define server 
server <- function(input, output) {
  
  selectedData <- reactive({
    K_means_data[, c(input$xcol, input$ycol)]
  })
  
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  
  output$plot1 <- renderPlot({
    par(mar = c(5.1, 4.1, 0, 1))
    plot(selectedData(),
         col = clusters()$cluster + 1,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })
  
}

# Create a Shiny app
shinyApp(ui = ui, server = server)
