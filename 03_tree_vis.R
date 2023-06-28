rm(list=ls())
setwd("C:/Users/YourUsername/R_folder/")

install.packages("tidyverse")
install.packages("ggtree")
install.packages("treeio")

library(tidyverse)
library(ggtree)
library(treeio)

tree <- read.tree("02_tree.treefile")
metadata <- read_csv('03_metadata.csv', show_col_types = FALSE)
genus_list <- read_csv('03_genus_list.csv')

#tree$tip.label # how to extract tip labels from tree object

#### PREPARE BASIC TREE ####

# print node labels and then reroot using manually selected node number
ggtree(tree) + geom_tiplab(size = 3) + geom_text2(aes(subset=!isTip, label=node), hjust=-.3)
ggsave("temp.pdf", width=20, height=40)
tree <- root(tree, outgroup=F, node = 450, resolve.root = T, interactive = F, edgelabel = TRUE)
p <- ggtree(tree) 

# prepare bootstrap object
d <- p$data
d <- d[!d$isTip,]
d$label <- as.numeric(d$label)

# prepare tip label object
new_metadata <- metadata %>%
  mutate(new_tip_labels = paste(Source_type, processid, species_name_tidy, Locality, bin_uri, sep = "_"))

d1 <- new_metadata %>% select(tip_labels, new_tip_labels)

# print bootstrap values on tree
p <- p %<+% d + geom_nodepoint(aes(subset = label > 50))
p <- p %<+% d1 + geom_tiplab(aes(label=new_tip_labels), size=2) + hexpand(.3)
p

ggsave("03_temp_with_bs.pdf", width=20, height=40)

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




