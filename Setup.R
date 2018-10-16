## Setup.R

# Loop through the needed libraries
libraries <- c("DBI", "RMySQL", "dplyr")
for (l in libraries){
  # If the library is not installed, install it
  if(!is.element(l, .packages(all.available = TRUE))){
    install.packages(l)
  }
  # Load the library
  suppressMessages(library(l, character.only = TRUE))
}

# Load in the credentials
source("Credentials.R")

# Load in the Utility functions
source("Utilities.R")

# Connect to the database
conn <- mysql_connect(mysql_user, mysql_password, mysql_host) # Function found in Utilities.R

#  Read in the SQL to set up the database
message("Setting up the MySQL Database")
run_sql_script(conn, "MySQL Setup.sql") # Function found in Utilities.R

# Disconnect from the database
disconnected <- dbDisconnect(conn)

# Run python script to scrape Dice
system("python Dice_URL_Scraper.py")
