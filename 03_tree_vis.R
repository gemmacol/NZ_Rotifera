rm(list=ls())
setwd("C:/Users/YourUsername/R_folder/")

install.packages("tidyverse")
install.packages("ggtree")
install.packages("treeio")
install.packages("colorspace")

library(tidyverse)
library(ggtree)
library(treeio)
library(colorspace)

tree <- read.tree("02_tree.treefile")
dat <- read_csv('03_metadata.csv', show_col_types = FALSE)

# print node numbers, save, and manually find node to reroot ----------------------------------------------------------------

#ggtree(tree) + geom_tiplab(size = 3) + geom_text2(aes(subset=!isTip, label=node), hjust=-.3)
#ggsave("04_outputs/temp.pdf", width=20, height=40)

# prepare base tree ----------------------------------------------------------------

tree <- root(tree, outgroup=F, node = 450, resolve.root = T, interactive = F, edgelabel = TRUE)

# group tips by info_group name, for colouring branches later
info_group <- dat %>% select(tip_labels, info_group) %>%
  split(., .[, "info_group"]) %>%
  lapply(., function(x) x$tip_labels)

tree2 <- groupOTU(tree, info_group)

tree2

# build tree ----------------------------------------------------------------

p <- ggtree(tree2, aes(color=group)) +
  #theme(legend.position='none') +
  scale_color_manual(values=c("gray", "gray", rainbow_hcl(20))) 

p

# add new tip labels ----------------------------------------------------------------
d_names <- dat %>% select(tip_labels, new_labels, new_labels_subsets)

p2 <- p %<+% 
  d_names +
  geom_tiplab(aes(label=new_labels), parse=T, size=2.5)+#, align=F, family='mono')+
  hexpand(.5) +
  geom_treescale() #(x=2)

p2

# create bootstrap object
bs <- p$data
bs <- bs[!bs$isTip,]
bs$label <- as.numeric(bs$label)
bs

# add bs to tree
p3 <- p2 %<+% bs + geom_nodepoint(aes(subset = label < 50))
p3

ggsave("04_outputs/supplementary_full_tree.pdf", width=15, height=40)



# --------------------------------------------------------------------------------
# go through this section one genus at a time, then come back to the start and set a different genus name 

genus <- "Brachionus"
genus <- "Filinia"
genus <- "Keratella"
genus <- "Platyias"
genus <- "Polyarthra"
genus <- "Squatinella"
genus <- "Synchaeta"

genus <- "Lecane"
genus <- "Trichocerca"

sub <- treeio::drop.tip(tree, tree$tip.label[-c(grep(genus, tree$tip.label))], subtree = F)

# group tips by info_group_species name, for colouring branches later
info_group_species <- dat %>% select(tip_labels, info_group_species) %>%
  split(., .[, "info_group_species"]) %>%
  lapply(., function(x) x$tip_labels)

sub2 <- groupOTU(sub, info_group_species)

# find out number of colours needed

n_cols <- dat %>% filter(Genus==genus) 
n_cols <- length(unique(n_cols$species))

# make tree
p_sub <- ggtree(sub2, aes(color=group), layout="fan", open.angle=180) + #, size=1
  scale_color_manual(values=c("gray",rainbow_hcl(n_cols)))+ 
  #scale_color_manual(values=c("gray","gray",rainbow_hcl(n_cols)))+ # some issue with legend, activate this for lecane and trichocerca instead of above
  ggtitle(genus) + 
  geom_treescale() +
  xlim(-0.2, NA) # to change the diameter of the centre space
p_sub

# add bootstrap node points
p_sub2 <- p_sub %<+% bs + geom_nodepoint(aes(subset = label < 50)) 

# print tip labels
p_sub3 <- p_sub2 %<+% 
  d_names +
  geom_tiplab(aes(label=new_labels_subsets), parse=T, size=2.5, align=F)+#, family='mono')+
  hexpand(.5) +
  geom_treescale() #(x=2) 
p_sub3

ggsave(file = paste0("04_outputs/subtree_", genus, ".pdf"), width=15, height=15)






-----------------------------------------------------------------------------------------------------------------

# previous way of subsetting the tree: 

#### SUBSET TREE ####

## create the function
subtree_function <- function(genus) {
  subtree <- treeio::drop.tip(tree, tree$tip.label[-c(grep(genus, tree$tip.label))], subtree = F) 
  
  p <- ggtree(subtree) + geom_treescale()
  
  ## prepare bootstrap object
  d <- p$data
  d <- d[!d$isTip,]
  d$label <- as.numeric(d$label)
  
  ## print bs on tree
  p <- p %<+% d + geom_nodepoint(aes(subset = label > 50)) 
  p <- p %<+% d1 + geom_tiplab(aes(label=new_tip_labels), size=2) + hexpand(.3)
  p
  
  ggsave(file = paste0("03_subtree_", genus, ".pdf"), width=10, height=8)
  
}

## apply function to each genus 
for (i in 1:length(genus_list$genus_list_for_subtrees)) {
  
  genus <- genus_list$genus_list_for_subtrees[[i]]
  
  subtree_function(genus)
  
}




