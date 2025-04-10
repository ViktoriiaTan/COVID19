#' Commissario straordinario per l'emergenza Covid-19, Presidenza del Consiglio dei Ministri
#'
#' Data source for: Italy
#'
#' @param level 1, 2
#'
#' @section Level 1:
#' - total vaccine doses administered
#' - people with at least one vaccine dose
#' - people fully vaccinated
#'
#' @section Level 2:
#' - total vaccine doses administered
#' - people with at least one vaccine dose
#' - people fully vaccinated
#'
#' @source https://github.com/italia/covid19-opendata-vaccini
#'
#' @keywords internal
#'
github.italia.covid19opendatavaccini <- function(level){
  if(!level %in% 1:2) return(NULL)
  
  # download
  urls <- c("https://raw.githubusercontent.com/italia/covid19-opendata-vaccini/refs/heads/master/dati/somministrazioni-vaccini-latest-2020.csv",
            "https://raw.githubusercontent.com/italia/covid19-opendata-vaccini/refs/heads/master/dati/somministrazioni-vaccini-latest-2021.csv",
            "https://raw.githubusercontent.com/italia/covid19-opendata-vaccini/refs/heads/master/dati/somministrazioni-vaccini-latest-2022.csv",
            "https://raw.githubusercontent.com/italia/covid19-opendata-vaccini/refs/heads/master/dati/somministrazioni-vaccini-latest-2023.csv",
            "https://raw.githubusercontent.com/italia/covid19-opendata-vaccini/refs/heads/master/dati/somministrazioni-vaccini-latest-campagna-2023-2024.csv",
            "https://raw.githubusercontent.com/italia/covid19-opendata-vaccini/refs/heads/master/dati/somministrazioni-vaccini-latest-campagna-2024-2025.csv"
  )
  
  x <- dplyr::bind_rows(lapply(urls, read.csv))
  
  # format
  x <- map_data(x, c(
    "data" = "date",
    "forn" = "type",
    "N2" = "state",
    "d1" = "first",
    "d2" = "second",
    "dpi" = "oneshot",
    "db1" = "extra_1",
    "db2" = "extra_2",
    "db3" = "extra_3",
    "d" = "unsp_dose"
  ))
  
  # people vaccinated and total doses
  x <- x %>%
    dplyr::mutate(
          vaccines = coalesce(first, 0) + 
            coalesce(second, 0) + 
            coalesce(oneshot, 0) + 
            coalesce(extra_1, 0) + 
            coalesce(extra_2, 0) + 
            coalesce(extra_3, 0) + 
            coalesce(unsp_dose, 0),
          people_vaccinated = first + oneshot,
          people_fully_vaccinated = second + oneshot + first*(type=="Janssen"))
  
  if(level==1){
    
    # vaccines
    x <- x %>%
      # for each date
      dplyr::group_by(date) %>%
      # compute total counts
      dplyr::summarise(
        vaccines = sum(vaccines),
        people_vaccinated = sum(people_vaccinated),
        people_fully_vaccinated = sum(people_fully_vaccinated)) %>%
      # sort by date
      dplyr::arrange(date) %>%
      # cumulate
      dplyr::mutate(
        vaccines = cumsum(vaccines),
        people_vaccinated = cumsum(people_vaccinated),
        people_fully_vaccinated = cumsum(people_fully_vaccinated))  
  
  }
  
  if(level==2){
    
    # vaccines
    x <- x %>%
      # for each date and region
      dplyr::group_by(date, state) %>%
      # compute total counts
      dplyr::summarise(
        vaccines = sum(vaccines),
        people_vaccinated = sum(people_vaccinated),
        people_fully_vaccinated = sum(people_fully_vaccinated)) %>%
      # group by date
      dplyr::group_by(state) %>%
      # sort by date
      dplyr::arrange(date) %>%
      # cumulate
      dplyr::mutate(
        vaccines = cumsum(vaccines),
        people_vaccinated = cumsum(people_vaccinated),
        people_fully_vaccinated = cumsum(people_fully_vaccinated))  
    
  }

  # format date
  x$date <- as.Date(x$date)

  return(x)
}
