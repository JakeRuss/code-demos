###########################
# File: Crapo_release_parser.R
# Description: 
#   (1) Create a list object that contains the file names of all the html copies
#       saved during the scraper script.
#   (2) Loop through the html files and extract the press release text for 
#       a potential text analysis. Save content to a text file.
# Date: 12/4/2014
# Author: Jake Russ
# Notes:
# To do:
############################

# Load packages
library(XML)
library(rvest)
library(stringr)
library(dplyr)
library(magrittr)

# Working directory
dir <- getwd()

# Create a list of the files in the html subdirectory
html_list <- list.files(path    = paste0(dir, "/press_release_scraper/html/"), 
                        pattern = "Crapo_")

for (i in html_list){
  
  # Remove ".html" from the file name
  filename <- str_replace(string = i, pattern = ".html", replacement = "")

  # Read html document into R
  doc <- html(paste0(dir,"/press_release_scraper/html/", i))
  
  # Extract the text of the press release using a CSS selector
  release_text <- html_nodes(x = doc, css = "#maincontent p") %>% html_text()
  
  # Remove garbage characters
  release_text <- str_replace_all(string      = release_text, 
                                  pattern     = "(\n|\r|\t)", 
                                  replacement = "")
  
  # Save a copy of the text to a file
  writeChar(object = release_text, 
            con    = paste0(dir, "/press_release_scraper/text/", filename, ".txt"))
  
} # End for loop

# Clean up work space
rm(list = ls())