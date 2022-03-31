library(dplyr)
library(jsonlite)
library(readr)
library(httr)
options(timeout = 1000)
apiKey <- "392e5031c111057ef77c084bc42a192c"

## get available countries
list_of_countries <- jsonlite::fromJSON("https://agsi.gie.eu/api/eic-listing/SSO/view") %>% 
  distinct(country) %>% 
  filter(!(country %in% c("IE","UA")))

df_gas_storage <- data.frame()

## loop over countries and get storage data
for (i in c(list_of_countries$country, "eu")) {
  
  print(i)
  
  req <- GET(paste0("https://agsi.gie.eu/api/data/",i), httr::add_headers('x-key' = apiKey))
  stop_for_status(req)
  
  df_gas_storage_temp <- jsonlite::fromJSON(rawToChar(req$content)) %>% 
    mutate(country = toupper(i))
  
  df_gas_storage <- bind_rows(df_gas_storage, df_gas_storage_temp)
}

## datawrangling
df_gas_storage <- df_gas_storage %>% 
  mutate(
    country = gsub("\\*","",country),
    country_name = ifelse(country == "EU", "European Union", countrycode::countrycode(country, origin = 'iso2c', destination = 'country.name')),
    country_name_nl = ifelse(country == "EU", "Europese Unie", countrycode::countrycode(country, origin = 'iso2c', destination = 'cldr.name.nl')),
    gasDayStartedOn = as.Date(gasDayStartedOn, "%Y-%m-%d"),
    full = as.numeric(full),
    trend = as.numeric(trend),
    injection = as.numeric(injection),
    withdrawal = as.numeric(withdrawal),
    gasInStorage = as.numeric(gasInStorage),
    year = lubridate::year(gasDayStartedOn),
    plot_date = as.Date(paste0("2021-", format(gasDayStartedOn,"%m-%d")))
  ) %>% 
  filter(!is.na(gasInStorage)) %>% 
  arrange(gasDayStartedOn) %>%
  group_by(country, year) %>% 
  mutate(
    cumWithdrawal = cumsum(withdrawal)
  ) %>% 
  ungroup() %>% 
  group_by(country, plot_date) %>% 
  mutate(
    full_avg = mean(full[year <= 2020], na.rm =T),
    full_min = min(full[year <= 2020], na.rm =T),
    full_max = max(full[year <= 2020], na.rm =T),
    withdrawal_avg = mean(cumWithdrawal[year <= 2020 & year >= 2015], na.rm =T),
    withdrawal_min = min(cumWithdrawal[year <= 2020 & year >= 2015], na.rm =T),
    withdrawal_max = max(cumWithdrawal[year <= 2020 & year >= 2015], na.rm =T),
    gasInStorage_avg = mean(gasInStorage[year <= 2020 & year >= 2015], na.rm =T)
  ) %>% ## calculate avg storage level, exc year 2021
  ungroup() %>% 
  mutate(
    full = full/100,
    full_avg = full_avg / 100,
    full_min = full_min / 100,
    full_max = full_max / 100,
    country = toupper(country)
  ) %>%
  group_by(country) %>% 
  mutate(
    currentLevel = full[gasDayStartedOn == max(gasDayStartedOn, na.rm = T) & full > 0],
    diff = (currentLevel - full_avg[gasDayStartedOn == max(gasDayStartedOn, na.rm = T) & full > 0]) * 100
  ) %>%
  ungroup()

## Get price data
print("downloading price data")
current_date_unix <- as.numeric(round(as.POSIXct(Sys.time())), "minutes")
req <- jsonlite::fromJSON(paste0("https://query1.finance.yahoo.com/v8/finance/chart/TTF=F?symbol=TTF%3DF&period1=1514761200&period2=",current_date_unix,"&useYfid=true&interval=1d&includePrePost=true&events=div%7Csplit%7Cearn&lang=en-US&region=US&crumb=WsWFbvfVGqa&corsDomain=finance.yahoo.com"))

gas_price <- data.frame(
  date = req$chart$result$timestamp %>% unlist(),
  price = req$chart$result$indicators$adjclose %>% unlist()
) %>% 
  `rownames<-`(NULL) %>% 
  mutate(date = as.Date(as.POSIXct(date, origin = "1970-01-01", tz = "UTC")))

## EXPORT

### gas prices
gas_price %>% 
  arrange(desc(date)) %>% 
  write_json("../webpage/src/data/gas_price.json")

gas_price %>% 
  arrange(desc(date)) %>% 
  write_csv("../webpage/src/data/gas_price.csv")
