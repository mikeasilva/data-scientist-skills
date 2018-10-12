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
# This dictionary will be the URL and the Location ID
urls_to_scrape = dict()
# This dictonary will hold the URL and the id in the DICE_URLS table
ids = dict()

sql = '''SELECT `DICE_URLS`.* 
FROM `DICE_URLS` 
LEFT JOIN `DICE_RAW_HTML` 
ON DICE_RAW_HTML.id = DICE_URLS.id 
WHERE DICE_RAW_HTML.id IS NULL'''

query = conn.execute(sql) 
for row in query:
    urls_to_scrape[row[2]] = row[1]
    ids[row[2]] = row[0]

# This will be the number of pages scraped
n_scraped = 0
 
def scrape_and_save(url):
    print('Scrapping ' + url)
    try:
        response = requests.get(url)
        i = ids[response.url]
        LOCATION_id = urls_to_scrape[response.url]
        conn.execute('''INSERT INTO `DICE_RAW_HTML` 
                     VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP);''', 
                     (i, LOCATION_id, response.url, response.content))
        return 1
    except:
        return 0
                 
async def scrape_all(urls_to_scrape):
    loop = asyncio.get_event_loop()
    futures = [
        loop.run_in_executor(
            None, 
            scrape_and_save, 
            url
        )
        for url in urls_to_scrape
    ]
    for response in await asyncio.gather(*futures):
        n_scraped = n_scraped + response
        #print('Saving ' + response.url)
        
 
loop = asyncio.get_event_loop()
loop.run_until_complete(scrape_all(urls_to_scrape))
loop.close()
     
conn.close()