code-demos
==========

Last update: 12/04/2014

I'm on the job market and I want a place I can direct potential employers to 
view code I've written. I've created this repository to demonstrate small sample 
projects that could scale into something larger and more complex.

#### 1. Web scraping project - collect press releases from members of Congress

The folder press_release_scraper contains two R scripts, a scraper and a parser.
My philosophy with web scraping is to cache local copies of the html pages and 
then parse the content out of the local html files with a second script. In this
example I am scraping the press releases from the website of Senator Mike Crapo
(Idaho). This basic framework could be modified to scrape the websites for every 
member of Congress. And then once all of those press releases were stored and 
parsed into text files the content could be used for a text analysis.

#### 2. Priceonomics [Bitcoin arbitrage puzzle](http://priceonomics.com/jobs/puzzle/)

I know this puzzle has been out a while by now and that there are several 
solutions floating around online. Still, I think I'm able to demonstrate a 
few cool things with new R packages.
