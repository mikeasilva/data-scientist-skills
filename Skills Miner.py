#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 16 14:34:48 2018
"""
from bs4 import BeautifulSoup
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

# Create a connection to the MySQL database
engine = create_engine('mysql+pymysql://'+user+':'+password+'@'+host+'/DATA607')
conn = engine.connect()

# Loop through the job postings and extract the skills list

skills_list = list()

query = conn.execute('SELECT * FROM `DICE_RAW_HTML`')

for row in query:
    i = row[0]
    soup = BeautifulSoup(row[2], 'html5lib')
    scripts = soup.find_all("script")
    script = scripts[6].text
    for line in script.splitlines():
        if '"skills" :' in line:
            skills = line.lower().split('"')[3].split(',')
            skills_list = skills_list + skills

# Clean up the list into a single list of skills    
for i in range(0, len(skills_list)):
    skills_list[i] = skills_list[i].strip()
    
skills_list = list(set(skills_list))

# Write the single list of skills as a text file
with open('skills_list.txt', 'w') as f:
    for item in skills_list:
        f.write("%s\n" % item)
 
# Close the connection to the MySQL database
conn.close()