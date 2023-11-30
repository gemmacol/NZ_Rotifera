# NZ_Rotifera

## Aim
All data files and scripts to recreate figures from the paper

## 1. Create the map of NZ with collection locations 

Script: 01_collection_sites.R 

Input: 01_NZ_Rotifer_sites.csv

Output: (ggsave) --> inkscape --> 01_collection_sites.png

## 2. Create the tree using IQ-TREE v2.2.0

IQ-TREE command: bin\iqtree2 -s 02_alignment.phy -B 1000 -nm 3000 -bnni -T AUTO -m MFP

Input: 02_alignment.phy

Outputs: 02_tree.treefile, 02_IQ-tree.log


## 3. Create the overall phylogenetic tree, and a set of trees for each genus

Script: 03_tree_vis.R

Inputs: 02_tree.treefile, 03_metadata.csv, 03_genus_list.csv

Outputs: supplementary_full_tree.pdf, subtree_{genus}.pdf

## 4. Perform the barcode gap analysis

Script: 04_barcode_gap_analysis.R

Inputs: 03_metadata.csv, 04_alignment.fasta

Outputs: 04_distmatrix.csv, 04_barcodegap.png, 04_barcodegap_{genus}.png

## 5. Perform the GMYC analysis

### 5a create ultrametric bifurcating tree in BEAST

BEAUti priors: 05a_priors.xml

Run this twice in BEAST 

Combined the two outputs into one new tree: 05a_ultrametric.tree

### 5b GMYC analysis in R

Script: 05b_GMYC.R

Input: 05a_ultrametric.tree

Outputs: 05b_species_list.csv, 05b_yulesupport.csv

Note: added the species list column back to the original 03_metadata.csv file and replotted the tree with this information in tip labels 



