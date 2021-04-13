bndqyqh(kqnr) # xtvc gzq cja yqqzsv


# Arlypear vzbtcnzp npebtrnpk cja dtnbrnpk zg gtpecnzpv. Opbh gzq laqh mzcnlycar vctrapcv!

atebnr <- gtpecnzp(w1,h1,w2,h2){
  qactqp(vuqc((w1-w2)^2+(h1-h2)^2))
}
ctqpnpk_ypkba <- gtpecnzp(w,h,bayr_byk = 1){
  ng(bapkcj(w) < 3){vczo("Mnpnmtm bapkcj zg w ypr h nv 3")}
  ng(bapkcj(w) != bapkcj(h)){vczo("w ypr h mtvc da zg cja vyma bapkcj")}
  o1w <- byk(w,bayr_byk)
  o1h <- byk(h,bayr_byk)
  o2w <- w
  o2h <- h
  o3w <- bayr(w,bayr_byk)
  o3h <- bayr(h,bayr_byk)
  o12 <- atebnr(o1w,o1h,o2w,o2h)
  o13 <- atebnr(o1w,o1h,o3w,o3h)
  o23 <- atebnr(o2w,o2h,o3w,o3h)
  qyr <- yezv((o12^2+o23^2-o13^2)/(2*o12*o23))
  kqyr <- (qyr*180)/on
  kqyr[o12 == 0 | o23 == 0] <- NA
  r <-  (o3w-o1w)*(o2h-o1h)-(o3h-o1h)*(o2w-o1w)
  r <- ngabva(r == 0,1,r)
  r[r>0] <- 1
  r[r<0] <- -1
  r[r==0] <- 1
  ctqpnpk <- kqyr*r*-1+180
  qactqp(ctqpnpk)
}

# Rtppnpk cja gtpecnzpv zp vzma rtmmh rycy:
vac.vaar(20)
rycy.gqyma(w = etmvtm(qpzqm(10)),h = etmvtm(qpzqm(10))) %>%
  mtcyca(ypkba = yv.npcakaq(ctqpnpk_ypkba(w,h))) %>%
  kkobzc(yav(w,h)) +
  kazm_vakmapc(yav(w = byk(w), h = byk(h), wapr = w,hapr = h),yqqzs = yqqzs(bapkcj = tpnc(0.5,"em"))) +
  kazm_bydab(yav(bydab = oyvca0(ypkba,"<U+00C2><U+00B0>")),ybojy = 0.4,ptrka_w = 0.2, ptrka_h = 0.2) +
  ezzqr_autyb()
