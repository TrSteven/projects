# Load the rvest package
library(rvest)
library(tidyverse)

# See also:
# https://www.analyticsvidhya.com/blog/2017/03/beginners-guide-on-web-scraping-in-r-using-rvest-with-hands-on-knowledge/

# Specify the url for desired website to be scraped
# Top 50 movies for the year 2018
url <- 'https://www.imdb.com/search/title/?release_date=2018-01-01,2018-12-31'

# Read the HTML code from the website
webpage <- read_html(url)

# First extract the data from each div containing information about a movie
results <- html_nodes(webpage, '.lister-item-content')

# To be able to deal with missing values (e.g. for metascore), do not use webpage directly
# E.g. first movie doesn't have a metascore
html_nodes(results[1], '.metascore') %>% html_text()

# Using webpage directly results in a wrong metascore
html_nodes(webpage, '.metascore')[1] %>% html_text()
html_nodes(results[1], '.metascore') %>% html_text() 

# Functions to get movies and deal with missing values
check_NA <- function(to_check) {
  return(ifelse(length(to_check) == 0, NA, to_check))
}

get_movies <- function(node) {
  rank <- html_nodes(node, '.text-primary') %>% html_text()
  title <- html_nodes(node, '.lister-item-header a') %>% html_text()
  runtime <- html_nodes(node, '.runtime') %>% html_text()
  rating <- html_nodes(node, '.ratings-imdb-rating strong') %>% html_text()
  number_of_votes <- html_nodes(node, 'p.sort-num_votes-visible > span:nth-child(2)') %>% html_text()
  metascore <- html_nodes(node, '.metascore') %>% html_text(trim = TRUE)
  
  data.frame(
    rank = check_NA(rank),
    title = check_NA(title),
    runtime = check_NA(runtime),
    rating = check_NA(rating),
    number_of_votes = check_NA(number_of_votes),
    metascore = check_NA(metascore),    
    stringsAsFactors=F
  )
  
}

# Get a dataframe with movies
movies <- lapply(results, get_movies) %>%
  bind_rows()

# Convert to correct format
movies$rank <- as.numeric(movies$rank)
movies$rating <- as.numeric(movies$rating)
movies$runtime <- as.numeric(gsub(" min", "", movies$runtime))
movies$length_title <- str_length(movies$title)
movies$number_of_votes <- as.numeric(gsub(",", "", movies$number_of_votes))
movies$metascore <- as.numeric(movies$metascore)

# Plot rating vs. length of title
rating_length <- ggplot(movies) + 
  aes(x = length_title, y = rating) +
  geom_point() + 
  labs(x = "Length of title", y = "Rating") + 
  geom_smooth()
 
rating_length

# Plot rating vs. runtime
rating_runtime <- ggplot(movies) + 
  aes(x = runtime, y = rating) +
  geom_point() + 
  labs(x = "Runtime", y = "Rating") + 
  geom_smooth()

rating_runtime

# Plot rating vs. metascore
rating_metascore <- ggplot(movies) + 
  aes(x = metascore, y = rating) +
  geom_point() + 
  labs(x = "Metascore", y = "Rating") + 
  geom_smooth()

rating_metascore

# Plot rating vs. number of votes
rating_votes <- ggplot(movies) + 
  aes(x = number_of_votes, y = rating) +
  geom_point() + scale_x_log10() +
  labs(x = "Number of votes", y = "Rating") + 
  geom_smooth()

rating_votes
