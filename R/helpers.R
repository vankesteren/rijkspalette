#' Image to palette
#'
#' Translates an image into a palette of 9 colours
#'
#' @param img cimg object from imager
#' @param k how many colours
#' @param lightness how light the returned palette should be
#'
#' @importFrom stats kmeans
#'
#' @keywords internal
imgToPalette <- function(img, k, brightness) {
  # resize and convert to lab colour space
  img512 <- imager::resize(img, 512, 512)
  lab <- imager::RGBtoLab(img512)

  # split into 961 pieces
  splitx <- imager::imsplit(lab,"x",-17)
  blocks <- unlist(lapply(splitx, function(i) imager::imsplit(i,"y",-17)),
                   recursive = FALSE)
  fuzzies <- lapply(blocks, function(i) imager::isoblur(i, 5))

  # get a matrix of mean colours
  labmat <- t(vapply(fuzzies, getMean, c(1.0,2.0,3.0), USE.NAMES = FALSE))

  # create 5 clusters in the a*b* space
  set.seed(142857)
  clusters <- kmeans(labmat[,-1],k)$cluster
  cluslist <- lapply(1:k, function(i) labmat[clusters == i,])

  # get a colour from each cluster based on the input brightness
  colours <- t(sapply(cluslist, function(m) {
    m[order(m[,1])[round(nrow(m)*brightness)],]
  }))

  # convert back to rgb via cimg (quite convoluted but works)
  labimg <- array(0, dim = c(1,k,1,3))
  labimg[1,,1,] <- colours
  rgbimg <- imager::LabtoRGB(labimg)

  # return rgb colours
  return(apply(rgbimg[1,,1,], 1, function(x) grDevices::rgb(x[1],x[2],x[3])))
}


#' @keywords internal
getMean <- function(img) {
  apply(img, 4, mean)
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

