library(shiny)
library(tidyverse)
library(here)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)

source(here::here("R", "globals.R"), local = FALSE)  # global scope: visible to server and ui, all sessions
source(here::here("R", "server_shared.R"), local = TRUE)  # visible to server, all sessions

# UI ====================================

ui <- navbarPage(
    shinyjs::useShinyjs(),
    
    title = "Risk Premia Harvesting",
    id = "tab",
    selected = "perfTab",
    
    # performance tab -------------------
    
    tabPanel(
        "Performance",
        value = "perfTab",
    
        sidebarLayout(
            sidebarPanel(
                selectizeInput("assets", "Select Assets", choices = c("VTI", "TLT", "GLD"), selected = c("VTI", "TLT", "GLD"), multiple = TRUE),
            ),
        
            mainPanel(
                plotOutput("cumReturnsPlot"),
                plotOutput("rollingPerfPlot"),
                plotOutput("rollCorrPlot"),
                plotOutput("corrMatPlot")
            )
        )
    ),
    
    # scatterplot tab -------------------
            
    tabPanel(
        "Scatterplots",
        value = "autcorrTab",
        sidebarLayout(
            sidebarPanel(
                selectizeInput("assets", "Select Assets", choices = c("VTI", "TLT", "GLD"), selected = c("VTI", "TLT", "GLD"), multiple = TRUE),
                sliderInput("estWdwSize", "Select Estimation Window Length", min = 10, max = 100, step = 10, value = 30),
                sliderInput("fwdWdwSize", "Select Forward Window Length", min = 10, max = 100, step = 10, value = 30),
                checkboxInput("removeOverlapping", label = "Show Non-Overlapping Periods Only", value = TRUE)
        
        ),
            mainPanel(
                fluidRow(
                    column(6, plotOutput("laggedReturnsPlot")),
                    column(6, plotOutput("laggedVolPlot"))
                )
            )
        )
    ),
    
    # backtesting tab -------------------
    
    tabPanel(
        "Backtest",
        value = "backtestTab",
        sidebarLayout(
            sidebarPanel(
                sliderInput("initEqSlider", "Initial Equity, $", min = 1000, max = 1000000, step = 1000, value = 10000),
                fluidRow(
                    column(6, 
                        knobInput("commKnob", "Per Share Commission, cents", min = 0.1, max = 2, step = 0.01, value = 0.5, displayPrevious = TRUE)
                    ),
                    column(6, 
                        knobInput("minCommKnob", "Minimum Commission Per Order, $", min = 0, max = 10, step = 0.5, value = 0.5, displayPrevious = TRUE)
                    )
                ),
                fluidRow(
                    column(6, 
                        sliderInput("targetVolSlider", "Target Asset Volatility, %", min = 1, max = 10, step = 0.5, value = 5)
                    ),
                    column(6, 
                        sliderInput("volLookbackSlider", "Volatility Estimation Window, days", min = 5, max = 120, step = 5, value = 60)
                    )
                ),
                fluidRow(
                    column(6, 
                        sliderInput("rebalFreqSlider", "Rebalance Frequency, months", min = 1, max = 12, step = 1, value = 1)
                    ),
                    column(6, 
                        sliderInput("capFreqSlider", "Frequency to Capitalise Profits", min = 0, max = 12, step = 1, value = 1)
                    )
                ),
                fluidRow(
                    column(12, align = "center",
                        actionButton("runBacktestButton", "UPDATE BACKTEST")
                    )
                )
            ),
            
            mainPanel(
                tabsetPanel(
                    id = "backtestPanel",
                    
                    # EW B&H tab --------
                    
                    tabPanel(
                        "Equal Weight Buy and Hold",
                        value = "ewbhTab",
                        fluidRow(
                            column(12, align = "center", 
                                plotOutput("ewbhEqPlot") %>% 
                                    withSpinner(),
                                tableOutput("ewbhPerfTable"),
                                plotOutput("ewbhRollPerfPlot") %>% 
                                    withSpinner(),
                                plotOutput("ewbhTradesPlot", height = "150px"),
                                plotOutput("ewbhCommPlot", height = "150px"),
                                plotOutput("ewbhCommExpPlot", height = "150px"),
                                DT::dataTableOutput(("ewbhTradesTable"))
                            )
                        )
                    ),
                    
                    # EW Rebal tab ------
                    
                    tabPanel(
                    "Equal Weight Rebalance",
                    value = "ewrebalTab", 
                        fluidRow(
                            column(12, align = "center", 
                               plotOutput("ewrebEqPlot")%>% 
                                   withSpinner(),
                               tableOutput("ewrebPerfTable")%>% 
                                   withSpinner(),
                               plotOutput("ewrebRollPerfPlot"),
                               plotOutput("ewrebTradesPlot", height = "150px"),
                               plotOutput("ewrebCommPlot", height = "150px"),
                               plotOutput("ewrebCommExpPlot", height = "150px"),
                               DT::dataTableOutput(("ewrebTradesTable"))
                            )
                        )
                    ),
                    
                    # Risk Parity tab ------
                    
                    tabPanel(
                        "Risk Parity",
                        fluidRow(
                            column(12, align = "center", 
                               plotOutput("rpEqPlot")%>% 
                                   withSpinner(),
                               plotOutput("rpTheoSizePlot", height = "150px")%>% 
                                   withSpinner(),
                               tableOutput("rpPerfTable"),
                               plotOutput("rpRollPerfPlot")%>% 
                                   withSpinner(),
                               plotOutput("rpTradesPlot", height = "150px"),
                               plotOutput("rpCommPlot", height = "150px"),
                               plotOutput("rpCommExpPlot", height = "150px"),
                               DT::dataTableOutput(("rpTradesTable"))
                            )
                        )
                    )
                )
            )
        )
    )
)

server <- function(input, output) {
    
    # scoped to individual sessions
    source(here::here("R", "analysis_reactives.R"), local = TRUE)  
    source(here::here("R", "backtest_reactives.R"), local = TRUE) 

}

# Run the application 
shinyApp(ui = ui, server = server)
