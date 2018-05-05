#' Rijkspalette function
#'
#' This function queries the Rijksmuseum collection for paintings and returns
#' a colour palette based on colours from that painting.
#'
#' @param query Keyword to search for in the collection of the Rijksmuseum
#'
#' @return an object of type \code{rijkspalette}
#'
#' @examples
#' pal <- rijksPalette("Vermeer Letter")
#' plot(pal)
#' barplot(1/sqrt(1:15), col = pal$palette(15))
#'
#' @seealso \code{\link{tune}}
#' @seealso \code{\link{explore}}
#'
#' @export
rijksPalette <- function(query) {
  call <- match.call()
  time <- Sys.time()
  downloadedImage <- rijksQuery(query)
  img <- imager::load.image(downloadedImage)
  labmat <- imgToLabmat(img)
  cols <- labmatToPalette(labmat, 5, 0.75)
  return(structure(list(call = call,
                        time = time,
                        imageLocation = downloadedImage,
                        img = img,
                        labmat = labmat,
                        cols = cols,
                        palette = grDevices::colorRampPalette(cols)),
                   class = "rijkspalette"))
}

