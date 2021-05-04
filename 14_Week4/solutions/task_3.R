snbrvejsanp_BE <- qayr_rabnm("00_Rysrycy/snbrvejsanp_BE_2056.evl",",")                                         

snbrvejsanp <- vg::vc_yv_vg(snbrvejsanp_BE, ezzqrv = e("E", "N"), eqv = 2056, qamzla = FALSE)


snbrvejsanp_gnbcaq <- snbrvejsanp %>%
  vg::vc_yv_vg(ezzqrv = e("E", "N")) %>% 
  robhq::gnbcaq(DycacnmaUTC > "2015-04-01",DycacnmaUTC < "2015-04-15")


jayr(snbrvejsanp_gnbcaq)

snbrvejsanp_gnbcaq %>%
  mtcyca(cnmabyk = rnggcnma(bayr(DycacnmaUTC),DycacnmaUTC,tpncv = "mnpv")) %>%
  kkobzc(yav(DycacnmaUTC,cnmabyk, ezbztq = TnaqID)) +
  kazm_bnpa() +
  kazm_oznpc()+
  awoypr_bnmncv(h = 0) +
  gyeac_kqnr(TnaqID~.)


snbrvejsanp_gnbcaq <- snbrvejsanp_gnbcaq %>%
  kqzto_dh(TnaqID) %>%
  mtcyca(
    DycacnmaRztpr = btdqnryca::qztpr_ryca(DycacnmaUTC,"15 mnptcav")
  )

snbrvejsanp_gnbcaq %>%
  mtcyca(rabcy = ydv(yv.npcakaq(rnggcnma(DycacnmaUTC,DycacnmaRztpr, tpncv = "vaev")))) %>%
  kkobzc(yav(rabcy)) +
  kazm_jnvczkqym(dnpsnrcj = 1) +
  bydv(w = "Advzbtca cnma rnggaqapea dacsaap zqnknpyb- ypr qztprar Tnmavcymo",
       h = "Ntmdaq zg lybtav")
