## data prep



library(tidyverse)

data_vac <- vroom::vroom("../../data/COVID-19_Vaccinations_in_the_United_States_County.csv.tar.gz")
data_demo <- read_csv("../MB21-Day2/data/acs2017_county_data.csv")
data_pres <- read_csv("../MB21-Day2/data/pres20results.csv")

data_demo <- data_demo %>%
  rename(fips = CountyId)

data_vac <- data_vac %>%
  mutate(FIPS = FIPS %>% as.numeric()) %>%
  filter(!is.na(FIPS)) %>%
  rename(fips = FIPS)

data_vac <- 
  data_vac %>%
  mutate(Date = Date %>% as.Date(format = "%m/%d/%Y"))


data_pres <- data_pres %>%
  mutate(fips = as.numeric(fips)) %>%
  filter(!is.na(fips)) 

data_vac_latest <- data_vac %>% group_by(fips) %>%
  filter(Date == max(Date))


data_vac_quarterly <- data_vac %>% group_by(fips) %>%
  filter(Date %in% as.Date(c("2021-03-01", "2021-06-01","2021-09-01", "2021-12-01")))

data_trump <- data_pres %>%
  filter(candidate == "Donald Trump") %>%
  mutate(pct_trump = votes / total_votes)


data_merged <- 
  data_vac_latest %>%
  inner_join(data_trump %>% select(state, pct_trump, fips), by = "fips") %>%
  inner_join(data_demo %>% select(!c(State, County)) %>%
               select(!ends_with("Err")), by = "fips")

write_csv(data_merged, "data/vaccine-data.csv.gz")


data_merged_quarterly <- 
  data_vac_quarterly %>%
  inner_join(data_trump %>% select(state, pct_trump, fips), by = "fips") %>%
  inner_join(data_demo %>% select(!c(State, County)) %>%
               select(!ends_with("Err")), by = "fips")


write_csv(data_merged_quarterly, "data/vaccine-data-quarterly.csv.gz")
