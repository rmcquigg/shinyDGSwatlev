library(ggplot2)
library(plotly)
library(shinyWidgets)
library(reshape2)
library(tidyr)
library(dplyr)
library(sf)
library(leaflet)
library(lattice)
library(leafpop)

id='17_bmjL9huH-WaDLwFGTJkTtML2_4lYcG'
# data=read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",id),check.names=FALSE)
# data$DateTime_EST=as.POSIXct(data$DateTime_EST,format="%Y-%m-%d %H:%M:%S")
# 
coordid='17bXcUPK8Oj-szxcKCckHd6yQtHplegi_'
# coordinates_list=read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",coordid),check.names=FALSE)
# latitude=c(coordinates_list$Latitude)
# longitude=c(coordinates_list$Longitude)

#____________________________________________________
server=shinyServer(function(input, output, session) {
  # Get the data from the variables declared on the ui.R file
  # df <- reactive({data[, c('TIMESTAMP', input$yCol)]})
  data=read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",id),check.names=FALSE)
  data$DateTime_EST=as.POSIXct(data$DateTime_EST,format="%Y-%m-%d %H:%M:%S")
  
  df=reactive({data})
  sites_list=reactive({input$sites})
  
  start_date=reactive({input$date_range[1]})
  end_date=reactive({input$date_range[2]})

  
  coordinates_list=read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",coordid),check.names=FALSE)
  latitude=c(coordinates_list$Latitude)
  longitude=c(coordinates_list$Longitude)
  
  pal <- colorFactor(
    palette = c('blue', 'red'),
    domain = coordinates_list$Network)
  
  output$map <- renderLeaflet({
    leaflet(data=coordinates_list) %>% addProviderTiles("OpenStreetMap.Mapnik") %>%
    setView(-75.562706,39.143522,zoom=8)%>%
#   addCircleMarkers(~lng, ~lat, popup=~as.character(DGSID),label=~as.character(DGSID),layerId = coordinates_list$DGSID)%>%
    addCircleMarkers(~Longitude, ~Latitude, color='black',fillColor =~pal(Network),radius=5,weight = 1,fillOpacity = 8.5,
                     popup=popupTable(coordinates_list,row.numbers=FALSE,feature.id=FALSE),label=~as.character(DGSID),layerId = coordinates_list$DGSID)%>%
      
    addLegend("bottomleft", pal = pal, values = ~Network,
                title = "Water level monitoring freqency",
                opacity = 1)%>%
    addEasyButton(easyButton(
      icon="glyphicon-home", title="Zoom to DE",
      onClick=JS("function(btn, map){ map.setView([39.143522,-75.562706],8); }")))
  })
  
  observeEvent(input$map_marker_click, {
    click=input$map_marker_click
    if (is.null(click))
      return()
    # print(click$id)

    output$plot=renderPlotly({
      plot.data=melt(df(), id.vars = 'DateTime_EST')
      start_date=as.POSIXct(start_date(),format='%m-%d-%Y')
      end_date=as.POSIXct(end_date(),format='%m-%d-%Y')
      lims=c(start_date,end_date)
      # # plot.data <- plot.data[plot.data$variable %in% input$sites, ]
      plot.data <- plot.data[plot.data$variable %in% click$id, ]
      p=ggplot(plot.data) +
        geom_line(mapping=aes(x=DateTime_EST,y=value,colour=variable)) + 
        theme_bw()+
        # theme(legend.position='bottom')+
        theme(legend.text = element_text(size=12))+
        scale_color_viridis_d(name='Site:')+
        scale_x_datetime(date_labels="%d-%b-%y\n%H:%M",limits=lims)+
        scale_y_reverse()+
        theme(axis.text.x = element_text(vjust=.5, hjust=1,family='Arial'))+
        xlab('')+
        ylab('feet below ground surface')+
        theme(text=element_text(family='Arial'))+
        labs(title='Depth to water')
      
      ggplotly(p) %>% 
        layout(legend=list(orientation='h'))
    })
  })
})