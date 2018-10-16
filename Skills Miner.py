#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 16 14:34:48 2018
"""
import pandas as pd
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
locations_list = list()
job_title_list = list()

query = conn.execute('SELECT * FROM `DICE_RAW_HTML`')

for row in query:
    lat = None
    lon = None
    i = row[0]
    soup = BeautifulSoup(row[2], 'html5lib')
    scripts = soup.find_all("script")
    script = scripts[6].text
    for line in script.splitlines():
        if '"skills" :' in line:
            skills = line.lower().split('"')[3].split(',')
            skills_list = skills_list + skills
        elif '"longitude" :' in line:
            lon = float(line.split('"')[3])
        elif '"latitude" :' in line:
            lat = float(line.split('"')[3])
        elif '"job_title": ' in line:
            job_title = line.lower().split('"')[3]
            job_title_list.append(job_title)
    locations_list.append((lat, lon))

# Clean up the list into a single list of skills
skills_counts = dict()
for i in range(0, len(skills_list)):
    key = skills_list[i].strip()
    skills_counts[key] = skills_counts.get(key, 0) + 1
    
skills_list = list(set(skills_counts.keys()))

# Write the single list of skills as a text file
with open('skills_list.txt', 'w') as f:
    for item in skills_list:
        f.write("%s\n" % item)

# Turn the skills counts into a CSV        
skills_counts_df = pd.DataFrame.from_dict(skills_counts, orient='index')
skills_counts_df.reset_index(inplace=True)
skills_counts_df.columns = ['skill', 'count']
skills_counts_df.to_csv('skills_counts.csv', index=False)

# Write the locations to a csv
with open('locations.csv', 'w') as f:
    f.write("lat,lon\n")
    for item in locations_list:
        f.write(str(item[0])+","+str(item[1])+"\n")

# Close the connection to the MySQL database
conn.close()