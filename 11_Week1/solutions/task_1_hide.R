# Data import ####
wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")

# Check Timezone
attr(wildschwein_BE$DatetimeUTC,"tzone") # or
wildschwein_BE$DatetimeUTC[1]
