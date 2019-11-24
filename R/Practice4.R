
library(igraph)
library(ggplot2)

### set working directory
setwd('~/projects/teaching/NetBio_UFMG2019/')

df = read.csv('data/HuRI.tsv', sep = '\t')

## build igraph object
g = graph_from_data_frame(df[,c('Ensembl_gene_id_a','Ensembl_gene_id_b')],directed = FALSE)


########### PART 1 #############
# significance of disease module
# randomization of node labels

## disease module discovery

dt = read.csv('output/tables/alzheimers_ensembl_ids.csv')
seeds = dt$Gene.stable.ID
nodes = names(V(g))
seeds_intersec = intersect(nodes, seeds)

get_disease_module_size = function(seeds, network){
  
  sub = subgraph(network, seeds)
  
  ## identify and delete nodes with degree 
  k = as.data.frame(degree(sub))
  k['nodes'] = rownames(k)
  
  nodes0k = k[k[,1] == 0,2]
  
  sub = delete_vertices(sub, nodes0k)
 
  size = vcount(sub)
  
  return (size)
   
}


real = get_disease_module_size(seeds_intersec, g)

r = c()

for (i in 1:100){
  
  random_seeds = sample(nodes,length(seeds_intersec))
  r[i] = get_disease_module_size(random_seeds, g)
  
  
}

hist(r)
abline(v= real,col='red')

p_empirical = length(r[r > real])/100


########### PART 2 ######################
# degree-preserving network randomization
# are the disease genes more central than expected by chance?


get_mean_centrality = function(seeds, network){
  ec = eigen_centrality(network)
  ec = as.data.frame(ec[1])
  ec['locus'] = rownames(ec)
  value = mean(ec[ec[,2] %in% seeds,1])
  return (value)
}

real = get_mean_centrality(seeds_intersec,g)
random = c()
for (i in 1:100){
  r = rewire(g, with = keeping_degseq(niter = vcount(g) * 10))
  random[i] = get_mean_centrality(seeds_intersec,g)
}

p_empirical = length(random[random > real])/length(random)
z_score = (real - mean(random))/sd(random)

