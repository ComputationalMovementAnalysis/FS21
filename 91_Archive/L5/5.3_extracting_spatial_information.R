#############################################################################
## Enrich deer positions with spatial information ###########################
#############################################################################


# Extracting the information form a Rasterdataset is simple enough. All we need
# to do is perpare our input data in such a way, that "extract" expects it. 
# Note: I'm using "ungroup()" function so that our grouping variable is dropped

gps_roe_grouped$elevation <- raster::extract(alti3d, as.data.frame(select(ungroup(gps_roe_grouped), X,Y)))

# The same command can be used to extract the information from a spatialpolygondataframe.
# Note: I'm only assigning the data from the column "OBJEKTART", otherwise the whole attribute-
# table would be added to my roe deer data with alot of irrelevant information.

gps_roe_grouped$tlm_boden <- raster::extract(tlm_boden, 
                                             as.data.frame(select(ungroup(gps_roe_grouped), X,Y)))$OBJEKTART


# Let's have a look at our "elevation" data:
ggplot(gps_roe_grouped, aes(TierID, elevation, fill = TierID)) +
  geom_boxplot()
# Note: If you want to add the number of observations per plot, you can import the function
# provided by this stackoverflow answer: http://stackoverflow.com/a/3483657/4139249

# Let's have a look at our "landuse" data:
ggplot(gps_roe_grouped, aes(factor(tlm_boden), fill = TierID)) +
  geom_bar(stat = "count") +
  facet_wrap(~TierID)
