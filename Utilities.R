## Utilities.R


#' Run an SQL file query by query
#'
#' @param full_name The full text string
#'
get_location_short_name <- function(full_name){
  # The full_name follows this format:
  # city1-city2, state1-state2 Metro Area
  # We want the short name to be:
  # city1, state1
  # Example: Atlanta-Sandy Springs-Roswell, GA Metro Area becomes Atlanta, GA
  # Split the long name on ", "
  parts <- unlist(strsplit(full_name, ", "))
  # Extract the city name
  part1 <- unlist(strsplit(parts[1], "-"))
  part1 <- unlist(strsplit(part1[1], "/"))
  city_name <- part1[1] 
  # We want the first state listed in the 2nd part
  state_name <- substr(parts[2],0,2)
  # Here's the short name
  short_name <- (paste0(city_name,", ", state_name))
  short_name
}
                    
#' Run an SQL file query by query
#'
#' @param db_connection Database connection
#' @param file_path The path to the SQL file
#'
run_sql_script <- function(db_connection, file_path){
  # Open a connection to the SQL file
  con <- file(file_path, "r")
  # Initialize the SQL string
  sql_string <- ""
  while (TRUE){
    # Loop through the SQL file line by line
    line <- readLines(con, n = 1)
    if (length(line) == 0){
      # Break out of the loop
      break
    }
    # Check for comments
    if (grepl( "--", line) == TRUE){
      # Replace them with the /* */ type comments
      line <- paste(gsub("--", "/*", line), "*/")
    }
    # Add the line to the end of the SQL string
    sql_string <- paste(sql_string, line)
    # Check for the end of a query
    if (grepl(";", sql_string)){
      # Found one so execute the SQL string
      results <- dbSendQuery(db_connection, sql_string)
      # Clear the result set
      dbClearResult(results)
      # Reset the SQL string
      sql_string <- ""
    }
  }
  # Close the connection to the file
  close(con)
}

# Connects to a MySQL database
mysql_connect <- function(user, password, host, dbname = NULL){
  driver <- RMySQL::MySQL()
  conn <- dbConnect(driver, dbname = dbname, user = user, password = password, host = host)
  conn
}
