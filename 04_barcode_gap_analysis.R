rm(list=ls())
setwd("C:/Users/YourUsername/R_folder/")

install.packages("ape")
install.packages("spider")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("devtools")
devtools::install_github("G-Thomson/Manu")
install.packages("tidyverse")

library(ape)
library(spider)
library(ggplot2)
library(dplyr)
library(Manu)
library(tidyverse)

# NOTE: Be sure that metadata and sequences are arranged in exactly the same order !!!
d_meta <- read.csv("03_metadata.csv") 
sequences <- ape::read.FASTA("04_alignment.fasta", type="DNA") 
genus_list <- read_csv('03_genus_list.csv')

d_sp <- as.data.frame(unique(d_meta$species_name_barcode_gap)) # isolate unique species names
d_vec <- as.character(d_meta$species_name_barcode_gap) # create a vector of species names for the dataset

#### Loop to calculate intraspecific divergences ####
Intraspecies.dat<-data.frame() # Create blank dataframe to store data generated from Loop

for (i in 1:nrow(d_sp)){           # for each species
  species.group       <- d_meta[d_meta$species_name_barcode_gap %in% d_sp[i,],] # make a list of all sequences for a species
  species.seqs        <- sequences[names(sequences) %in% species.group$tip_labels_xx] # isolates the sequences for that species
  Intraspecies.dist   <- ape::dist.dna(species.seqs, model="raw", pairwise.deletion = TRUE) # calculates p-distances among sequences with pairwise deletions
  Intraspecies.dat    <- rbind(Intraspecies.dat, c(nrow(species.group),           # calculates the minimum, mean, and maximum intraspecific divergence
                                                   min(Intraspecies.dist), mean(Intraspecies.dist),
                                                   sd(Intraspecies.dist),  max(Intraspecies.dist))) # and adds it to the dataframe
}

Intraspecies.dat    <- cbind(Intraspecies.dat, d_sp)                          # merge the species name with the generated data
names(Intraspecies.dat) <- c("Sequences", "MinIntra", "MeanIntra", 
                             "SD", "MaxIntra", "Species")                          # label the columns


##### Interspecies Divergences ######
distmatrix          <- ape::dist.dna(sequences, model="raw", pairwise.deletion = TRUE)           # create distance matrix of all sequences using p-distance with pairwise deletions
distmatrix_toexport <- ape::dist.dna(sequences, model="raw", pairwise.deletion = TRUE, as.matrix=T) 
write.csv(distmatrix_toexport, "04_distmatrix.csv")

nonconspeciesDist   <- as.data.frame(cbind(d_vec, 
                                           spider::nonConDist(distmatrix, d_vec)))                     # calculate the smallest interspecies distance (aka Nearest Neighbour - NN) for each species

interspecies.dat<-data.frame()                                                            # create blank dataframe to store data from loop

for (i in 1:nrow(d_sp)){       # for each species
  species.group      <- nonconspeciesDist[nonconspeciesDist[,1] %in% d_sp[i,],]        # make a list of all NN distances for a species
  interspecies.dat   <- rbind(interspecies.dat, 
                              min(as.numeric(as.character(species.group[,2]))))           # pull out the smallest interspecific distance recorded for the species
}

interspecies.dat<-cbind(interspecies.dat, d_sp)                                        # merge the species name with the data
names(interspecies.dat)<-c("MinInter", "Species")                                        # label the columns


##### Combine the data and plot #####
BarcodeGap   <- merge(Intraspecies.dat, interspecies.dat, by = c("Species"))              # merge the dataframes into one
#BarcodeGap   <- na.omit(BarcodeGap[- grep("sp.", BarcodeGap$Species),])                   # could use this to remove species with "sp." in their name, and species lacking intraspecific values. Or see filter option below. 
write.csv(BarcodeGap, "04_barcode_gap_results.csv")

BarcodeGap <- BarcodeGap %>% filter(MaxIntra>0.01) #filter out those with basically no intraspecific variation (clearly a barcode gap, just cluttering the graph)

selected_colours <- get_pal("Hoiho") # uses Manu package 
colours <- colorRampPalette(selected_colours)(31)

ggplot(BarcodeGap)+                          # species above the line have a barcode gap
  geom_point(aes(y=MinInter, x=MaxIntra, color = Species, shape = Species), size = 3) +
  scale_shape_manual(values = rep(0:24, len=31))+
  scale_colour_manual(values=colours)+
  theme(panel.border =  element_rect(colour = "black", fill=NA),
        panel.background = element_rect(colour="white", fill="white"),
        axis.line = element_line(size = 0.5, linetype = "solid", colour = "black"),
        axis.text = element_text(colour ="black", size=8),
        strip.background=element_rect(fill=NA),
        strip.text=element_text(size=11))+
   scale_x_continuous(expand = c(0, 0), limits = c(0, 0.25)) + 
   scale_y_continuous(expand = c(0, 0), limits = c(0, 0.2)) +
  labs(y="Min Interspecific P-Distance", "Max Intraspecific P-Distance")+ 
  geom_abline()

ggsave(filename="04_barcodegap.png")


# make a for loop for each genus
barcode_gap_function <- function(genus) {
  
  BarcodeGap   <- na.omit(BarcodeGap[grep(genus, BarcodeGap$Species),])
  
  ggplot(BarcodeGap)+                          
    geom_point(aes(y=MinInter, x=MaxIntra, shape = Species)) +
    scale_shape_manual(values = 0:7)+
    #scale_shape_identity()+
    theme(panel.border =  element_rect(colour = "black", fill=NA),
          panel.background = element_rect(colour="white", fill="white"),
          axis.line = element_line(size = 0.5, linetype = "solid", colour = "black"),
          axis.text = element_text(colour ="black", size=8),
          strip.background=element_rect(fill=NA),
          strip.text=element_text(size=11))+
    scale_x_continuous(expand = c(0, 0), limits = c(0, 0.25)) + 
    scale_y_continuous(expand = c(0, 0), limits = c(0, 0.2)) +
    labs(y="Min Interspecific P-Distance", "Max Intraspecific P-Distance")+ 
    geom_abline()
  
  ggsave(file = paste0("04_barcodegap_", genus, ".png"))
  
}

## apply function to each genus 
for (i in 1:length(genus_list$full_genus_list)) {
  
  genus <- genus_list$full_genus_list[[i]]
  
  barcode_gap_function(genus)
  
}



