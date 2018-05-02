#' Image to small lab coordinate matrix
#'
#' Translates an image into a palette of 9 colours
#'
#' @param img cimg object from imager
#'
#'
#' @keywords internal
imgToLabmat <- function(img) {
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
  return(structure(labmat, class = "labmat"))
}

#' @keywords internal
getMean <- function(img) {
  apply(img, 4, mean)
}

#' Labmat to palette
#'
#' Translates a labmat to a colour palette
#'
#' @param labmat a n*3 matrix signifying Lab space coordinates
#' @param k how many colours
#' @param lightness how light the returned palette should be
#'
#' @importFrom stats kmeans
#'
#' @keywords internal
labmatToPalette <- function(labmat, k, lightness) {
  # create k clusters in the a*b* space
  set.seed(142857)
  clusters <- kmeans(labmat[,-1], k)$cluster
  cluslist <- lapply(1:k, function(i) labmat[clusters == i,])

  # get a colour from each cluster based on the input lightness
  colours <- t(sapply(cluslist, function(m) {
    m[order(m[,1])[round(nrow(m)*lightness)],]
  }))

  # convert back to rgb via cimg (quite convoluted but works well)
  labimg <- array(0, dim = c(1,k,1,3))
  labimg[1,,1,] <- colours
  rgbimg <- imager::LabtoRGB(labimg)

  # get rgb cols and hsv form
  rgbcols <- apply(rgbimg[1,,1,], 1, function(x) grDevices::rgb(x[1],x[2],x[3]))
  hsvcols <- grDevices::rgb2hsv(t(rgbimg[1,,1,]))

  # return rgb colours ordered by hue
  return(structure(rgbcols[order(hsvcols[1,])], class = "rgbcols"))
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

