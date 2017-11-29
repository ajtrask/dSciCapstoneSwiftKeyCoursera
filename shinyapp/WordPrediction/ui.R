library(shiny)

fluidPage(
  titlePanel("Word Prediction"),

  column(1),
  
  column(10,
         fluidRow(div(h4("by Aaron Trask"),h4("Version 1.0"),h5("November 29, 2017"))),
         wellPanel(
           textInput("text", label = h3("Text input:"), value = ""),
           uiOutput("buttons")
         ),
         wellPanel(align="center",
           plotOutput("graph", width = 500, height = 300)
           #verbatimTextOutput("inputText"),
           #verbatimTextOutput("suggestedWords"),
           #verbatimTextOutput("keypress")
         )
  ),
  
  column(1) #,
  # 
  # # this is just a test for capturing keystrokes
  # tags$script('
  #             $(document).on("keydown", function (e) {
  #             Shiny.onInputChange("mydata", e.which);
  #             });
  #             ') 
)

