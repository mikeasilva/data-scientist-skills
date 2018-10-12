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

sql = '''SELECT `DICE_URLS`.* 
FROM `DICE_URLS` 
LEFT JOIN `DICE_RAW_HTML` 
ON DICE_RAW_HTML.url = DICE_URLS.url 
WHERE DICE_RAW_HTML.id IS NULL'''

query = conn.execute(sql) 
for row in query:
    urls_to_scrape[row[2]] = row[1]

# This function scrapes the web page and saves the data to a table
def scrape_and_save(url):
    try:
        print('Scrapping ' + url)
        response = requests.get(url)
        LOCATION_id = urls_to_scrape[url]
        html = str(response.text)
        data = (LOCATION_id, url, html)
        conn.execute('''INSERT INTO `DICE_RAW_HTML` 
                     VALUES (NULL, %s, %s, %s, CURRENT_TIMESTAMP);''', data)
        return 1
    except:
        return 0

# This is the async loop
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
        return 1
        #print('Saving ' + response.url)
        

urls = list(urls_to_scrape.keys())

# Sync (SLOW)
#for url in urls:
#       scrape_and_save(url)
        
# Async (FAST) But Needs to be run multiple times
loop = asyncio.get_event_loop()
loop.run_until_complete(scrape_all(urls))
loop.close()

     
conn.close()