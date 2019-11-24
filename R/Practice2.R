library(igraph)
library(ggplot2)
library(ReactomePA)
library(biomaRt)
library(sand)

### set working directory
setwd('~/projects/teaching/NetBio_UFMG2019/')


########### PART 1 ##########
#  HuRI Network             #
#  Calculate Centrality     #
#  Pathway Enrichment       #
#############################

df = read.csv('data/HuRI.tsv', sep = '\t')

## build igraph object
g = graph_from_data_frame(df[,c('Ensembl_gene_id_a','Ensembl_gene_id_b')],directed = FALSE)
vcount(g)
ecount(g)

## most central proteins


k = degree(g)
k = as.data.frame(k)
k['locus'] = rownames(k)

## closeness
cl = closeness(g)
cl$cl = as.data.frame(cl)
cl['locus'] = rownames(cl)
ggplot(cl, aes(x=cl)) + geom_histogram() + scale_y_continuous(trans = 'log10')


## betweenness
bc = betweenness(g)
bc = as.data.frame(bc)
bc['locus'] = rownames(bc)
ggplot(bc, aes(x=bc)) + geom_histogram() + scale_y_continuous(trans = 'log10')

ec = eigen_centrality(g)
ec = as.data.frame(ec[1])
ec['locus'] = rownames(ec)
ggplot(ec, aes(x=vector)) + geom_histogram() + scale_y_continuous(trans = 'log10')



## compare with essential genes
## http://ogee.medgenius.info/browse/
es = read.csv('data/EssentialGenes.txt', sep = '\t')
es = es[,c('locus', 'essential')]
es = es[!duplicated(es),]

merged = merge(k, es,by.x = 'locus',by.y = 'locus')


ggplot(merged, aes(x=essential, y=k)) +
  geom_boxplot() + scale_y_continuous(trans='log10')


x = merged[merged$essential == 'NE','k']
y = merged[merged$essential == 'E','k']

# independent 2-group Mann-Whitney U Test
wilcox.test(x,y)

## what are the most central proteins??

# sort by ec
ec = ec[order(ec$vector,decreasing = TRUE),]

top = ec[1:500,'locus']
## map ensembl ids to entrez ids
mart <- useMart(biomart = "ensembl", dataset = "hsapiens_gene_ensembl")
converted = getBM(attributes = c("entrezgene_id"), filters = 'ensembl_gene_id',
                  values = top, bmHeader = T, mart = mart)


enric = enrichPathway(as.character(converted$`NCBI gene ID`))
summary(enric)

dotplot(enric)

########### PART 2 ##########
#  Community Detection      #
#  Pathway Enrichment       #
#############################

library(sand)

?ppi.CC

parts <- fastgreedy.community(ppi.CC)
length(parts)
sizes(parts)
membership(parts)
plot(parts, ppi.CC)


## HuRI
parts <- fastgreedy.community(g)
length(parts)
sizes(parts)
mems = membership(parts)
which.max(sizes(parts))
x = names(mems)
y = as.vector(mems)
dx = as.data.frame(cbind(x,y))
write.csv(dx, 'output/tables/huri_communities.csv')


comm = dx[dx$y == 6,1]
converted = getBM(attributes = c("entrezgene_id"), filters = 'ensembl_gene_id',
                  values = comm, bmHeader = T, mart = mart)


enric = enrichPathway(as.character(converted$`NCBI gene ID`))
summary(enric)

dotplot(enric)