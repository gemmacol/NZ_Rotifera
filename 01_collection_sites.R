rm(list=ls())
setwd("C:/Users/YourUsername/R_folder/")

install.packages("rnaturalearth")
install.packages("ggplot2")
install.packages("ggspatial")
install.packages("ggrepel")

library("rnaturalearth")
library("ggplot2")
library("ggspatial")
library("ggrepel")

sites=read.csv("01_NZ_Rotifer_sites.csv")

# Set lat/lon boundaries (x=longitude y=latitude)
#all of NZ
xlim <- c(165, 179)
ylim <- c(-48, -34)

#North Island
xlim <- c(174, 177)
ylim <- c(-39, -36)

#South Island
xlim <- c(168, 173)
ylim <- c(-45, -43)

fill="steelblue"
colour="black"

world <- ne_countries(scale = "medium", returnclass = "sf")

#with site names
ggplot(data = world) +
  geom_sf() +
  coord_sf(crs = "+init=epsg:2193") +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(3, "in"), pad_y = unit(0.25, "in"),
                         style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  geom_point(data=sites, aes(x=long, y=lat), shape = "circle filled", fill = fill, colour=colour, size=4) +
  geom_text_repel(data=sites, aes(x=long, y=lat, label=site_name)) +
  xlab("Longitude") + ylab("Latitude")+
  theme_bw(base_size = 20)

#no site names
ggplot(data = world) +
  geom_sf() +
  coord_sf(crs = "+init=epsg:2193") +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(3, "in"), pad_y = unit(0.25, "in"),
                         style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  geom_point(data=sites, aes(x=long, y=lat), shape = "circle filled", fill = fill, colour=colour, size=3) +
  xlab("Longitude") + ylab("Latitude")+
  theme_bw(base_size = 25)

#################################################################
# Could otherwise use terrain or other type of map background
install.packages("ggmap")
library("ggmap")

maptype="terrain-background"
maptype="watercolor"
maptype="toner-lite" # with regional boundaries

map <- get_stamenmap(bbox = c(left = 166, bottom = -48, right = 179, top = -34), zoom = 7, maptype = maptype)
ggmap(map)

# add collection data points
map1 = ggmap(map)+geom_point(data=sites, aes(x=long, y=lat), shape = "circle filled", fill = "slateblue1", colour="slateblue4", size=3) +
  xlab("Longitude") + ylab("Latitude")+
  theme_linedraw(base_size = 15)
map1

