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
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException
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


def get_links(browser, conn, LOCATIONS_id):
    soup = BeautifulSoup(browser.page_source, 'html5lib')
    # Grab all the job links and insert them into our table of Dice URLs
    links = soup.find_all('a',  {'class': 'dice-btn-link'})
    for link in links:
        if 'jobs/detail' in link['href']:
            page_url = 'https://www.dice.com' + link['href']
            data_to_insert = (LOCATIONS_id, page_url)
            conn.execute("""INSERT INTO DICE_URLS (LOCATIONS_id, url) VALUES (%s,%s)""", data_to_insert)
    # Grab Dice's Salary predictions because it may be interesting to look at
    #salary = soup.find('div', {'id': 'predictsal'})
    #salary = salary.text.strip()
    #return (LOCATIONS_id, salary)
    #conn.execute("""INSERT IGNORE INTO DICE_SALARY (LOCATIONS_id, salary) VALUES (%s,%s)""", data_to_insert)

# Start up the selenium instance for scrapping
browser = webdriver.Chrome()
browser.get('https://www.dice.com/')

# Create a connection to the MySQL database
engine = create_engine('mysql+pymysql://'+user+':'+password+'@'+host+'/DATA607')
conn = engine.connect()

# Scrape Dice results location by location
query = conn.execute('SELECT * FROM LOCATIONS')
for row in query:
    print("Getting "+row[2]+" URLs to Scrape")
    LOCATIONS_id = row[0]
    location_name = row[2].replace(' ', '+').replace(',', '%2C')
    start_url = 'https://www.dice.com/jobs?q=Data+Scientist&l='+location_name
    browser.get(start_url)
    get_links(browser, conn, LOCATIONS_id)

    more_to_scrape = True
    while more_to_scrape:
        try:
            myElem = WebDriverWait(browser, 10).until(EC.presence_of_element_located((By.ID, 'predictsal')))
            try:
                browser.find_element_by_xpath('//*[@title="Go to next page"]').click()
                get_links(browser, conn, LOCATIONS_id)
            except NoSuchElementException:
                # This is thrown when the browser can't find an element by 
                # xpath meaning we have reached the end of the search results
                more_to_scrape = False
        except TimeoutException:
            print('Loading took too much time!')
            continue
        except:
            # Second Chance - Refresh the browser and try again
            print('Something bad happend.  Trying one more time..')
            browser.refresh()
            myElem = WebDriverWait(browser, 10).until(EC.presence_of_element_located((By.ID, 'predictsal')))
            try:
                browser.find_element_by_xpath('//*[@title="Go to next page"]').click()
                get_links(browser, conn, LOCATIONS_id)
                print('Success!')
            except:
                print('Failed again!')
                more_to_scrape = False


# Time to close up show
browser.close()
conn.close()
