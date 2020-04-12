import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import os

# Source: https://www.gutenberg.org/browse/scores/top
titles = []
for file in os.listdir('books'):
    if file.endswith('.txt'):
        titles.append(file.replace('.txt', ''))
        

books = dict.fromkeys(titles)
for title in titles:
    f = open('books/' + title + '.txt', encoding='utf-8')
    books[title] = f.read().lower()
    
# Tokenize the books, remove punctuation and remove stopwords
stw_set = set(stopwords.words('english'))

for book in books:
    books[book] = [word for word in word_tokenize(books[book])]
    books[book] = [word for word in books[book] if word not in stw_set and word.isalpha()]

books[titles[0]][1000:1010]
len(books[titles[1]])

books_freq = dict.fromkeys(titles)
for book in books_freq:
    books_freq[book] = nltk.FreqDist(books[book])
    
books_freq[titles[2]]

books_freq[titles[0]].plot(20, cumulative=False)
books_freq[titles[1]].plot(20, cumulative=False)
books_freq[titles[2]].plot(20, cumulative=False)
