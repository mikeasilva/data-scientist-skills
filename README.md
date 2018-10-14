![](https://sps.cuny.edu/sites/all/themes/cuny/assets/img/header_logo.png)

# Skills of a Data Scientist Team Project

This is a project for CUNY SPS 607 - Data Acquisition and Management.  This project was completed by 

* Elizabeth Drikman
* Michael Yampol
* Michael Silva
* Corey Arnouts

## Motivation

Our motivation for this study is to gain an understanding of which skills are the most useful for a data scientist to have so that we can plan what courses to take in our Master's program.

## Approach

To answer this question we will scrape data scientist job listings on dice.com and extract the skills listed on the postings.  We also want to see if there is any variation by the location of the jobs so we are scraping results from a selection of metro areas.

## Findings

TODO: Summarize findings

## Replication

### System Requirements

This study uses both R and Python 3.  In order to replicate it you will need the following installed:

*   R
    *   DBI
    *   RMySQL
    *   censusapi
    *   dplyr
*   Python
    *   requests
    *   asyncio
    *   sqlalchemy
    *   pymysql
    *   beautifulsoup4
    *   selenium
    
You will need the [Chrome selenium driver](https://sites.google.com/a/chromium.org/chromedriver/home) installed on your local machine.  You will also need to have [register for a U.S. Census Bureau's API key](https://api.census.gov/data/key_signup.html).

### Configuration

You will need to edit Credentials.R with your Census Bureau API key and MySQL credentials.

### Replicating the Study

#### Step 1: Setup.R

You will first need to run the Setup.R script.  This will set up your local MySQL database.  Next it will request the 2010 census population from the API for the metropolitan area above the threshold defined in Setup.R.  It will then launch a selenium controlled Chrome browser which will search for dice.com using "Data Scientist" as the keyword and the metro's name for the location.

#### Step 2: Dice_Scraper.py

The next step is to run the Dice Scraper script which will scrape all the URLs previously stored in the MySQL database.  