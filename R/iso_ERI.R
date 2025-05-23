#' Eritrea
#'
#' @source \url{`r repo("ERI")`}
#' 
ERI <- function(level){
  x <- NULL
  
  #' @concept Level 1
  #' @section Data Sources:
  #' 
  #' ## Level 1
  #' `r docstring("ERI", 1)`
  #' 
  if(level==1){
    
    #' - \href{`r repo("github.cssegisanddata.covid19")`}{Johns Hopkins Center for Systems Science and Engineering}:
    #' confirmed cases,
    #' deaths,
    #' recovered.
    #'
    x1 <- github.cssegisanddata.covid19(country = "Eritrea")
    
    #' - \href{`r repo("ourworldindata.org")`}{Our World in Data}:
    #' tests. 
    #' 
    x2 <- ourworldindata.org(id = "ERI")
    
    # merge
    x <- full_join(x1, x2, by = "date")
    
  }
  
  return(x)
}
