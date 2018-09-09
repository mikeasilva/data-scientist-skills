## Setup.R

# Load the needed libraries
library("RMySQL")

# Load in the MySQL credentials
source("MySQL Settings.R")

# Load in the Utility functions
source("Utilities.R")

# Connect to the database
driver <- RMySQL::MySQL()
conn <- dbConnect(driver, user = user, password = password, host = host)

#  Read in the SQL to set up the database
setup_db_sql <- getSQL("Setup Database.sql") # Function found in Utilities.R
dbSendQuery(conn, setup_db_sql)

# Disconnect from the database
dbDisconnect(conn)