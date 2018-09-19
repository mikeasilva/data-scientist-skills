## Setup.R

# The minimum number of people in the 2010 census to be in the study's universe
location_pop_threshold = 1000000

# Loop through the needed libraries
libraries <- c("DBI", "RMySQL", "censusapi", "dplyr")
for (l in libraries){
  # If the library is not installed, install it
  if(!is.element(l, .packages(all.available = TRUE))){
    install.packages(l)
  }
  # Load the library
  library(l, character.only = TRUE)
}

# Load in the credentials
source("Credentials.R")

# Load in the Utility functions
source("Utilities.R")

# Connect to the database
conn <- mysql_connect(mysql_user, mysql_password, mysql_host) # Function found in Utilities.R

#  Read in the SQL to set up the database
message("Setting up the MySQL Database")
run_sql(conn, "Setup Database.sql") # Function found in Utilities.R

# Disconnect from the database
disconnected <- dbDisconnect(conn)

# Connect to the database but specify the database name
conn <- mysql_connect(mysql_user, mysql_password, mysql_host, 'DATA607')

# Create a data.frame of locations we want to collect data for
source("Get Locations.R")

# Save the locations data.frame to MySQL
message("Saving locations to MySQL table")
dbWriteTable(conn, 'LOCATIONS', locations, append = TRUE)

# Disconnect from the database
disconnected <- dbDisconnect(conn)