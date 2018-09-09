## Utilities.R

#' Run an SQL file query by query
#'
#' @param db_connection Database connection
#' @param file_path The path to the SQL file
#'
run_sql <- function(db_connection, file_path){
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