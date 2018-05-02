#' Tune a rijksPalette
#'
#' This function tunes the extracted palette from an image in a rijksPalette
#' object. Often, the defaults need to be tuned a little to get the nicest
#' results.
#'
#' @param x rijkspalette object
#' @param lightness overall lightness between 0 (darkest) and 1 (brightest)
#' @param k number of colours to extract
#' @param ... other arguments passed to tune function (not used)
#'
#' @export
tune <- function(x, lightness, k, ...) {
  UseMethod("tune")
}

#' @export
tune.rijkpalette <- function(x, lightness = 0.75, k = 5, ...) {
  x$cols <- labmatToPalette(x$labmat, k, lightness)
  x$palette <- grDevices::colorRampPalette(x$cols)
  return(x)
}


#' Plot rijkspalette
#'
#' Plots a rijkspalette with its source image
#'
#' @param x rijkspalette object
#' @param ... other arguments passed to plot function
#'
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

#' Print rijkspalette
#'
#' Prints a rijkspalette object with nice colours in the console
#'
#' @param x rijkspalette object
#' @param ... other arguments to print (not used)
#'
#' @seealso \code{\link{plot.rijkspalette}}
#' @seealso \code{\link{tune}}
#' @seealso \code{\link{explore}}
#'
#' @method print rijkspalette
#'
#' @export
print.rijkspalette <- function(x, ...) {
  cat("\n  Rijkspalette based on", crayon::underline(x$call$query))
  cat("\n\n  ")
  lapply(x$cols, function(co) cat(crayon::make_style(co, bg = TRUE)("  "), ""))
  cat("\n\n")
}


plot.rgbcols <- function(x, ...) {
  opt <- par(mar = c(1,1,1,1))
  barplot(rep(1, length(x)), space = 0, col = x, border = NA,
          axes = FALSE, asp = 1, ...)
  par(opt)
}


#' Plot labmat
#'
#' Plots a labmat object from a rijkspalette. It can be used for tuning the
#' required number of clusters.
#'
#' @importFrom graphics par points
#'
#' @param x a labmat object
#' @param k number of clusters to draw
#' @param ... other arguments passed to plot function
#'
#' @seealso \code{\link{explore}}
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

#' Explore the available colours in a rijkspalette
#'
#' This function plots the available colours in ab-space along with the chosen
#' cluster centroids. By manipulating the number of clusters, each distinct
#' colour category can receive its own centroid. This function was tested to
#' works in RStudio. The package `manipulate` is required for its function.
#'
#' @param x A rijkspalette object
#' @param ... other arguments passed to plot function
#'
#' @method explore rijkspalette
#'
#' @export
explore <- function(x, ...) {
  UseMethod("explore")
}

#' @rdname explore
#' @export
explore.rijkspalette <- function(x, ...) {
  if (requireNamespace("manipulate", quietly = TRUE)) {
    manipulate::manipulate(plot(x$labmat, k = 5, ...),
                           k = manipulate::slider(1, 15, 5,
                                                  label = "Number of clusters"))
  } else {
    warning("Package manipulate is not installed.",
            "For full exploration functionality, install it.")
    plot(x$labmat, ...)
  }
}
