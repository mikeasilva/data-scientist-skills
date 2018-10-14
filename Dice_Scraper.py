#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 12 05:56:40 2018

This assumes that Setup.R has been run successfully in advance.
"""
import requests
import asyncio
from sqlalchemy import create_engine

# Read in Credentials line by line and set equivalent variables
with open('Credentials.R') as f:
    for line in f:
        if 'mysql' in line:
            line = line.replace("'", '')
            var_name, value = line.split(' <- ')
            if var_name == 'mysql_host':
                host = value.strip()
            elif var_name == 'mysql_user':
                user = value.strip()
            elif var_name == 'mysql_password':
                password = value.strip()
f.close()

# Connect to the MySQL database
engine = create_engine('mysql+pymysql://'+user+':'+password+'@'+host+'/DATA607')
conn = engine.connect()

print('Building list of URLs to scrape')
urls_to_scrape = list()
ids = dict()

sql = '''SELECT *
FROM `DICE_RAW_HTML`
WHERE scraped = 0'''

query = conn.execute(sql)
for row in query:
    urls_to_scrape.append(row[2])
    ids[row[2]] = row[0]

# This function scrapes the web page and saves the data to a table.  It is
# used if the syncronous routine is called.
def scrape_and_save(url):
    try:
        print('Scrapping ' + url)
        response = requests.get(url)
        html = str(response.text)
        data = (html, url)
        print('Saving ') + url
        conn.execute('''UPDATE `DICE_RAW_HTML` 
                     SET `html` = %s, scraped = 1 
                     WHERE `DICE_RAW_HTML`.`url` = %s;''', data)
        return 1
    except:
        return 0

# This function is used as part of the asynchronous routine.  It will scrape
# the webpage and return the data that will be saved in the database.
def scrape(url):
    print('Scrapping ' + url)
    response = requests.get(url)
    html = str(response.text)
    return (html, url)
        

# This is the async loop that will scrape and save the website data 
async def scrape_all(urls_to_scrape):
    # This handles the scraping
    loop = asyncio.get_event_loop()
    futures = [
        loop.run_in_executor(
            None,
            scrape,
            url
        )
        for url in urls_to_scrape
    ]
    # This handles the saving
    for response in await asyncio.gather(*futures):
        MySQL_id = ids[response[1]]
        print('Saving ' + response[1])
        data = (response[0], MySQL_id)
        conn.execute('''UPDATE `DICE_RAW_HTML` 
                     SET `html` = %s, scraped = 1 
                     WHERE `DICE_RAW_HTML`.`id` = %s;''', data)

## Sync routine (SLOW)
#for url in urls_to_scrape:
#       scrape_and_save(url)

# Async routine (FAST)
# We need to break up the URLs to process into smaller chunks

# Source: https://stackoverflow.com/questions/312443/how-do-you-split-a-list-into-evenly-sized-chunks
def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]
        
loop = asyncio.get_event_loop()
for urls in chunks(urls_to_scrape, 100):
    loop.run_until_complete(scrape_all(urls))
loop.close()

# Close the connection to the MySQL database
conn.close()
