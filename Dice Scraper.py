#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 29 12:14:51 2018

You must install the chrome driver for this script.  You can find it at:
https://sites.google.com/a/chromium.org/chromedriver/home

Move the file into C:\Windows\System32 or /usr/local/bin to "install" it
"""
from bs4 import BeautifulSoup
from selenium import webdriver
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


def scrape_page(browser, conn, LOCATIONS_id):
    soup = BeautifulSoup(browser.page_source, 'html5lib')
    links = soup.find_all('a',  {'class': 'dice-btn-link'})
    for link in links:
        if 'jobs/detail' in link['href']:
            page_url = 'https://www.dice.com' + link['href']
            browser.get(page_url)
            data_to_insert = (LOCATIONS_id, page_url, browser.page_source)
            conn.execute("""INSERT INTO DICE_RAW_HTML (LOCATIONS_id, url, html) VALUES (%s,%s, %s)""", data_to_insert)    
    
# Start up the selenium instance for scrapping
browser = webdriver.Chrome()
browser.get('https://www.dice.com/')

# Create a connection to the MySQL database
engine = create_engine('mysql+pymysql://'+user+':'+password+'@'+host+'/DATA607')
conn = engine.connect()

# Scrape Indeed location by location
query = conn.execute('SELECT * FROM LOCATIONS LIMIT 1')
for row in query:
    print(row[2])
    LOCATIONS_id = row[0]
    location_name = row[2].replace(' ', '+').replace(',', '%2C')
    start_url = 'https://www.dice.com/jobs?q=Data+Scientist&l='+location_name
    browser.get(start_url)
    scrape_page(browser, conn, LOCATIONS_id)
     
    more_to_scrape = True
    while more_to_scrape:
        try:
            browser.find_element_by_xpath('//*[@title="Go to next page"][0]').click()
            scrape_page(browser, conn, LOCATIONS_id)
        except:
            more_to_scrape = False

    

# Time to close up show
browser.close()
conn.close()