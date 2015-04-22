library("shiny")
library("ggplot2")

#ttype <- "Rt"

# Simulation and Shiny Application of Resource Competition
shinyServer(function(input, output) {
  
  # Hit counter
  
  mydata <- reactive({

    apt <- input$ap
    ttype <- input$ttype
    
    df <- dfRt[dfRt$APS==apt,]
    list(long=df, wide=c())
  #list(long=dtest, wide=c())

    })
  
 #  output$datatable <- renderTable(mydata()[["long"]], digits=2)
    
#gf <- ggplot(dsim, aes(x=x, y=lambda, colour=COMPETING))
#gf <- gf + xlab("Number of competing individuals") + geom_line() + facet_grid(PERFORMANCE ~ .) + geom_vline(aes(xintercept = z), vline.data)

  output$graph1 <- renderPlot({

    if (input$ttype=="Rt") {
    g <- ggplot(mydata()[["long"]], aes(x=time, y=Rt))
    g <- g+ geom_ribbon(aes(ymin = Rtlr, ymax=Rtur)) + geom_line() + facet_grid(method ~ .) + ggtitle("Dengue Rt")  
    #g <- g + geom_line() 
  }
  else if (input$ttype=="Incidence") {
    g <- ggplot(mydata()[["long"]], aes(x=time, y=casosm))
    g <- g + geom_line() + ggtitle("Num. dengue cases")  
  }
    
    print(g)
  })
    
  
})
  
