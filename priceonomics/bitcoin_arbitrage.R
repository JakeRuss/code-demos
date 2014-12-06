###########################
# File: bitcoin_arbitrage.R
# Description: A solution to the Priceonomics.com Bitcoin puzzle.
#
# Date: 12/6/2014
# Author: Jake Russ
# Notes: I know this puzzle has been out a while by now and that there 
#        are several solutions floating around online. Still, I think I'm 
#        able to demonstrate a few cool things with new R packages.  
# To do:
############################

# Load packages
library(gtools)
library(httr)
library(jsonlite)
library(dplyr)
library(magrittr)
library(tidyr)

# Working directory
dir <- getwd()

# Cache a copy of the html directions (only need to run once)

# GET(url = "http://priceonomics.com/jobs/puzzle/",
#    write_disk(path      = paste0(dir, "/priceonomics/puzzle.html"), 
#               overwrite = TRUE))

# Load exchange rate data from url connection
messy <- stream_in(con = url("http://fx.priceonomics.com/v1/rates/"))


# Tidy the data
tidy <- messy %>%
  gather(key = cpair, value = rate, USD_JPY:USD_BTC) %>%
  mutate(rate = as.numeric(rate)) %>%
  tidyr::extract(col   = cpair, 
                 into  = c("from", "to"), 
                 regex = "([A-Z]{3})_([A-Z]{3})") %>%
  filter(from != to) %>%
  mutate(log_rate = log(rate))

cycles <- permutations(n = 4, r = 3, v = unique(tidy$from), 
                       repeats.allowed = FALSE) %>%
  data.frame(stringsAsFactors = FALSE) %>%
  rename(start = X1, middle = X2, end = X3)


results <- data.frame(start  = character(), 
                      middle = character, 
                      end    = character(), 
                      profit = numeric(), 
                      stringsAsFactors = FALSE)

for (i in 1:nrow(cycles)){
  
  calculation <- 
    tidy$log_rate[tidy$from == cycles$start[i]  & tidy$to == cycles$middle[i]] + 
    tidy$log_rate[tidy$from == cycles$middle[i] & tidy$to == cycles$end[i]]    +
    tidy$log_rate[tidy$from == cycles$end[i]    & tidy$to == cycles$start[i]]
  
  tmp <- data.frame(start  = cycles$start[i], 
                    middle = cycles$middle[i], 
                    end    = cycles$end[i], 
                    profit = calculation, 
                    stringsAsFactors = FALSE)
  
  results <- rbind(tmp, results)
}

# Sort by largest profit
results <- arrange(results, desc(profit))
