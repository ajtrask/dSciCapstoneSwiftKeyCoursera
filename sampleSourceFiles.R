# created sampled text files from source files

# set random seed
set.seed(1234)

# get the list of files
en_files <- Sys.glob("final/en_US/*.txt")

# loop over files and save sample
for (i in 1:length(en_files)) {
  # create some meta data from the file name
  explodePath <- unlist(strsplit(en_files[i], "[.]|[/]"))
  
  # read in the file to a data frame with rows for each line
  con <- file(en_files[i], open="r")
  allLines <- readLines(con)
  close(con)
  
  # write the sample to a file
  sample_prob <- 0.1 # look at about 5% of the lines in the files
  sampledLines <- allLines[rbinom(n = length(allLines), size = 1, prob = sample_prob)==1]
  write.csv(sampledLines, file = paste(explodePath[3],explodePath[4],"sampled",explodePath[5],sep = "."))
}