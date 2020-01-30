#########################################################################
## Master_File ##########################################################
#########################################################################

# This is the "Master" R-File. In this file, all other R-Scripts in a 
# data-analysis Project come together in the correct order. If you set 
# this up correctly, you can always process through your WHOLE project 
# in one go using this file.

# First, you need to set up your working directory. Change the following 
# directory to the one you will be using for this course:
setwd("C:/Users/nils/Dropbox/GEO880/Exercises/E5_Context/Solution")

source("Packages_libraries.R") # Loading all Packages
source("Custom_Functions.R")   # Load custom functions
source("Rawdata_import.R")     # Import the rawdata

#########################################################################
## Lesson 1 #############################################################
#########################################################################

source("L1/1.1_read_in_roe.data.R")
source("L1/1.2_format_date.time.R")
source("L1/1.3_transform_geocoordinates.R")
source("L1/1.4_plotting_ggplot.R") 
source("L1/1.5_plotting_move.R")


#########################################################################
## Lesson 2 #############################################################
#########################################################################

source("L2/2.x_defining_functions.R")

source("L2/2.1_joining_data.R")
source("L2/2.2_SAC_part_I.R")
source("L2/2.3_SAC_part_II.R")
source("L2/2.4_ggplot_facet.R")
source("L2/2.5_distance_speed_move.R")
# source("L2/2.6_multiscale_analysis.R")


#########################################################################
## Lesson 3 #############################################################
#########################################################################

source("L3/3.1_segmentation.R")
source("L3/3.2_stop_and_moves.R")
source("L3/3.3_similarity_measures.R")

source("L3/3.4_identifying_180min_fixes.R")

#########################################################################
## Lesson 4 #############################################################
#########################################################################

source("L4/4.1_piping_commands.R")
source("L4/4.2_finding_interactions.R")
source("L4/4.3_plotting_interactions_ggmap.R")

source("L4/4.x_moving_window.R")
source("L4/4.x_introduction_data.tables.R")
source("L4/4.x_plotting_interactions_leaflet.R")


#########################################################################
## Lesson 5 #############################################################
#########################################################################

source("L5/5.1_import_vector_data.R")
source("L5/5.2_import_raster_data.R")
source("L5/5.3_extracting_spatial_information.R")
source("L5/5.4_summarise_data.R")





