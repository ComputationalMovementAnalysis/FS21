
ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4)

ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056)
