#' @exportMethod tune explore
#'
NULL

#' @title Tune a rijkspalette
#'
#' @description This function tunes the extracted palette from an image in a rijksPalette
#' object. Often, the defaults need to be tuned a little to get the nicest
#' results.
#'
#' @param x rijkspalette object
#' @param lightness overall lightness between 0 (darkest) and 1 (brightest)
#' @param k number of colours to extract
#'
#' @seealso \code{\link{explore}}
#'
#' @export
tune <- function(x, lightness, k) {
  UseMethod("tune")
}

#' @export
tune.rijkspalette <- function(x, lightness = 0.75, k = 5) {
  x$cols <- labmatToPalette(x$labmat, k, lightness)
  x$palette <- grDevices::colorRampPalette(x$cols)
  return(x)
}

#' @title Explore a rijkspalette
#'
#' @description This function plots the available colours in ab-space along with the cluster
#' centroids used to generate the palette. By manipulating the number of
#' clusters, each distinct colour category can receive its own centroid. This
#' function was designed to work in \code{RStudio}.
#'
#' @param x A rijkspalette object
#' @param ... other arguments passed to plot function
#'
#' @export
explore <- function(x, ...) {
  UseMethod("explore")
}

#' @export
explore.rijkspalette <- function(x, ...) {
  if (requireNamespace("manipulate", quietly = TRUE)) {
    manipulate::manipulate(plot(x$labmat, k, ...),
                           k = manipulate::slider(1, 15, 5,
                                                  label = "Number of clusters"))
  } else {
    warning("Package manipulate is not installed.",
            "For full exploration functionality, install it.")
    plot(x$labmat, ...)
  }
}

# R CMD CHECK fix for above function
globalVariables("k")

#' @importFrom graphics barplot
#' @importFrom graphics plot
#'
#' @method plot rijkspalette
#'
#' @export
plot.rijkspalette <- function(x, ...) {
  opt <- par(mar = c(1,1,1,1))
  graphics::layout(matrix(c(1,1,1,2), 1))
  plot(x$img, axes = FALSE)
  barplot(rep(1, length(x$cols)), space = 0, col = x$cols, border = NA,
          axes = FALSE, horiz = TRUE, asp = 1, ...)
  graphics::layout(1,1)
  par(opt)
}


#' @method print rijkspalette
#'
#' @export
print.rijkspalette <- function(x, ...) {
  cat("\n  Rijkspalette based on", crayon::underline(x$call$query))
  cat("\n\n  ")
  lapply(x$cols, function(co) cat(crayon::make_style(co, bg = TRUE)("  "), ""))
  cat("\n\n")
}

#' @method plot rgbcols
#'
#' @export
plot.rgbcols <- function(x, ...) {
  opt <- par(mar = c(1,1,1,1))
  barplot(rep(1, length(x)), space = 0, col = x, border = NA,
          axes = FALSE, asp = 1, ...)
  par(opt)
}


#' @importFrom graphics par points
#'
#' @method plot labmat
#'
#' @export
plot.labmat <- function(x, k = 5, ...) {
  # create k centers in the a*b* space
  set.seed(142857)
  centers <- kmeans(x[,-1], k)$centers

  # convert lab to rgb
  labimg <- array(0, dim = c(1,nrow(x),1,3))
  labimg[1,,1,] <- x
  rgbimg <- imager::LabtoRGB(labimg)

  rgbcols <- apply(rgbimg[1,,1,], 1, function(x) grDevices::rgb(x[1],x[2],x[3], 0.8))
  opt <- par(bg = "black", col = "white", col.lab = "white",
             col.main = "white", col.axis = "white")
  plot(x[,-1], pch = 21, bg = rgbcols, col = rgbcols, bty = "L",
       xlab = "a*", ylab = "b*", asp = 1, sub = paste(k, "centers"), ...)
  points(centers, pch = 22, cex = 1.5, bg  = "white", col = "black")
  par(opt)
}

