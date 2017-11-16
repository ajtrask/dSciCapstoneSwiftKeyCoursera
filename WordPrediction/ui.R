library(shiny)

fluidPage(
  titlePanel("Word Prediction"),
  column(1),
  
  column(10,
         wellPanel(
           textInput("text", label = h3("Text input"), value = ""),
           uiOutput("buttons")
         ),
         wellPanel(
           verbatimTextOutput("inputText"),
           verbatimTextOutput("suggestedWords"),
           verbatimTextOutput("keypress")
         )
  ),
  
  column(1),

  # this is just a test for capturing keystrokes
  tags$script('
              $(document).on("keydown", function (e) {
              Shiny.onInputChange("mydata", e.which);
              });
              ') 
)

