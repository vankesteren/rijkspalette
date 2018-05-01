#' Tune a rijksPalette
#'
#' This function tunes the extracted palette from an image in a rijksPalette
#' object. Often, the defaults need to be tuned a little to get the nicest
#' results.
#'
#' @param rp rijkspalette object
#' @param brightness overall brightness between 0 (darkest) and 1 (brightest)
#' @param k number of colours to extract
#'
#' @export
tune <- function(rp, brightness = 0.7, k = 5) {
  rp$cols <- imgToPalette(rp$img, k, brightness)
  rp$palette <- grDevices::colorRampPalette(rp$cols)
  return(rp)
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
  graphics::layout(matrix(c(1,1,1,2), 1))
  plot(x$img, axes = FALSE)
  barplot(rep(1, length(x$cols)), space = 0, col = x$cols, border = NA,
          axes = FALSE, horiz = TRUE, ...)
  graphics::layout(1,1)
}

#' Print rijkspalette
#'
#' Prints a rijkspalette object with nice colours in the console
#'
#' @param x rijkspalette object
#' @param ... other arguments to print (not used)
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
