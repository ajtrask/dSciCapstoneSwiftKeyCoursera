suppressPackageStartupMessages(c(
  library(stringr),
  library(tidyverse),
  library(tidytext),
  library(data.table),
  library(igraph),
  library(ggraph)
))

# load the ngrams:
n1grams <- readRDS("n1grams.rds")
n2grams <- readRDS("n2grams.rds")
n3grams <- readRDS("n3grams.rds")
n4grams <- readRDS("n4grams.rds")

# build bigram graph
bigram_graph <- n2grams %>%
  rename(from=ngram,to=pred) %>%
  graph_from_data_frame()

# get top three words in vocab to fill in when not enough predictions
top_three_words <- n1grams %>% 
  arrange(desc(freq)) %>% 
  head(3) %>% 
  mutate(ngram="") %>%
  rename(pred = word, score = freq)

# create function to predict words using stupid backoff
predictWords <- function(phrase, backoff_factor=0.4, num_predictions=3) {
  
  # max ngram order based on the loaded rds files
  ngram_order <- 4
  
  # split out the input phrase into words
  words <- str_split(str_to_lower(phrase), " ")[[1]]
  
  # store the total number of input words
  num_words <- length(words)
  
  # initialize empty data frame
  preds <- data.frame(ngram=character(),
                      pred=character(),
                      score=double(),
                      stringsAsFactors=FALSE)
  
  # loop down to bigrams
  for (i in ngram_order:2) {

        # search ngram level if we have enough words in the phrase
    if (num_words >= i-1) {
      
      # setup backoff_factor for this ngram level
      bos <- backoff_factor^(i-ngram_order)
      
      # create search ngram
      search_gram <- paste(words[(num_words-(i-2)):num_words], collapse = " ")

      # append prediction scores if ngram found
      preds <- rbind(preds,
                     eval(as.symbol(paste("n",i,"grams",sep=""))) %>%
                       filter(ngram==search_gram) %>%
                       mutate(score = bos*score)) %>% 
        group_by(pred) %>%
        top_n(1, score) %>%
        ungroup() %>%
        arrange(desc(score)) %>%
        head(num_predictions)
    }
  }
  
  # add in the top three unigrams to fill out the prediction if needed
  preds <- rbind(preds,top_three_words) %>% 
    group_by(pred) %>% 
    top_n(1, score) %>%
    ungroup() %>%
    arrange(desc(score)) %>%
    head(num_predictions)
  
  return(preds)
}

# function to check if variable is empty (NULL, NA, NaN, "")
is.valid <- function(x) {
  require(shiny)
  is.null(need(x, message = FALSE))  
}

shinyServer(function(input, output, session) {
  
  # reflect the input text back to the output
  output$inputText <- renderText({ input$text })

  # split input text into list of words
  input_words <- reactive({
    str_to_lower(strsplit(str_trim(input$text), " ")[[1]], locale = "en")
  })
  
  # predict the next word
  words <- reactive({
    req(input$text) # require that input text is not empty for predictions
    
    predWords <- NA_character_
    #if (length(myText)>0) {
      #predWords <- nextword(myText, 3)
    predWords <- predictWords(str_trim(input$text),0.4,10)
    #}

    predWords
  })
  
  # return the predicted words
  #output$suggestedWords <- renderText({ words() })
  
  # show buttons for the top 3 predicted words
  output$buttons <- renderUI({
    div(
      span(renderText({length(words())}))
    )
    
    if (is.valid(words()[1])) {
      div(
        span(
          if (is.valid(words()$pred[1])) { actionButton(inputId = "word1", label = words()$pred[1]) },
          if (is.valid(words()$pred[2])) { actionButton(inputId = "word2", label = words()$pred[2]) },
          if (is.valid(words()$pred[3])) { actionButton(inputId = "word3", label = words()$pred[3]) }
          )
      )
    }
  })
  
  # this is just a test for capturing keystrokes
  output$keypress <- renderPrint({ input$mydata })
  
  # respond to word1 selection button press
  observeEvent(input$word1, {
    # change the value of input$text, based on button pressed
    updateTextInput(session, "text", value = paste(input$text, words()$pred[1]))
  })
  
  # respond to word2 selection button press
  observeEvent(input$word2, {
    # change the value of input$text, based on button pressed
    updateTextInput(session, "text", value = paste(input$text, words()$pred[2]))
  })
  
  # respond to word1 selection button press
  observeEvent(input$word3, {
    # change the value of input$text, based on button pressed
    updateTextInput(session, "text", value = paste(input$text, words()$pred[3]))
  })
  
  output$graph <- renderPlot({
    req(words()) # require that prediction is not empty to show the plot
    
    # query subgraph
    graph_words <- data.frame(phrase=c(words()$ngram,words()$pred,input_words()),stringsAsFactors = FALSE) %>%
      unnest_tokens(word, phrase) %>%
      count(word, sort = TRUE)
    verts <- graph_words$word
    verts <- match(verts, V(bigram_graph)$name)
    verts <- verts[!is.na(verts)]
    
    bigram_subgraph <- induced_subgraph(bigram_graph, verts, impl = "auto")
    
    ggraph(bigram_subgraph, layout = 'kk') + 
      geom_edge_link(aes(colour = 'red')) + 
      geom_node_point() +
      geom_node_text(aes(label = name), vjust = 1, hjust = 1) + 
      ggtitle('Word Prediction Relational Graph') +
      theme(axis.line=element_blank(),axis.text.x=element_blank(),
            axis.text.y=element_blank(),axis.ticks=element_blank(),
            axis.title.x=element_blank(),axis.title.y=element_blank(),
            legend.position="none",panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),plot.background=element_blank())
    
  })

})

