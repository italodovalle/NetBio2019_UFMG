library(igraph)
library(ggplot2)
library(diffusr)

### set working directory
setwd('~/projects/teaching/NetBio_UFMG2019/')

df = read.csv('data/HuRI.tsv', sep = '\t')

## build igraph object
g = graph_from_data_frame(df[,c('Ensembl_gene_id_a','Ensembl_gene_id_b')],directed = FALSE)


## disease module discovery

dt = read.csv('output/tables/alzheimers_ensembl_ids.csv')
seeds = dt$Gene.stable.ID
nodes = names(V(g))

seeds_intersec = intersect(nodes, seeds)

sub = subgraph(g, seeds_intersec)

## identify and delete nodes with degree 
k = as.data.frame(degree(sub))
k['nodes'] = rownames(k)

nodes0k = k[k[,1] == 0,2]

sub = delete_vertices(sub, nodes0k)


# network propagation

## get adjacency matrix
adj = get.adjacency(g)
adj = as.matrix(adj)

## create starting vector

### first, create a data frame with all nodes

seeds = names(V(sub))

buf = rep(0,dim(adj)[1])
dh = cbind(nodes, buf)
dh[,2] = as.integer(dh[,2])

dh[dh[,1] %in% seeds,2] = 1/length(seeds)

## create starting vector
h0 = as.numeric(dh[,2])


## run diffusion

## it takes ~8 min to run
ht = heat.diffusion(h0, adj)


