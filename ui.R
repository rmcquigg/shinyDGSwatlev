library(shiny)
library(ggplot2)
library(plotly)
library(shinyWidgets)
library(leaflet)
library(leafpop)
library(shinydashboard)

id='17_bmjL9huH-WaDLwFGTJkTtML2_4lYcG'
data=read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download",id),check.names=FALSE)
data$DateTime_EST=as.POSIXct(data$DateTime_EST,format="%Y-%m-%d %H:%M:%S")
y=names(data)[2:(length(names(data)))]
startdt=data$DateTime_EST[1]

#____________________________________________________
ui=shinyUI(fluidPage(
  title='DGS GWMN',
    titlePanel(title=h2(strong("Delaware Geological Survey"),style={
      'background-color: #6BA0D1;
      box-sizing: border-box;
      padding: 20px;
      padding-left: 10px;'})),
    fluidRow(
      column(4,
             leafletOutput("map", width = "100%",height = "650px")
             ),
      column(8,
             h4(strong("Groundwater Monitoring Network")),
             h5("This display shows real-time water levels collected by the Delaware Geological Survey. It has not been reviewed
                by staff and is considered provisional."),
             h5("Click on a map icon to display water level data and view well construction information."),
             # fluidRow(
             #   column(4,pickerInput(
             #         inputId = "sites",
             #         label = "Sites",
             #         choices = y,
             #         options = list(
             #           `actions-box` = TRUE),
             #         multiple = TRUE,
             #         selected=y[1])),
             #   # selectInput('yCol','Select data to plot',y),
             #    column(8,dateRangeInput('date','',
             #          start=startdt,
             #          end=Sys.Date()))),
             mainPanel(plotlyOutput('plot'),width='75%',height='250px'),
             sliderInput("date_range","Date range:",
                        min=as.POSIXct(startdt),
                        max=as.POSIXct(Sys.Date()),
                        value=c(startdt,Sys.Date()),
                        timeFormat="%d-%b-%y", ticks = F, animate = F,
                        width='90%'
                        )
             )
    )
))