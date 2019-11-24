library(ReactomePA)
library(biomaRt)

setwd('~/projects/teaching/NetBio_UFMG2019/')


dt = read.csv('data/Alzheirmers_seeds.tsv', sep = '\t')

genes = dt$Gene_id

## map ensembl ids to entrez ids
mart <- useMart(biomart = "ensembl", dataset = "hsapiens_gene_ensembl")
converted = getBM(attributes = c("ensembl_gene_id"), filters = 'entrezgene_id',
                  values = genes, bmHeader = T, mart = mart)


write.csv(converted, 'output/tables/alzheimers_ensembl_ids.csv')
