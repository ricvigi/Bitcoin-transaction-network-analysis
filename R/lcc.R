getwd()
library(tidyverse)
setwd("/home/rick/Ri/SecondYear/2ndSemester/DMAU2/project/blocks/tseries/APIrequests/0bigsequence/")
setwd("~")
library(igraph)
library(ggplot2)
library(ggraph)
library(tidygraph)


er_lcc <- c()
start <- 0
finish <- 200000
step <- 400
for(p in seq(from = start, to = finish, by = step)){
  edges_slice <- edges[0:p,]
  nodes_slice <- unique(c(edges_slice$sender, edges_slice$receiver))
  edges_filtered <- edges[edges$sender %in% nodes_slice | edges$receiver %in% nodes_slice, ]
  nodes_filtered <- unique(c(edges_filtered$sender, edges_filtered$receiver))
  G <- network(edges_filtered, nodes_filtered)
  lcc = max(components(G)$csize)
  er_lcc = c(er_lcc, lcc)
}

plot(main="LCC w.r.t slice size(400)",
     x = seq(from = start, to = finish, by = step),
     y = er_lcc, xlab = "slice_size",
     ylab = "LCC")
