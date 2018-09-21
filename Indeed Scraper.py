#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep 21 06:06:22 2018

You must install the chrome driver for this script.  You can find it at:
https://sites.google.com/a/chromium.org/chromedriver/home

Move the file into C:\Windows\System32 or /usr/local/bin to "install" it
"""

from bs4 import BeautifulSoup
from selenium import webdriver
from sqlalchemy import create_engine
#import pandas as pd


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
    

# Start up the selenium instance for scrapping
browser = webdriver.Chrome()
browser.get('https://www.indeed.com/')


# Create a connection to the MySQL database
engine = create_engine('mysql+pymysql://'+user+':'+password+'@'+host+'/DATA607')
conn = engine.connect()


# Scrape Indeed location by location
query = conn.execute('SELECT * FROM LOCATIONS')
for row in query:
    print(row[2])
    LOCATIONS_id = row[0]
    location_name = row[2].replace(' ', '+').replace(',', '%2C')
    start_url = 'https://www.indeed.com/jobs?q=data+scientist&l='+location_name
    browser.get(start_url)
    data_to_insert = (LOCATIONS_id, start_url, browser.page_source)
    conn.execute("""INSERT INTO INDEED_RAW_HTML (LOCATIONS_id, url, html) VALUES (%s,%s, %s)""", data_to_insert)    
     
    more_to_scrape = True
    while more_to_scrape:
        try:
            browser.find_element_by_link_text('Next »').click()
            data_to_insert = (LOCATIONS_id, browser.current_url, browser.page_source)
            conn.execute("""INSERT INTO INDEED_RAW_HTML (LOCATIONS_id, url, html) VALUES (%s,%s, %s)""", data_to_insert)    
        except:
            more_to_scrape = False
    
    

# Time to close up show
browser.close()
conn.close()