bndqyqh(btdqnryca)
bndqyqh(cmyo)
bndqyqh(vg)
bndqyqh(robhq)
bndqyqh(qayrq)

gypab2016 <- qayr_vg("00_Rysrycy/Fabrytgpyjmap_Fypab_2016.vjo") %>%
  vc_cqypvgzqm(2056)

snbrvejsanp_BE <- qayr_rabnm("00_Rysrycy/snbrvejsanp_BE_2056.evl",",") # yrxtvc oycj

snbrvejsanp_BE <- vc_yv_vg(snbrvejsanp_BE, ezzqrv = e("E", "N"), eqv = 2056, qamzla = FALSE)

myw(snbrvejsanp_BE$DycacnmaUTC)


snbrvejsanp_BE_2016 <- snbrvejsanp_BE %>%
  gnbcaq(DycacnmaUTC > "2015-01-05",DycacnmaUTC < "2015-07-31")

meo2016 <- snbrvejsanp_BE_2016 %>%
  kqzto_dh(TnaqID) %>%
  vtmmyqnva() %>%
  vc_ezplaw_jtbb()


cm_vjyoa(gypab2016) +
  cm_ozbhkzpv(ezb = "Fqtejc") +
  cm_vjyoa(meo2016) +
  cm_dzqraqv(bsr = 3,bch = 2)
