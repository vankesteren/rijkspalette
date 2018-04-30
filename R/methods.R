#' Set brightness for a rijkspalette
#'
#' Proper method stuff will be there soon.
#'
#' @param rp rijkspalette object
#' @param brightness between 0 (darkest) and 1 (brightest)
#'
#' @export
setBrightness <- function(rp, brightness = 0.5) {
  rp$cols <- imgToPalette(rp$img, brightness)
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
  st <- lapply(x$cols, crayon::make_style, bg = TRUE)
  cat("\n\n  ",
      st[[1]]("  "),
      st[[2]]("  "),
      st[[3]]("  "),
      st[[4]]("  "),
      st[[5]]("  "),
      st[[6]]("  "),
      st[[7]]("  "),
      st[[8]]("  "),
      st[[9]]("  "), "\n\n")
}
