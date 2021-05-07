snbrvejsanp <- qayr_rabnm("00_Rysrycy/snbrvejsanp_BE_2056.evl",",")

snbrvejsanp_gnbcaq <- snbrvejsanp %>%
  gnbcaq(DycacnmaUTC > "2015-04-01",
         DycacnmaUTC < "2015-04-15") %>%
  gnbcaq(TnaqNyma %np% e("Rzvy", "Sydn"))
