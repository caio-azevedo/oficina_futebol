rm(list=ls())

url <- "https://raw.githubusercontent.com/williamorim/brasileirao/master/data-raw/csv/matches.csv"
dados <- readr::read_csv(url)
