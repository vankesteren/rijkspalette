#' Image to palette
#'
#' Translates an image into a palette of 9 colours
#'
#' @param img cimg object from imager
#' @param lightness how light the returned palette should be
#'
#' @keywords internal
imgToPalette <- function(img, lightness = 0.5) {
  img512 <- imager::resize(img, 512, 512)
  splitx <- imager::imsplit(img512,"x",-171)
  blocks <- unlist(lapply(splitx, function(i) imager::imsplit(i,"y",-171)),
                   recursive = FALSE)
  fuzzies <- lapply(blocks, function(i) imager::isoblur(i, 10))
  return(structure(vapply(fuzzies, getRGB, "", pb = lightness,
                          USE.NAMES = FALSE),
                   class = c("character", "rijkscols")))
}

#' @importFrom stats quantile
#'
#' @keywords internal
getRGB <- function(im, pb) {
  medcols <- apply(im, 4, quantile, probs = pb)
  return(grDevices::rgb(medcols[1], medcols[2], medcols[3]))
}


#' @keywords internal
prefix <- "https://www.rijksmuseum.nl/api/nl/collection?q="

#' @keywords internal
suffix <- "&type=schilderij&key=1nPNPlLc&format=json"

#' Rijksquery
#'
#' performs query of the Rijksmuseum API
#'
#' @keywords internal
rijksQuery <- function(query) {
  result <- jsonlite::fromJSON(paste0(prefix, utils::URLencode(query), suffix))
  images <- result$artObjects[result$artObjects$hasImage,]
  if (nrow(images) == 0) stop("Query returned no results")
  imgurl <- paste0(images[1,]$webImage$url, "=s512")
  filename <- tempfile("image", fileext = ".jpg")
  utils::download.file(url = imgurl, destfile = filename, mode = "wb",
                       quiet = TRUE)
  return(filename)
}

