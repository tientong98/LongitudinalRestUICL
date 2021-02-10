
####################################################################################
#####################################  CPM .01   ###################################
####################################################################################

sbinge_01 <- readRDS("~/hpchome/rest/sbinge_01.RDS")
ebinge_01 <- readRDS("~/hpchome/rest/ebinge_01.RDS")

sbinge_01_Rpos_train <- mean(sbinge_01[[1]])
sbinge_01_Rneg_train <- mean(sbinge_01[[2]]) 
ebinge_01_Rpos_train <- mean(ebinge_01[[1]])
ebinge_01_Rneg_train <- mean(ebinge_01[[2]]) 

####################################################################################
#####################################  CPM .001   ###################################
####################################################################################

sbinge_001 <- readRDS("~/hpchome/rest/sbinge_001.RDS")
ebinge_001 <- readRDS("~/hpchome/rest/ebinge_001.RDS")

sbinge_001_Rpos_train <- mean(sbinge_001[[1]])
sbinge_001_Rneg_train <- mean(sbinge_001[[2]]) 
ebinge_001_Rpos_train <- mean(ebinge_001[[1]])
ebinge_001_Rneg_train <- mean(ebinge_001[[2]]) 

####################################################################################
#####################################  CPM .0001   ###################################
####################################################################################

sbinge_0001 <- readRDS("~/hpchome/rest/sbinge_0001.RDS")
ebinge_0001 <- readRDS("~/hpchome/rest/ebinge_0001.RDS")

sbinge_0001_Rpos_train <- mean(sbinge_0001[[1]])
sbinge_0001_Rneg_train <- mean(sbinge_0001[[2]]) 
ebinge_0001_Rpos_train <- mean(ebinge_0001[[1]])
ebinge_0001_Rneg_train <- mean(ebinge_0001[[2]]) 



#########################################################################################################
#########################################################################################################
#########################################################################################################


sbinge_0001spearmanlog_nogroup_pos <- as.data.frame(table(unlist(sbinge_0001spearmanlog_nogroup[[5]]))) %>%
  filter(Freq == 119)
sbinge_0001spearmanlog_nogroup_neg <- as.data.frame(table(unlist(sbinge_0001spearmanlog_nogroup[[6]]))) %>%
  filter(Freq == 119)

blank.matrix <- matrix(0, nrow = 300, ncol = 300)
blank.vector <- blank.matrix[lower.tri(blank.matrix, diag = F)]
for (i in sbinge_0001spearmanlog_nogroup_pos$Var1) {
  blank.vector[as.numeric(i)] <- 1
}
blank.matrix[lower.tri(blank.matrix, diag=F)] <- blank.vector
sbinge_0001spearmanlog_nogroup_pos.mat <- as.matrix(Matrix::forceSymmetric(blank.matrix, uplo="L"))
isSymmetric(sbinge_0001spearmanlog_nogroup_pos.mat)
rownames(sbinge_0001spearmanlog_nogroup_pos.mat) <- network$netName
colnames(sbinge_0001spearmanlog_nogroup_pos.mat) <- network$netName
# column sum for each seed
degree.pos <- apply(sbinge_0001spearmanlog_nogroup_pos.mat, 2, function(x) sum(x, na.rm = T))
degree.pos[degree.pos > 20]
# DefaultMode       DefaultMode SomatomotorDorsal 
# 50                34                21 
degree.pos.df <- as.data.frame(degree.pos) # seed 44, 45 DMN, 107 Somatomotor Dorsal
write.table(sbinge_0001spearmanlog_nogroup_pos.mat, "~/hpchome/rest/sbinge_0001spearmanlog_nogroup_pos.csv", 
            sep = ',', col.names = F, row.names = F)



blank.matrix <- matrix(0, nrow = 300, ncol = 300)
blank.vector <- blank.matrix[lower.tri(blank.matrix, diag = F)]
for (i in sbinge_0001spearmanlog_nogroup_neg$Var1) {
  blank.vector[as.numeric(i)] <- 1
}
blank.matrix[lower.tri(blank.matrix, diag=F)] <- blank.vector
sbinge_0001spearmanlog_nogroup_neg.mat <- as.matrix(Matrix::forceSymmetric(blank.matrix, uplo="L"))
isSymmetric(sbinge_0001spearmanlog_nogroup_neg.mat)
rownames(sbinge_0001spearmanlog_nogroup_neg.mat) <- network$netName
colnames(sbinge_0001spearmanlog_nogroup_neg.mat) <- network$netName
# column sum for each seed
degree.neg <- apply(sbinge_0001spearmanlog_nogroup_neg.mat, 2, function(x) sum(x, na.rm = T))
degree.neg[degree.neg > 20]
# Auditory  CinguloOpercular   DorsalAttention SomatomotorDorsal 
# 21                23                23                22 
degree.neg.df <- as.data.frame(degree.neg)
write.table(sbinge_0001spearmanlog_nogroup_neg.mat, "~/hpchome/rest/sbinge_0001spearmanlog_nogroup_neg.csv", 
            sep = ',', col.names = F, row.names = F)

