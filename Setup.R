## Setup.R

# Load the needed libraries
library("DBI")

# Load in the MySQL credentials
source("MySQL Settings.R")

# Load in the Utility functions
source("Utilities.R")

# Connect to the database
driver <- RMySQL::MySQL()
conn <- dbConnect(driver, user = user, password = password, host = host)

#  Read in the SQL to set up the database
run_sql(conn, "Setup Database.sql") # Function found in Utilities.R

# Disconnect from the database
disconnected <- dbDisconnect(conn)