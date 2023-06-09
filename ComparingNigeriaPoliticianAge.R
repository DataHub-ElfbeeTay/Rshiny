library(shiny)
library(dplyr)
library(ggplot2)

raw_data <- read.csv("NigFinal.csv")
str(raw_data)
attach(raw_data)

ui <- fluidPage(
  theme = shinytheme("yeti"),
  useShinyjs(),
  inlineCSS(appCSS),
  titlePanel("Nigeria Governors and Deputy Governors Age",
             windowTitle = "Nigerian Politician app"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      pickerInput("state_input",
                  label = "Select states of interest",
                  choices = unique(State_Name),
                  multiple = TRUE,
                  options = list(`actions-box` = TRUE),
                  selected = "Abia State"),
      pickerInput("position",
                  label = "Select position",
                  choices = unique(Position_Name),
                  selected = unique(Position_Name),
                  multiple = TRUE,
                  options = list(`actions-box` = TRUE)),
      htmlOutput("lines")
    ),
    mainPanel(
      width = 8,
      tabsetPanel(
        id = 'tabs',
        selected = 'Total',
        tabPanel(
          "Title Page",
          tags$h1("Nigeria Governors and Deputy Governor Age Analysis")
        ),
        tabPanel(
          "Model Plot",
          value = "Model",
          plotOutput("modelPlot")
        ),
        tabPanel("Governor List",
                 value = 'Governor',
                 tableOutput("Governor_T")
        ),
        tabPanel("Deputy Governor List",
                 value = 'Deputy_Governor',
                 tableOutput("Deputy_Governor_T")
        )
      )
    )
  )
)

server <- function(input, output) {
  data_filtered <- reactive({
    filtered <- raw_data
    if (!is.null(input$state_input) && length(input$state_input) > 0) {
      filtered <- filtered[filtered$State_Name %in% input$state_input, ]
    }
    if (!is.null(input$position) && length(input$position) > 0) {
      filtered <- filtered[filtered$Position_Name %in% input$position, ]
    }
    filtered
  })
  
  output$modelPlot <- renderPlot({
    ggplot(data_filtered(), aes(x = State_Name, y = Age, fill = Position_Name)) +
      geom_bar(stat = "identity", position = "dodge") +
      xlab("States") +
      ylab("Median Earnings After 10yrs") +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
      ggtitle("Predictions vs. Actual")
  })
  
  output$Governor_T <- renderTable({
    data_Governor <- data_filtered() %>%
      filter(Position_Name == 'Governor') %>%
      select(State_Name, Age) %>%
      arrange(State_Name)
    data_Governor
  })
  output$Deputy_Governor_T <- renderTable({
    data_Deputy_Governor <- data_filtered() %>%
      filter(Position_Name == 'Deputy_Governor') %>%
      select(State_Name, Age) %>%
      arrange(State_Name)
    data_Deputy_Governor
  })
  
  
}

shinyApp(ui = ui, server = server)

