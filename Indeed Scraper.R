# Indeed Scrapper

library(rvest)

url_to_scrape <- 'https://www.indeed.com/jobs?q=data%20scientist&start=0'

html <- read_html(url_to_scrape)

html %>%
  html_nodes('a.jobtitle') %>%
  html_text()