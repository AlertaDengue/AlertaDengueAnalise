
library(shiny)

d<-read.csv("./dadosAPS_201514.csv")
listaAPS<-unique(d$APS)
nAPS <- length(listaAPS)

# Define UI for slider demo application
shinyUI(pageWithSidebar(
  
  #  Application title
  headerPanel("Rt and Incidence"),
  
  # Sidebar with sliders that demonstrate various available options
  sidebarPanel(
    
    tags$h3("Options"),
            
    selectInput(inputId = "ap",
                 label = "APS",
                 choices = as.character(listaAPS[c(1:3,6:7, nAPS)]),
                 selected = listaAPS[1]),
    
    selectInput(inputId = "ttype",
                label = "Type",
                choices = c("Incidence", "Rt"),
                selected = "Rt"),
    tags$br(),
    h5("Created by:"),
    tags$a("Daniel A. M. Villela", 
           href="http://www.procc.fiocruz.br/Members/dvillela"),
    
    h6("Alert: http://info.dengue.mat.br"),
    h6("Method EpiEstim package: Cori, A. et al. A new framework and software to estimate time-varying reproduction numbers
during epidemics. (submitted)"),
    h6("TD: Wallinga, J., and P. Teunis. Different Epidemic Curves for Severe Acute Respiratory Syndrome Reveal
       Similar Impacts of Control Measures. American Journal of Epidemiology 160, no. 6 (2004):
509."),
    h6("R0 package: Obadia, T., Haneef, R., & Boëlle, P. Y. (2012). The R0 package: a toolbox to estimate reproduction numbers for epidemic outbreaks. BMC medical informatics and decision making, 12(1), 147.")
    ),
  
  # Show a table summarizing the values entered
  mainPanel(
    plotOutput("graph1")
    #plotOutput("graph2"),
  #  tableOutput("datatable")
  )
))
