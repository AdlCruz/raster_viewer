library(shiny)
library(dplyr)
library(ncdf4)
library(colourpicker)
library(purrr)
library(shinyFiles)
library(leaflet)
library(raster)
library(rgdal)


# implement the app's user interface
ui <- fluidPage(
    titlePanel("Raster Viewer"),
    fluidRow(
        column(3, verbatimTextOutput("Select a raster file (eg. .tif, .nc)")),
        column(
            3,
            shinyFilesButton(
                "file",
                "File select",
                "Please select a file",
                multiple = TRUE,
                viewtype = "detail"
            )
        ),
        column(6, verbatimTextOutput("filepaths"))
    ),
    # fluidRow(
    #   plotOutput("plot")
    # ),
    fluidRow(leafletOutput("leaf")),
    
    
    # The plot itself will display in the main panel, to the right of the side bar:
    mainPanel()
    
)


server <- function(input, output, session) {
    volumes <-
        c(Home = fs::path_home(),
          "R Installation" = R.home(),
          getVolumes()())
    shinyFileChoose(input, "file", roots = volumes, session = session)
    
    observe({
        cat("\ninput$file value:\n\n")
        print(input$file)
        print(input$filepaths$datapath)
    })
    
    ## print to browser
    output$filepaths <- renderPrint({
        if (is.integer(input$file)) {
            cat("No files have been selected (shinyFileChoose)")
        } else {
            parseFilePaths(volumes, input$file)
        }
    })
    
    
    output$leaf <- renderLeaflet({
        req(parseFilePaths(volumes, input$file)$datapath)
        path <- parseFilePaths(volumes, input$file)$datapath
        
        rstr <- raster(path) # if multi layer this keeps only FIRST
        # so for variable layer selection will have to be specified here at outset or
        # by creating earler reactiveraster step
        
        
        leaflet() %>% addTiles() %>%
            addRasterImage(rstr, opacity = .6)
        
    })
    
}


#run/call the shiny app
shinyApp(ui, server)
