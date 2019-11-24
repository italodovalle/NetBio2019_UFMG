library(igraph)
library(ggplot2)

########### PART 1 ##########
#  Summary of the data      #
#  Clean and edit the table #
#  Save cleaned table       #
#############################

### set working directory
setwd('~/projects/teaching/NetBio_UFMG2019/')

## load edge list
dt = read.csv('data/BIOGRID-ORGANISM-3.5.178.mitab/BIOGRID-ORGANISM-Plasmodium_falciparum_3D7-3.5.178.mitab.txt',
              sep = '\t')


# let's have a look on the information present in the table
colnames(dt)
dim(dt)

## what are the types of evidences?

unique(df$Interaction.Detection.Method)


# let's make sure with we have only interactions for plasmodium proteins

unique(dt$Taxid.Interactor.A)
unique(dt$Taxid.Interactor.B)

df = dt[dt$Taxid.Interactor.A == 'taxid:36329',]
df = df[dt$Taxid.Interactor.B == 'taxid:36329',]

dim(dt)
dim(df)

# adjust the identifies

## create new columns with the identifiers edited to have only the protein name

df['proteinA'] = NA
df['proteinB'] = NA

df$X.ID.Interactor.A = as.character(df$X.ID.Interactor.A)
df$ID.Interactor.B = as.character(df$ID.Interactor.B)
df['proteinA'] = sapply(df$X.ID.Interactor.A, function(x) unlist(strsplit(x,':'))[2],USE.NAMES=FALSE)
df['proteinB'] = sapply(df$ID.Interactor.B, function(x) unlist(strsplit(x,':'))[2],USE.NAMES=FALSE)

## let's save a smaller table for visualization in cytoscape

res = df[,c('proteinA', 'proteinB')]
res = res[complete.cases(res), ]

write.csv(res, 'output/tables/plasmodium_edgelist.csv')

########### PART 2 ##########
#  Visualize in Cytoscape   #
#############################



############ PART 3 ##########
# Check degree distribution  #
##############################

res = read.csv('output/tables/plasmodium_edgelist.csv')

## build igraph object
g = graph_from_data_frame(res[,c('proteinA','proteinB')],directed = FALSE)
vcount(g)
ecount(g)

## degree distribution
hist(degree(g))

## what are the hubs??

k = as.data.frame(degree(g))
k['node'] = row.names(k)
colnames(k) = c('degree', 'node')
head(k[order(k$degree,decreasing = TRUE),],n=20)

## plot degree distribution - Histogram
hist(k$degree, plot=TRUE,prob=TRUE)

## plot degree distribution log-log scale
d.plasmodium <- degree(g)

## a numeric vector of the same length as the maximum degree plus one. The first element is the relative frequency zero degree vertices, the second vertices with degree one, etc.
dd.plasmodium <- degree.distribution(g)


d <- 1:max(d.plasmodium)-1 ## create a sequence of values up to the maximum degree
ind <- (dd.plasmodium != 0)
plot(d[ind], dd.plasmodium[ind], log="xy", col="blue",
     xlab=c("Log-Degree"), ylab=c("Log-Intensity"),
     main="Log-Log Degree Distribution")