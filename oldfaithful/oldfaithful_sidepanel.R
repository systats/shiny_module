# http://shiny.rstudio.com/gallery/faithful.html

library(shiny)

faithfulHistInput <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(inputId = ns("n_breaks"),
                label = "Number of bins in histogram (approximate):",
                choices = c(10, 20, 35, 50),
                selected = 20),
    
    checkboxInput(inputId = ns("individual_obs"),
                  label = strong("Show individual observations"),
                  value = FALSE),
    
    checkboxInput(inputId = ns("density"),
                  label = strong("Show density estimate"),
                  value = FALSE),
    
    # Display this only if the density is shown.
    # Note kludgey way to pass condition via javascript.
    conditionalPanel(condition = paste0("input['", ns("density"), "'] == true"),
                     sliderInput(inputId = ns("bw_adjust"),
                                 label = "Bandwidth adjustment:",
                                 min = 0.2, max = 2, value = 1, step = 0.2)
    )
  )
}
faithfulHistUI <- function(id) {
  ns <- NS(id)
  plotOutput(outputId = ns("hist"), height = "300px")
}

faithfulHist <- function(input, output, session) {
  ns <- session$ns
  
  output$hist <- renderPlot({
    hist(faithful$eruptions,
         probability = TRUE,
         breaks = as.numeric(input$n_breaks),
         xlab = "Duration (minutes)",
         main = "Geyser eruption duration")
    if (input$individual_obs) {
      rug(faithful$eruptions)
    }
    if (input$density) {
      dens <- density(faithful$eruptions,
                      adjust = input$bw_adjust)
      lines(dens, col = "blue")
    }
  })
}

server <- function(input, output) {
  callModule(faithfulHist, "faithful")
  }

ui <- fluidPage(
  titlePanel("Old Faithful"),
  
  sidebarLayout(
    sidebarPanel(
      faithfulHistInput("faithful")
    ),
    mainPanel(
      faithfulHistUI("faithful")
    )
  )
)
    
shinyApp(ui, server)


