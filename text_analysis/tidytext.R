# Load packages
library(tidyverse)
library(tidytext)

# Load data
# Source: https://www.gutenberg.org/browse/scores/top

files <- c("a_christmas_carol", "frankenstein", "pride_and_prejudice")
books <- data.frame(line = integer(), 
                    text = character(), 
                    title = character(),
                    stringsAsFactors = FALSE)

for(i in 1:length(files)) {
  path <- paste0("books/", files[i], ".txt")
  con <- file(path, encoding = "UTF-8")
  text <- readLines(con)
  df <- as.data.frame(text, stringsAsFactors=FALSE)
  df$line <- 1:nrow(df)
  df$title <- files[i]
  close(con)
  books <- rbind(books, df)
}

books <- books %>%
  mutate(title = recode(title, 
                        pride_and_prejudice = "Pride and Prejudice",
                        frankenstein = "Frankenstein",
                        a_christmas_carol = "A Christmas Carol"))

# Create tidy version of books dataframe
# Remove stopwords
tidy_books <- books %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

# Frequency analysis
freq_analysis <- tidy_books %>%
  group_by(title, word) %>%
  tally() %>%
  ungroup() %>%
  group_by(title) %>%
  top_n(n = 5, wt = n) %>%
  arrange(title, desc(n))

# Check
tidy_books %>%
  filter(title == "Frankenstein") %>%
  count(word, sort = TRUE) %>%
  slice(1:5)
