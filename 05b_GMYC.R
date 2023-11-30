rm(list=ls())
setwd("C:/Users/YourUsername/R_folder/")

install.packages(c("ape", "paran", "rncl"))
install.packages("splits", repos = "http://R-Forge.R-project.org")

library(rncl)

tree <- read_nexus_phylo("05a_ultrametric.tree")

print(tree)
library(splits)
yule_gmyc <- gmyc(tree)

summary(yule_gmyc)

plot(yule_gmyc)


specieslist<-spec.list(yule_gmyc)


yule_support <- gmyc.support(yule_gmyc)        # estimate support
is.na(yule_support[yule_support == 0]) <- TRUE # only show values for affected nodes
plot(tree, cex=.6, no.margin=TRUE)          # plot the tree
nodelabels(round(yule_support, 2), cex=.7)     # plot the support values on the tree

write.tree(yule_gmyc, file="mytree.newick")
write.table(specieslist, file="species_list.csv")
write.table(yule_support, file="yulesupport.csv")

print(yule_support)
print(yule_gmyc)


# you can visualise it here, but perhaps better to take the column of species numbers from output and put back into metadata to add as tip labels on trees. 
pdf("GMYC_support2.pdf", width = 20, height=30)
plot(tree, cex=.6, no.margin=TRUE) # plot the tree
nodelabels(round(yule_support, 2), cex=.7) # plot the support values
dev.off()
