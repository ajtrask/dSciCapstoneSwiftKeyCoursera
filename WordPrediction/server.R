suppressPackageStartupMessages(c(
  library(stringr)
))

# load the n-grams:
unigrams <- readRDS("unigrams.rds")
bigrams <- readRDS("bigrams.rds")
trigrams <- readRDS("trigrams.rds")
quadgrams <- readRD("quadgrams.rds")

# function to predict next word options
nextword <- function(words, num_predict) {

  lastthree <- tail(words, 3)
  
  potential_matches <- ""
  
  # this returns potential matches from the quadgrams
  if (length(lastthree)==3) {
    potential_matches <- quadgrams %>%
      filter(word1==lastthree[1,]) %>%
      filter(word2==lastthree[2,]) %>%
      filter(word3==lastthree[3,]) %>%
      arrange(desc(logprob)) %>%
      head(num_predict)
  }
  
  # if no quadgrams found or if only two words provided, this returns potential matches from the trigrams
  if (length(lastthree)==2 | nrow(potential_matches)==0) {
    potential_matches <- trigrams %>%
      filter(word2==tail(lastthree,1)$word) %>%
      filter(word1==head(tail(lastthree,2),1)$word) %>%
      arrange(desc(logprob)) %>%
      head(num_predict)
  }
  
  # if no trigrams found or if only one word provided, this returns potential matchs from the bigrams
  if (length(lastthree)==1 | nrow(potential_matches)==0) {
    potential_matches <- bigrams %>%
      filter(word1==tail(lastthree,1)$word) %>%
      arrange(desc(logprob)) %>%
      head(num_predict)
  }
  
  # if no bigrams found, return top unigrams
  if (nrow(potential_matches)==0) {
    potential_matches <- unigrams %>%
      arrange(desc(logprob)) %>%
      head(num_predict)
  }
  
  return(potential_matches)
}


shinyServer(function(input, output, session) {
  
  # reflect the input text back to the output
  output$inputText <- renderText({ input$text })

  # predict the next word
  words <- reactive({
    #TODO apply the same cleaning to the input text before prediction
    #HARDCODED EXAMPLE AT THE MOMENT
    myText <- str_to_lower(strsplit(input$text, " ")[[1]], locale = "en")
    
    predWords <- NA_character_
    if (length(myText)>0) {
      predWords <- nextword(myText, 3)$word
    }

    predWords
  })
  
  # return the predicted words
  output$suggestedWords <- renderText({ words() })
  
  # show buttons for the top 3 predicted words
  output$buttons <- renderUI({
    div(
      span(renderText({length(words())}))
    )
    
    if (!is.na(words()[1])) {
      div(
        span(
          # TODO make these radio buttons
          actionButton(inputId = "word1", label = words()[1]),
          actionButton(inputId = "word2", label = words()[2]),
          actionButton(inputId = "word3", label = words()[3])
          
          )
      )
    #} else {
    #  span()
    }
  })
  
  # this is just a test for capturing keystrokes
  output$keypress <- renderPrint({ input$mydata })
  
  # respond to word1 selection button press
  observeEvent(input$word1, {
    # change the value of input$text, based on button pressed
    updateTextInput(session, "text", value = paste(input$text, words()[1]))
  })
  
  # respond to word2 selection button press
  observeEvent(input$word2, {
    # change the value of input$text, based on button pressed
    updateTextInput(session, "text", value = paste(input$text, words()[2]))
  })
  
  # respond to word1 selection button press
  observeEvent(input$word3, {
    # change the value of input$text, based on button pressed
    updateTextInput(session, "text", value = paste(input$text, words()[3]))
  })

})

