library(quanteda)
library(readtext)
library(ggplot2)

# Source: https://www.gutenberg.org/browse/scores/top
books <- readtext("books/*.txt", encoding = "utf-8")

# Create corpus
corpus_books <- corpus(books)
summary(corpus_books)

doc_names <- c("A Christmas Carol", "Frankenstein", "Pride and Prejudice")
docnames(corpus_books) <- doc_names
summary(corpus_books)

# Create tokens
tokens_books <- tokens(corpus_books)
tokens_books[[1]][100:150]

# Create Document-feature matrix
dfm_books <- dfm(tokens_books, remove_punct = TRUE, remove = stopwords("en"))
dfm_books[, 500:510]

# Basic analysis
freq_all_books <- textstat_frequency(dfm_books, n = 15)
freq_books <- textstat_frequency(dfm_books, groups = doc_names, n = 10)
freq_all_books
freq_books

# Frequency plot
freq_all_books %>% ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()

# Word cloud
textplot_wordcloud(dfm_books, max_words = 10)
textplot_wordcloud(dfm_books, comparison = TRUE, max_words = 100)

# Lexical diversity
lexdiv_books <- textstat_lexdiv(dfm_books)
lexdiv_books
ggplot(data = lexdiv_books, aes(x = document, y = TTR)) +
  geom_bar(stat="identity")

