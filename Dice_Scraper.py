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
urls_to_scrape = list()

sql = '''SELECT *
FROM `DICE_RAW_HTML`
WHERE scraped = 0'''

query = conn.execute(sql)
for row in query:
    urls_to_scrape.append(row[2])

# This function scrapes the web page and saves the data to a table
def scrape_and_save(url):
    try:
        print('Scrapping ' + url)
        response = requests.get(url)
        html = str(response.text)
        data = (html, url)
        conn.execute('''UPDATE `DICE_RAW_HTML` 
                     SET `html` = %s, scraped = 1 
                     WHERE `DICE_RAW_HTML`.`url` = %s;''', data)
        return 1
    except:
        return 0
    
def scrape(url):
    print('Scrapping ' + url)
    response = requests.get(url)
    html = str(response.text)
    return (html, url)
        

# This is the async loop
async def scrape_all(urls_to_scrape):
    loop = asyncio.get_event_loop()
    futures = [
        loop.run_in_executor(
            None,
            scrape,
            url
        )
        for url in urls_to_scrape
    ]
    for data in await asyncio.gather(*futures):
        print('Saving ' + data[1])
        conn.execute('''UPDATE `DICE_RAW_HTML` 
                     SET `html` = %s, scraped = 1 
                     WHERE `DICE_RAW_HTML`.`url` = %s;''', data)

# Sync (SLOW)
#for url in urls_to_scrape:
#       scrape_and_save(url)

# Async (FAST) but needs to be run multiple times
loop = asyncio.get_event_loop()
loop.run_until_complete(scrape_all(urls_to_scrape))
loop.close()

# Close the connection to the MySQL database
conn.close()
