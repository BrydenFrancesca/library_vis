library(tm)
library(tidytext)
library(dplyr)

#Download dataset
catalogue_raw <- data.table::fread("https://datamillnorth.org/download/ncclibs-catalogue-titles/ce624993-17b7-4655-be2e-842b7b8282c1/Cataloguetitles-20190806.csv", encoding = "UTF-8")

#Top ten authors by number of books
top_authors <- catalogue_raw[author != "", .(count = sum(Copies, na.rm = T)), by = list(author)]
data.table::setorder(top_authors, -count)
top_authors <- head(top_authors, n = 10)

#Number of books by year
books_by_year <- catalogue_raw[, .(count = sum(Copies, na.rm = T)), by = list(copyrightdate)]
data.table::setorder(books_by_year, copyrightdate)

#Number of authors by year
author_by_year <- catalogue_raw[, .(count = .N), by = list(author, copyrightdate)]
author_by_year <- author_by_year[, .(count = .N), by = list(copyrightdate)]
data.table::setorder(author_by_year, copyrightdate)

##Text mining
#Read in titles as Corpus, removing graphic characters to avoid encoding errors
titles <- Corpus(VectorSource(stringr::str_replace_all(catalogue_raw$title,"[^[:graph:]]", " ")))

#Remove punctuation
toSpace <- content_transformer(function (x , pattern) gsub(pattern, "", x))
titles <- tm_map(titles, toSpace, "[[:punct:]]")
#Remove whitespace
titles <- tm_map(titles, stripWhitespace)
titles <- tm_map(titles, content_transformer(tolower))
# Remove numbers
titles <- tm_map(titles, removeNumbers)
# Remove english common stopwords
titles <- tm_map(titles, toSpace, paste0("\\b", paste(c(stopwords("english"), "and", "the"), collapse = "\\b|\\b"), "\\b"))

#Turn corpus into frequency table of words
title_words <- TermDocumentMatrix(titles)
title_words <- tidytext::tidy(title_words) %>%
  data.table::as.data.table()

#Group by word and summarise
title_words <- title_words[, .(count = sum(count, na.rm = TRUE)), by = list(term)]
data.table::setorder(title_words, -count)



