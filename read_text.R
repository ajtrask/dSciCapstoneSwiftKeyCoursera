# function for reading Coursera dSci Capstone files
read_text <- function(files) {
  # empty data frame for text lines
  df <- data.frame()
  
  # loop over files
  for (i in 1:length(files)) {
    # open connection to file
    con <- file(files[i], open="r")
    
    # read all lines from file
    allLines <- readLines(con,encoding = "UTF-8")
    
    # close connection to file
    close(con)
    
    # append lines to data frame
    df <- rbind(df, data.frame(text=allLines, stringsAsFactors = FALSE))
  }
  
  # add lineID column
  df <- df %>% rowid_to_column("lineID")
  
  # replace curly quotes with straight quotes and multiple white space with single space
  df$text <- df$text %>% str_replace_all(c("\\s+" = " ",
                                           "[\u2018\u2019]" = "'",
                                           "[\u201C\u201D]" = "\""))
  
  return(df)
}