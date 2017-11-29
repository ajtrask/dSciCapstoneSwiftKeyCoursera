#function for reading in source text files and returning a data frame

library(dplyr)

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
  
  return(df)
}

# created sampled text files from source files
sample_source_files <- function(files, sample_prob) {
  # set random seed
  set.seed(1234)
  
  # loop over files and save sample
  for (i in 1:length(en_files)) {
    # create some meta data from the file name
    explodePath <- unlist(strsplit(en_files[i], "[.]|[/]"))
    
    # read in the file to a data frame with rows for each line
    con <- file(en_files[i], open="r") #, encoding = "UTF-8-BOM")
    allLines <- readLines(con, encoding = "UTF-8")
    close(con)
    
    # sample lines using random binomial distribution with provided probability
    sampledLines <- allLines[rbinom(n = length(allLines), size = 1, prob = sample_prob)==1]
    
    # write sample to file
    con <- file(paste(explodePath[3], explodePath[4], "sampled", explodePath[5], sep = "."),
                open="w", encoding = "UTF-8")
    writeLines(sampledLines, con)
    close(con)
  }
  
  return(Sys.glob("en_US.*.sampled.txt"))
}





