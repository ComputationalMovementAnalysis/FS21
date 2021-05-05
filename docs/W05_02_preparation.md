## Preparation


```r
## Preparation ##################################################################
```

Open your R Project from last week. Either run your own script from last week or the following lines to transform the data into the form we need for today's exercise.



```r
library(tidyverse)
```

```
## Warning: Paket 'tidyverse' wurde unter R Version 4.0.5 erstellt
```

```
## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --
```

```
## v ggplot2 3.3.3     v purrr   0.3.4
## v tibble  3.1.1     v dplyr   1.0.5
## v tidyr   1.1.3     v stringr 1.4.0
## v readr   1.4.0     v forcats 0.5.1
```

```
## Warning: Paket 'ggplot2' wurde unter R Version 4.0.5 erstellt
```

```
## Warning: Paket 'tibble' wurde unter R Version 4.0.5 erstellt
```

```
## Warning: Paket 'tidyr' wurde unter R Version 4.0.5 erstellt
```

```
## Warning: Paket 'readr' wurde unter R Version 4.0.5 erstellt
```

```
## Warning: Paket 'purrr' wurde unter R Version 4.0.5 erstellt
```

```
## Warning: Paket 'dplyr' wurde unter R Version 4.0.5 erstellt
```

```
## Warning: Paket 'stringr' wurde unter R Version 4.0.5 erstellt
```

```
## Warning: Paket 'forcats' wurde unter R Version 4.0.5 erstellt
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(sf)
```

```
## Warning: Paket 'sf' wurde unter R Version 4.0.5 erstellt
```

```
## Linking to GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1
```

```r
library(ggspatial)
```

```
## Warning: Paket 'ggspatial' wurde unter R Version 4.0.4 erstellt
```

```r
library(raster)
```

```
## Warning: Paket 'raster' wurde unter R Version 4.0.5 erstellt
```

```
## Lade nötiges Paket: sp
```

```
## Warning: Paket 'sp' wurde unter R Version 4.0.5 erstellt
```

```
## 
## Attache Paket: 'raster'
```

```
## The following object is masked from 'package:dplyr':
## 
##     select
```

```
## The following object is masked from 'package:tidyr':
## 
##     extract
```

```r
# Import as tibble
wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")
```

```
## 
## -- Column specification --------------------------------------------------------
## cols(
##   TierID = col_character(),
##   TierName = col_character(),
##   CollarID = col_double(),
##   DatetimeUTC = col_datetime(format = ""),
##   Lat = col_double(),
##   Long = col_double()
## )
```

```r
# Convert to sf-object
wildschwein_BE <- st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326,remove = FALSE)

# transform to CH1903 LV95
wildschwein_BE <- st_transform(wildschwein_BE, 2056)

# Add geometry as E/N integer Columns
wildschwein_BE <- st_coordinates(wildschwein_BE) %>%
  cbind(wildschwein_BE,.) %>%
  rename(E = X) %>%
  rename(N = Y)
```


