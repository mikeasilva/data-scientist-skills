# Get Locations.R

message("Getting the Metro 2010 Population via the Census API")
pop2010 <- getCensus(name = "dec/sf1", 
                     vintage = 2010, 
                     vars = c("NAME", "P001001"), 
                     region = "metropolitan statistical area/micropolitan statistical area") %>%
  rename(GEOID = metropolitan_statistical_area_micropolitan_statistical_area,
         api_name = NAME,
         population = P001001) %>%
  filter(population >= location_pop_threshold)


if(!file.exists('2017_Gaz_cbsa_national.txt')){
  message("Downloading the Census Bureau's 2017 Gazetteer for Coordinates")
  temp <- tempfile()
  download.file("http://www2.census.gov/geo/docs/maps-data/data/gazetteer/2017_Gazetteer/2017_Gaz_cbsa_national.zip", temp)
  unzip(temp)
  unlink(temp)
}

message("Getting Location Data from the Census Bureau's 2017 Gazetteer")
# Read in the tab seperated file
locations <- read.delim('2017_Gaz_cbsa_national.txt', 
                        colClasses = c('GEOID'='character')) %>%
  filter(CBSA_TYPE == 1) %>%
  merge(pop2010) %>%
  mutate(full_name = as.character(NAME)) %>%
  rowwise() %>%
  mutate(short_name = get_location_short_name(full_name)) %>%
  ungroup() %>%
  rename(id = GEOID,
         latitude = INTPTLAT,
         longitude = INTPTLONG) %>%
  select(id, full_name, short_name, population, latitude, longitude)
  
message(paste("There are", nrow(locations),"Metro areas with a population at or above", location_pop_threshold))
