from bs4 import BeautifulSoup
import pandas as pd
import requests

# Specify the url for desired website to be scraped
# Top 50 movies for the year 2018
url = 'https://www.imdb.com/search/title/?release_date=2018-01-01,2018-12-31'

# Read the HTML code from the website
soup = BeautifulSoup(requests.get(url).content)

# First extract the data from each div containing information about a movie
results = soup.find_all("div", class_="lister-item-content")
results[2]

# To be able to deal with missing values (e.g. for metascore), do not use webpage directly
# E.g. first movie doesn't have a metascore
# Using webpage directly results in a wrong metascore
soup.find_all(class_="metascore")[0]
results[0].find(class_="metascore")
results[4].find(class_="metascore").get_text(strip = True)

# Function to get text stripped 
# and test if the value passed to the function is not empty
def extract_text(text):
    if not text:  # if len(text) == 0:
        return None
    else:
        return text[0].get_text(strip = True)
    
    
# Function to get necassary info from div
def parse_movie(node):
    rank = extract_text(node.select(".text-primary"))
    title = extract_text(node.select(".lister-item-header a"))
    runtime = extract_text(node.select(".runtime"))
    rating = extract_text(node.select(".ratings-imdb-rating strong"))
    number_of_votes = extract_text(node.select("p.sort-num_votes-visible > span:nth-child(2)"))
    metascore = extract_text(node.select(".metascore"))
    return {"rank": rank, "title": title, "runtime": runtime, 
            "rating": rating, "number_of_votes": number_of_votes, "metascore": metascore}

movies = pd.DataFrame()
for x in results:
    movies = movies.append(parse_movie(x), ignore_index = True)

movies["number_of_votes"] = movies["number_of_votes"].str.replace(',', '').astype(float)
movies["rank"] = movies["rank"].str.replace('.', '').astype(int)
movies["rating"] = movies["rating"].astype(float)
movies["metascore"] = movies["metascore"].astype(float)
movies["runtime"] = movies["runtime"].str.replace('min', '').astype(float)

print(movies)
