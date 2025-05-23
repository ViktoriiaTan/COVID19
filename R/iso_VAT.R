#' Holy See
#'
#' @source \url{`r repo("VAT")`}
#' 
VAT <- function(level){
  x <- NULL
  
  #' @concept Level 1
  #' @section Data Sources:
  #' 
  #' ## Level 1
  #' `r docstring("VAT", 1)`
  #' 
  if(level==1){
    
    #' - \href{`r repo("github.cssegisanddata.covid19")`}{Johns Hopkins Center for Systems Science and Engineering}:
    #' confirmed cases,
    #' recovered.
    #'
    x <- github.cssegisanddata.covid19(country = "Holy See")

  }
  
  return(x)
}
