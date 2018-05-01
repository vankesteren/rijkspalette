# rijkspalette

[![Build Status](https://travis-ci.org/vankesteren/rijkspalette.svg?branch=master)](https://travis-ci.org/vankesteren/rijkspalette)

An R package to generate palettes based on famous paintings from the Rijksmuseum. This package uses the fantastic [Rijksmuseum API](http://rijksmuseum.github.io/). 


# Installation

Installation is simple when you have `R` and the package `devtools` installed:
```R
devtools::install_github("vankesteren/rijkspalette")
```

## Usage

As an example, let's make a palette based on Vermeer's famous painting of a woman reading a letter.
```R
library(rijkspalette)
letter <- rijksPalette("Vermeer Letter")
letter
```
![console](img/console.png)

The colours show up immediately in the `R` console, but not very precisely because it only accepts 256 colours. Maybe we should look at the palette a bit better:

```R
plot(letter)
```

![vermeer](img/vermeer.png)

The palette works well for the above image. However, when a painter uses many colours this does not always work well:

```R
appel <- rijksPalette("Karel Appel")
plot(appel)
```
![appel5](img/appel5.png)

Luckily, we can tune both the number of colours and the brightness of those colours:

```R
appel <- tune(appel, brightness = 0.8, k = 7)
plot(appel)
```
![appel5](img/appel7.png)


That's better. Now let's use the two most relevant items inside this object. First, the `cols` slot contains the extracted colours in hexadecimal format:

```R
appel$cols
```

```
[1] "#9C4734" "#C79734" "#29384D" "#C0C4B0" "#426C73" "#7A8D8B" "#155F7A"
```

And the `palette` object is a `colorRampPalette` function to be used in plots and such:

```R
barplot(1:15, col = appel$palette(15))
```

![barplot](img/barplot.png)

This can become practically continuous through interpolation:

```R
barplot(rep(1,1500), col = appel$palette(1500), border = NA, space = 0, 
        axes = FALSE)
```

![contpal](img/contpal.png)

Try it out yourself! Do post your palette on twitter with the `#rijkspalette` hashtag :)
