#' Public Health Agency of Canada
#'
#' Data source for: Canada
#'
#' @param level 1, 2
#'
#' @section Level 1:
#' - confirmed cases
#' - deaths
#' - recovered
#' - tests
#' - total vaccine doses administered
#' - people with at least one vaccine dose
#' - people fully vaccinated
#'
#' @section Level 2:
#' - confirmed cases
#' - deaths
#' - recovered
#' - tests
#' - total vaccine doses administered
#' - people with at least one vaccine dose
#' - people fully vaccinated
#'
#' @source https://www.canada.ca/en/public-health/services/diseases/coronavirus-disease-covid-19.html
#'
#' @keywords internal
#'
canada.ca <- function(level){
  if(!level %in% 1:2) return(NULL)
  
  # download cases
  # see https://health-infobase.canada.ca/covid-19/
  url <- "https://health-infobase.canada.ca/src/data/covidLive/covid19-download.csv"
  x1 <- read.csv(url, na.strings = c("", "-"))
  
  # format
  x1 <- map_data(x1, c(
    "date",
    "pruid"      = "id",
    "prname"     = "name",
    "numdeaths"  = "deaths",
    "totalcases" = "confirmed"
  ))
  
  # use vintage data because they are daily instead of weekly
  x1 <- bind_rows(extdata("ds/CAN.csv"), x1)
  x1 <- x1[!duplicated(x1[,c("id", "date")]),]
  
  # download total vaccine doses
  # see https://health-infobase.canada.ca/covid-19/vaccine-administration/
  url <- "https://health-infobase.canada.ca/src/data/covidLive/vaccination-administration.csv"
  x2 <- read.csv(url)
  
  # format
  x2 <- map_data(x2, c(
    "pruid" = "id",
    "report_date" = "date",
    "numtotal_all_administered" = "vaccines"
  ))
  
  # sanitize
  x2 <- x2[!duplicated(x2),]
  x2$vaccines <- as.integer(x2$vaccines)
  
  # download people vaccinated
  # see https://health-infobase.canada.ca/covid-19/vaccination-coverage/
  url <- "https://health-infobase.canada.ca/src/data/covidLive/vaccination-coverage-map.csv"
  x3 <- read.csv(url, fileEncoding = "UTF-8-BOM")
  
  # format
  x3 <- map_data(x3, c(
    "pruid" = "id",
    "week_end" = "date",
    "numtotal_atleast1dose" = "people_vaccinated",
    "numtotal_fully" = "people_fully_vaccinated"
  ))

  # download tests
  url <- "https://health-infobase.canada.ca/src/data/covidLive/covid19-epiSummary-labIndicators.csv"
  x4 <- read.csv(url, fileEncoding = "UTF-8-BOM")
  
  # format
  x4 <- map_data(x4, c(
    "pruid" = "id",
    "date" = "date",
    "numtests_total" = "tests"
  ))
  
  # merge
  by <- c("id", "date")
  x <- x1 %>%
    full_join(x2, by = by) %>%
    full_join(x3, by = by) %>%
    full_join(x4, by = by)

  # remove non-geographic entity
  x <- x[which(x$id!=99),] 

  # filter by level (id=1 -> Canada)
  if(level==1)
    x <- x[x$id==1,]   
  if(level==2)
    x <- x[x$id!=1,]  

  # convert date
  x$date <- as.Date(x$date)
  
  return(x)
}
