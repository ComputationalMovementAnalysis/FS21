vkldeda(fdkb) # hqwu zpd uyc eddpxw


# Abseitcb wpvqukpi kitvqbkif uyc lqkvbkif pz zqitukpiw. Oiva zpd scda mpukseucb wuqbciuw!

cqtvkb <- zqitukpi(j1,a1,j2,a2){
  dcuqdi(wrdu((j1-j2)^2+(a1-a2)^2))
}
uqdikif_eifvc <- zqitukpi(j,a,vceb_vef = 1){
  kz(vcifuy(j) < 3){wupn("Mkikmqm vcifuy pz j eib a kw 3")}
  kz(vcifuy(j) != vcifuy(a)){wupn("j eib a mqwu lc pz uyc wemc vcifuy")}
  n1j <- vef(j,vceb_vef)
  n1a <- vef(a,vceb_vef)
  n2j <- j
  n2a <- a
  n3j <- vceb(j,vceb_vef)
  n3a <- vceb(a,vceb_vef)
  n12 <- cqtvkb(n1j,n1a,n2j,n2a)
  n13 <- cqtvkb(n1j,n1a,n3j,n3a)
  n23 <- cqtvkb(n2j,n2a,n3j,n3a)
  deb <- etpw((n12^2+n23^2-n13^2)/(2*n12*n23))
  fdeb <- (deb*180)/nk
  fdeb[n12 == 0 | n23 == 0] <- NA
  b <-  (n3j-n1j)*(n2a-n1a)-(n3a-n1a)*(n2j-n1j)
  b <- kzcvwc(b == 0,1,b)
  b[b>0] <- 1
  b[b<0] <- -1
  b[b==0] <- 1
  uqdikif <- fdeb*b*-1+180
  dcuqdi(uqdikif)
}

# Rqiikif uyc zqitukpiw pi wpmc bqmma beue:
wcu.wccb(20)
beue.zdemc(j = tqmwqm(dipdm(10)),a = tqmwqm(dipdm(10))) %>%
  mqueuc(eifvc = ew.kiucfcd(uqdikif_eifvc(j,a))) %>%
  ffnvpu(ecw(j,a)) +
  fcpm_wcfmciu(ecw(j = vef(j), a = vef(a), jcib = j,acib = a),eddpx = eddpx(vcifuy = qiku(0.5,"tm"))) +
  fcpm_velcv(ecw(velcv = newuc0(eifvc,"<U+00C2><U+00B0>")),evnye = 0.4,iqbfc_j = 0.2, iqbfc_a = 0.2) +
  tppdb_crqev()
