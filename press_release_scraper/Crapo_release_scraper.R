###########################
# File: Crapo_release_scraper.R
# Description: 
#   (1) Loop through Senator Mike Crapo's website and compile a list of all the 
#       press release urls.
#   (2) Run a second loop through the release urls and download an html copy of 
#       each individual press release. Save these html files to folder. 
# Date: 12/4/2014
# Author: Jake Russ
# Notes:
# To do:
############################

# Load packages
library(httr)
library(rvest)
library(stringr)
library(lubridate)
library(magrittr)

# Working directory
dir <- getwd()

# Set user agent
uagent <- "Mozilla/5.0"

# Base web address
base_url <- "http://www.crapo.senate.gov/media/newsreleases/"

# Web address for the release all page 
release_all_url <- paste0(base_url, "release_all.cfm")

# Initialize an empty data frame to collect all of the press release ids and urls.
links_all <- data.frame(release.id = numeric(), url = character(), 
                        stringsAsFactors = FALSE)

# In this example Mike Crapo's news release website displays 30 news releases 
# at a time. So we start at news release "one", which tells the website we want 
# the most recent page and then we're going to increase that by 30 each time we 
# go through the loop. NUmber 31 means the start of page two, 61 page three, etc.

# His website currently lists 72 pages, so subtract the first page, and then 
# grab each page in sequence of 30, 71 * 30 = 2130 will get that 72nd page.
page_sequence <- seq(from = 1, to = 2130, by = 30)

# Loop through the pages to get all of the press release link urls
for (i in page_sequence){


  # Make POST request, res is short for response
  res <- POST(release_all_url, 
              query = list(start = i,
                           user_agent(uagent)))
  
  # The response from the webiste is a list of all the webiste info
  # we specifically want the html document.
  doc <- html(res)
  
  # All of rvest's html_x functions will take CSS selectors or xpath selectors
  # I tend to work with CSS selectors because they're easier.
  # Go to SelectorGadget chrome extension and it will help you.
  # Note: there is an html_node and nodes
  links <- html_nodes(x = doc, css = ".table-striped a") %>% html_attr("href")
  
  # Append the individual press release id to the base url 
  links <- paste0(base_url, links)
  
  # Use a regular expression to extract the press release id
  ids <- str_extract_all(string = links, pattern = "[0-9]+") %>% unlist()
  
  # Collect ids and urls into temporary data frame.
  tmp <- data.frame(release.id = ids, url = links, stringsAsFactors = FALSE)
  
  # Store results in the links_all data frame
  links_all <- rbind(links_all, tmp)
  
  # Be polite to server; between url calls, have the scraper rest for 
  # a few seconds. Adds time to the loop but you don't want to overload 
  # the website's server.
  Sys.sleep(time = 5)
  
} # end first for loop

# Sanity check 
nrow(links_all) # 2130 release links appears to be correct number

# Store a copy of the html links
write.csv(links_all, paste0(dir, "/press_release_scraper/Crapo_release_links.csv"), 
          row.names = FALSE)

# Second stage - Now that we have all of the press release urls stored in
# links_all, we can loop through that list and download an html copy of every
# press release and save it to a folder.

# Loop through all of the press release links.
for (i in links_all$release.id) {
  
  # Press release url
  release_url <- paste0(base_url, "release_full.cfm?id=", i)
  
  # File path to save a copy of the webpage
  file_path <- paste0(dir, "/press_release_scraper/html/Crapo_release_", i, ".html")
  
  # Since we have the direct url for each release, we can do a GET
  # request instead of a POST request. This time we'll also save a copy
  # of the website for each press release. 
  res <-   GET(url = release_url, user_agent(uagent),
               write_disk(path = file_path, overwrite = TRUE))
  
  # Again, be polite to server
  Sys.sleep(time = 5)
  
} # End second for loop

# Clean up work space
rm(list = ls())