heatmap(sbinge_0001spearmanlog_nogroup_pos.mat, labRow=network$netName, labCol=network$netName, 
        Rowv=NA, Colv=NA, ColSideColors=network$color, RowSideColors=network$color,symm = T)
heatmap(sbinge_0001spearmanlog_nogroup_neg.mat, labRow=network$netName, labCol=network$netName, 
        Rowv=NA, Colv=NA, ColSideColors=network$color, RowSideColors=network$color,symm = T)





melted_pos <- reshape2::melt(sbinge_0001spearmanlog_nogroup_pos.mat)
library(ggplot2)
ggplot(data = melted_pos, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()

ggcorrplot(sbinge_0001spearmanlog_nogroup_pos.mat)


#########################################################################################################
#########################################################################################################
#########################################################################################################

ebinge_0001spearmanlog_nogroup_pos <- as.data.frame(table(unlist(ebinge_0001spearmanlog_nogroup[[5]]))) %>%
  filter(Freq == 119)
ebinge_0001spearmanlog_nogroup_neg <- as.data.frame(table(unlist(ebinge_0001spearmanlog_nogroup[[6]]))) %>%
  filter(Freq == 119)

blank.matrix <- matrix(0, nrow = 300, ncol = 300)
blank.vector <- blank.matrix[lower.tri(blank.matrix, diag = F)]
for (i in ebinge_0001spearmanlog_nogroup_pos$Var1) {
  blank.vector[as.numeric(i)] <- 1
}
blank.matrix[lower.tri(blank.matrix, diag=F)] <- blank.vector
ebinge_0001spearmanlog_nogroup_pos.mat <- as.matrix(Matrix::forceSymmetric(blank.matrix, uplo="L"))
isSymmetric(ebinge_0001spearmanlog_nogroup_pos.mat)
rownames(ebinge_0001spearmanlog_nogroup_pos.mat) <- network$netName
colnames(ebinge_0001spearmanlog_nogroup_pos.mat) <- network$netName
# column sum for each seed
degree.pos <- apply(ebinge_0001spearmanlog_nogroup_pos.mat, 2, function(x) sum(x, na.rm = T))
degree.pos[degree.pos > 20]
# DefaultMode DefaultMode DefaultMode 
# 34          33          22 
degree.pos.df <- as.data.frame(degree.pos) # seed 44, 45 DMN
write.table(ebinge_0001spearmanlog_nogroup_pos.mat, "~/hpchome/rest/ebinge_0001spearmanlog_nogroup_pos.csv", 
            sep = ',', col.names = F, row.names = F)



blank.matrix <- matrix(0, nrow = 300, ncol = 300)
blank.vector <- blank.matrix[lower.tri(blank.matrix, diag = F)]
for (i in ebinge_0001spearmanlog_nogroup_neg$Var1) {
  blank.vector[as.numeric(i)] <- 1
}
blank.matrix[lower.tri(blank.matrix, diag=F)] <- blank.vector
ebinge_0001spearmanlog_nogroup_neg.mat <- as.matrix(Matrix::forceSymmetric(blank.matrix, uplo="L"))
isSymmetric(ebinge_0001spearmanlog_nogroup_neg.mat)
rownames(ebinge_0001spearmanlog_nogroup_neg.mat) <- network$netName
colnames(ebinge_0001spearmanlog_nogroup_neg.mat) <- network$netName
# column sum for each seed
degree.neg <- apply(ebinge_0001spearmanlog_nogroup_neg.mat, 2, function(x) sum(x, na.rm = T))
degree.neg[degree.neg > 20]
degree.neg.df <- as.data.frame(degree.neg)
write.table(ebinge_0001spearmanlog_nogroup_neg.mat, "~/hpchome/rest/ebinge_0001spearmanlog_nogroup_neg.csv", 
            sep = ',', col.names = F, row.names = F)

heatmap(ebinge_0001spearmanlog_nogroup_pos.mat, labRow=network$netName, labCol=network$netName, 
        Rowv=NA, Colv=NA, ColSideColors=network$color, RowSideColors=network$color,symm = T)
heatmap(ebinge_0001spearmanlog_nogroup_neg.mat, labRow=network$netName, labCol=network$netName, 
        Rowv=NA, Colv=NA, ColSideColors=network$color, RowSideColors=network$color,symm = T)

#########################################################################################################
#########################################################################################################
#########################################################################################################

library(igraph)
library(ggraph)
graph <- graph_from_adjacency_matrix(blank.matrix)
d1 <- data.frame(from="origin", to=paste("group", seq(1,10), sep=""))
d2 <- data.frame(from=rep(d1$to, each=10), to=paste("subgroup", seq(1,100), sep="_"))
hierarchy <- rbind(d1, d2)
all_leaves <- paste("subgroup", seq(1,100), sep="_")
connect <- rbind( 
  data.frame( from=sample(all_leaves, 100, replace=T) , to=sample(all_leaves, 100, replace=T)), 
  data.frame( from=sample(head(all_leaves), 30, replace=T) , to=sample( tail(all_leaves), 30, replace=T)), 
  data.frame( from=sample(all_leaves[25:30], 30, replace=T) , to=sample( all_leaves[55:60], 30, replace=T)), 
  data.frame( from=sample(all_leaves[75:80], 30, replace=T) , to=sample( all_leaves[55:60], 30, replace=T)) )
connect$value <- runif(nrow(connect))

# create a vertices data.frame. One line per object of our hierarchy
vertices  <-  data.frame(
  name = unique(c(as.character(hierarchy$from), as.character(hierarchy$to))) , 
  value = runif(111)
) 
# Let's add a column with the group of each name. It will be useful later to color points
vertices$group  <-  hierarchy$from[ match( vertices$name, hierarchy$to ) ]
# Create a graph object
mygraph <- graph_from_data_frame( hierarchy, vertices=vertices )
# The connection object must refer to the ids of the leaves:
from  <-  match( connect$from, vertices$name)
to  <-  match( connect$to, vertices$name)

library(RColorBrewer)
ggraph(mygraph, layout = 'dendrogram', circular = TRUE) + 
  geom_conn_bundle(data = get_con(from = from, to = to), width=1, alpha=0.2, aes(colour=..index..)) +
  scale_edge_colour_distiller(palette = "RdPu") +
  theme_void() +
  theme(legend.position = "none") + 
  geom_node_point(aes(filter = leaf, x = x*1.05, y=y*1.05, colour=group), size=3) +
  scale_colour_manual(values= rep( brewer.pal(9,"Paired") , 30))


ebinge_01spearmanraw <- readRDS("~/hpchome/rest/ebinge_01spearmanraw.RDS")
ebinge_001spearmanraw <- readRDS("~/hpchome/rest/ebinge_001spearmanraw.RDS")
ebinge_001spearmanlog <- readRDS("~/hpchome/rest/ebinge_001spearmanlog.RDS")
ebinge_001spearmanlog_nogroup <- readRDS("~/hpchome/rest/ebinge_001spearmanlog_nogroup.RDS")
ebinge_0001spearmanlog_nogroup <- readRDS("~/hpchome/rest/ebinge_0001spearmanlog_nogroup.RDS")
ebinge_0001spearmanlog_nogroup_pos <- as.data.frame(table(unlist(ebinge_0001spearmanlog_nogroup[[5]]))) %>%
  filter(Freq == 119)
ebinge_0001spearmanlog_nogroup_neg <- as.data.frame(table(unlist(ebinge_0001spearmanlog_nogroup[[6]]))) %>%
  filter(Freq == 119)

blank.matrix <- matrix(0, nrow = 300, ncol = 300)
blank.vector <- blank.matrix[lower.tri(blank.matrix, diag = F)]
for (i in ebinge_0001spearmanlog_nogroup_pos$Var1) {
  blank.vector[as.numeric(i)] <- 1
}
blank.matrix[lower.tri(blank.matrix, diag=F)] <- blank.vector
ebinge_0001spearmanlog_nogroup_pos.mat <- as.matrix(Matrix::forceSymmetric(blank.matrix, uplo="L"))
isSymmetric(ebinge_0001spearmanlog_nogroup_pos.mat)
write.table(ebinge_0001spearmanlog_nogroup_pos.mat, "~/hpchome/rest/ebinge_0001spearmanlog_nogroup_pos.csv", 
            sep = ',', col.names = F, row.names = F)



blank.matrix <- matrix(0, nrow = 300, ncol = 300)
blank.vector <- blank.matrix[lower.tri(blank.matrix, diag = F)]
for (i in ebinge_0001spearmanlog_nogroup_neg$Var1) {
  blank.vector[as.numeric(i)] <- 1
}
blank.matrix[lower.tri(blank.matrix, diag=F)] <- blank.vector
ebinge_0001spearmanlog_nogroup_neg.mat <- as.matrix(Matrix::forceSymmetric(blank.matrix, uplo="L"))
isSymmetric(ebinge_0001spearmanlog_nogroup_neg.mat)
write.table(ebinge_0001spearmanlog_nogroup_neg.mat, "~/hpchome/rest/ebinge_0001spearmanlog_nogroup_neg.csv", 
            sep = ',', col.names = F, row.names = F)


names <- c('Rpos', 'Rneg', 'RMSEpos', 'RMSEneg', 'pos_col_list', 'neg_col_list')

for (i in 1:length(names)) assign(names[i], results_sbinge_update[[i]])


###### p-values

obs_pval <- 2*mean(Rpos_per>=obs)
obs_pval

sorted_prediction descending
position <- which(sorted_prediction == observe)
pval <- position/no_interation

