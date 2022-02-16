library(dplyr)
library(jsonlite)
library(readr)
options(timeout = 1000)

## get available countries
list_of_countries <- fromJSON("https://agsi.gie.eu/api/eic-listing/SSO/view") %>% 
  distinct(country) %>% 
  filter(country != "IE")

df_gas_storage <- data.frame()

## loop over countries and get storage data
for (i in c(list_of_countries$country, "eu")) {
  
  print(i)
  
  df_gas_storage_temp <- fromJSON(paste0("https://agsi.gie.eu/api/data/",i)) %>% 
    mutate(country = toupper(i))
  
  df_gas_storage <- bind_rows(df_gas_storage, df_gas_storage_temp)
}

## datawrangling
df_gas_storage <- df_gas_storage %>% 
  mutate(
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

current_date_unix <- as.numeric(round(as.POSIXct(Sys.time())), "minutes")
req <- fromJSON(paste0("https://query1.finance.yahoo.com/v8/finance/chart/TTF=F?symbol=TTF%3DF&period1=1514761200&period2=",current_date_unix,"&useYfid=true&interval=1d&includePrePost=true&events=div%7Csplit%7Cearn&lang=en-US&region=US&crumb=WsWFbvfVGqa&corsDomain=finance.yahoo.com"))

gas_price <- data.frame(
  date = req$chart$result$timestamp %>% unlist(),
  price = req$chart$result$indicators$adjclose %>% unlist()
) %>% 
  `rownames<-`(NULL) %>% 
  mutate(date = as.Date(as.POSIXct(date, origin = "1970-01-01", tz = "UTC")))

## EXPORT

### gas storage levels
df_gas_storage %>%
  filter(year>=2021 & !is.na(full) & plot_date != "2021-02-28") %>%
  select(country, country_name_nl, gasDayStartedOn, plot_date, year, full, full_avg, full_min, full_max, gasInStorage, currentLevel, diff) %>%
  filter(country_name_nl != "Ierland") %>%
  arrange(-year, currentLevel, desc(plot_date)) %>% 
  write_json("../webpage/src/data/storage_levels.json")

### gas prices
gas_price %>% 
  arrange(desc(date)) %>% 
  write_json("../webpage/src/data/gas_price.json")