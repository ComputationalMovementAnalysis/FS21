#############################################################################
## Plot Rasterdata in ggplot2 ###############################################
#############################################################################

# THIS SECTION WAS NOT PART OF THE EXERCISE. It's just here to help you work 
# with raster-data in ggplot in case you want to use this for your project.

# if we want to plot the data with ggplot, we'll have to import a new package:
# "RasterVis". Similar to working with ggmaps, we now initiate a ggplot using 
# a new command rather than the familiar command "ggplot()". We use "gplot()",
# but can then add data and options with "+" just like we'd do when creating a
# normal ggplot.

gplot(alti3d) +
  geom_tile(aes(colour = value)) +
  coord_fixed(ratio = 1)


# Using RasterVis, you could also plot colourcoded GeoTiffs like the "Swiss Map Raster",
# LK25/LK50 ect. The only challenge is extracting the colourcodes and pass them 
# on to ggplot. I've created a little function that you could use to solve this.

getColTab <- function(rasterfile, greyscale = F){
  # extract the colourtable with the function colortable() from the "raster" package
  colTab <- raster::colortable(rasterfile)
  # if you choose the option "greyscale", it will turn all colourvalues into greyscale
  if(greyscale == T){
    colTab <- col2rgb(colTab)
    colTab <- colTab[1,]*0.2126 + colTab[2,]*0.7152 + colTab[3,]*0.0722
    colTab <- rgb(colTab,colTab,colTab, maxColorValue = 255)
  }
  # gives each colour the name/code which LK25 uses 
  names(colTab) <- 0:(length(colTab)-1)
  # returns a "named character vector" that you can implement into ggplot2
  return(colTab)
}

# We can try this on some sampledata that I've downloaded* from swisstopo and added 
# to the zipfile:
# * http://www.swisstopo.admin.ch/internet/swisstopo/de/home/products/maps/national/digital/national.html

SMR25 <- raster("Rawdata/SMR25_Musterdaten/SMR25_LV03_KOMB_Mosaic.tif")

gplot(SMR25, maxpixels = 10e5) +
  geom_tile(aes(fill = factor(value))) +
  scale_fill_manual(values = getColTab(SMR25), guide = "none") +
  coord_fixed(ratio = 1)



