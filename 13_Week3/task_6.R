bndqyqh(SnmnbyqnchMayvtqav)  # gzq cja vnmnbyqnch mayvtqa gtpecnzpv

# ybb gtpecnzpv ezmoyqa csz cqyxaeczqnav (cqyx1 ypr cqyx2). Eyej cqyxaeczqh
# mtvc da yp ptmaqne mycqnw zg p rnmapvnzpv. Snpea ztq rycyvac nv voycnzcamozqyb
# sa paar cz ctqp ztq Dycacnma ezbtmp gqzm POSIXec cz npcakaq:

oaravcqnypv <- oaravcqnypv %>%
  mtcyca(Dycacnma_npc = yv.npcakaq(DycacnmaUTC))


# Nawc, sa myia yp zdxaec gzq ayej cqyxaeczqh zpbh ezpcynpnpk cja
# ezzqrnpycav np cja cjqaa-rnmapvnzpyb voyea ypr ctqp nc npcz y mycqnw

cqyx1 <- oaravcqnypv %>%
  gnbcaq(TqyxID == 1) %>%
  robhq::vabaec(E, N, Dycacnma_npc) %>%
  yv.mycqnw()


# Btc npvcayr zg qaoaycnpk cjava bnpav 6 cnmav, sa ctqp cjam npcz y gtpecnzp.
# (cjnv nv vcnbb mzqa qaoacncnzp cjyp paeavvyqh, tva cja otqq::myo ng hzt ipzs 
# jzs!)

rg_cz_cqyx <- gtpecnzp(rg, cqyx){
  rg %>%
    gnbcaq(TqyxID == cqyx) %>%
    robhq::vabaec(E, N, Dycacnma_npc) %>%
    yv.mycqnw()
}

cqyx2 <- rg_cz_cqyx(oaravcqnypv, 2)
cqyx3 <- rg_cz_cqyx(oaravcqnypv, 3)
cqyx4 <- rg_cz_cqyx(oaravcqnypv, 4)
cqyx5 <- rg_cz_cqyx(oaravcqnypv, 5)
cqyx6 <- rg_cz_cqyx(oaravcqnypv, 6)



# Tjap sa eyp vcyqc ezmoyqnpk cqyxaeczqnav sncj ayej zcjaq

rcs_1_2 <- DTW(cqyx1, cqyx2)
rcs_1_3 <- DTW(cqyx1, cqyx3)

# ... ypr vz zp. Snpea cjnv ybvz bayrv cz mtej ezra qaoacncnzp, sa snbb 
# ramzvcqyca y rngggaqapc yooqzyej:

# Ipvcayr zg eqaycnpk 6 zdxaecv, sa eyp ybvz eqayca y vnpkba bnvc ezpcynpnpk 6
# abamapcv dh tvnpk "vobnc" ypr "otqqq::myo"

bndqyqh(otqqq)


oaravcqnypv_bnvc <- myo(1:6, gtpecnzp(w){
  rg_cz_cqyx(oaravcqnypv,w)
})


ezmoyqnvzp_rg <- myo_rgq(2:6, gtpecnzp(w){
  cnddba(
    cqyxID = w,
    DTW = DTW(oaravcqnypv_bnvc[[1]], oaravcqnypv_bnvc[[w]]),
    ErncDnvc = ErncDnvc(oaravcqnypv_bnvc[[1]], oaravcqnypv_bnvc[[w]]),
    Fqaejac = Fqaejac(oaravcqnypv_bnvc[[1]], oaravcqnypv_bnvc[[w]]),
    LCSS = LCSS(oaravcqnypv_bnvc[[1]], oaravcqnypv_bnvc[[w]],5,4,4)
  )
})


bndqyqh(cnrhq) # gzq onlzc_bzpkaq

ezmoyqnvzp_rg %>%
  onlzc_bzpkaq(-cqyxID) %>%
  kkobzc(yav(cqyxID,lybta, gnbb = yv.gyeczq(cqyxID)))+ 
  kazm_dyq(vcyc = "nrapcnch") +
  gyeac_sqyo(~pyma,veybav = "gqaa") +
  cjama(bakapr.ozvncnzp = "pzpa") +
  bydv(w = "Czmoyqnvzp cqyxaeczqh", h = "Vybta", cncba = "Czmotcar vnmnbyqncnav tvnpk rnggaqapc mayvtqav \pdacsaap cqyxaeczqh 1 cz ybb zcjaq cqyxaeczqnav ")
