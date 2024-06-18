getwd()
setwd("/home/rick/Ri/SecondYear/2ndSemester/DMAU2/project/blocks/tseries/APIrequests/0bigsequence/")

library(igraph)
library(dplyr)
library(viridis)
# edge list
edges = read.csv("blocks/txedgelist_0000000000000000ebed3e2b0cf036d577ffec8a7c4015d64499e8a791b82c0b.csv")
edges
filtered_edges = edges[150:250, ]
#filtered_edges
filtered_edges_nodes <- unique(c(filtered_edges$sender, filtered_edges$receiver))
#filtered_edges_nodes



# node list
NL = read.csv("blocks/txnodelist_0000000000000000ebed3e2b0cf036d577ffec8a7c4015d64499e8a791b82c0b.csv")
NL
# Filter the nodes to include only those present in the filtered edges
filtered_nodes <- NL[NL$name %in% filtered_edges_nodes, ]



edge_colors <- rep("black", ecount(g))  # Default color for all edges
edge_colors[out_edges]
E(g)[from(V(g)[5])]
for (v in V(g)) {
  out_edges <- E(g)[from(v)]
  in_edges <- E(g)[to(v)]
  edge_colors[out_edges] <- "red"
  edge_colors[in_edges] <- "blue"
}


g <- graph_from_data_frame(d=filtered_edges, vertices=filtered_edges_nodes, directed=TRUE)
layout <- layout_with_kk(g) 
plot(g, layout=layout_with_kk, vertex.label=NA, vertex.size=6.7, edge.arrow.size=0.4) 
 
mat <- as_adjacency_matrix(g)

mat
plot(mat)



#############################à
library(igraph)
library(tidygraph)
library(tidyverse )
library(ggraph)
set_graph_style()

# edge list
edges = read.csv("blocks/tseries/txedgelist_0000000000000000003da033bd60d190a13bab11f27029827d5b7948d3237f2d.csv")
edges
#filtered_edges
filtered_edges = edges[1900:2300, ]

#filtered_edges_nodes
filtered_edges_nodes <- unique(c(filtered_edges$sender, filtered_edges$receiver))
head(filtered_edges_nodes)

filtered_edges_nodes_df <- data.frame(name = filtered_edges_nodes, stringsAsFactors = FALSE)

# filtered_edges = edges[2000:3000,]
length(edges$sender)

# Assuming `filtered_nodes` is your data frame
# Check the length of the reference string
reference_length <- nchar("e3a77159938953ea5a7a397faa360439ba0a9eae249fe158380d48ac8ad5e283")

# Add the `type` column based on the length comparison
filtered_edges_nodes_df$type <- ifelse(nchar(filtered_edges_nodes_df$name) < reference_length, 0, 1)
head(filtered_edges_nodes_df)

head(filtered_nodes)
filtered_nodes

head(filtered_edges_nodes)
G = graph_from_data_frame(d=filtered_edges, v = filtered_edges_nodes_df)
G %>% ggraph(layout = "sugiyama") +
geom_edge_fan(aes(color=type), width = .5) +
geom_node_point(aes(color=type), size = 3) +
scale_color_viridis()
head(filtered_edges)

#### full function ######


edges <- read.csv("blocks/tseries/3_blocks_test.csv")
foo <- function(i, j, edges) {
  filtered_edges = edges[i:j, ]
  filtered_edges_nodes <- unique(c(filtered_edges$sender, filtered_edges$receiver))
  filtered_edges_nodes_df <- data.frame(name = filtered_edges_nodes, stringsAsFactors = FALSE)
  l1 <- nchar("e3a77159938953ea5a7a397faa360439ba0a9eae249fe158380d48ac8ad5e283")
  filtered_edges_nodes_df$type <- ifelse(nchar(filtered_edges_nodes_df$name) < l1, 0, 1)
  G = graph_from_data_frame(d=filtered_edges, v = filtered_edges_nodes_df, directed=T)
  return(G)
} # <---- foo(i, j, edge) HERE
foo(1,11390)
G <- foo(1,32426,edges)

# Density: The proportion of present edges from all possible ties
edge_density(G, loops=F) 
ecount(G)/(vcount(G)*(vcount(G)-1)) #for a directed network
# same value!

# Reciprocity: The proportion of reciprocated ties (for a directed network)
reciprocity(G)
dyad_census(G) # Mutual, asymmetric, and null node pairs
2*dyad_census(G)$mut/ecount(G) # Calculating reciprocity

# Transitivity  (or Clustering Coefficient)
# global: ratio of triangles (direction disregarded) to connected triples
# local: ratio of triangles to connected triples each vertex is part of
transitivity(G, type="global")  # G is treated as an undirected network
transitivity(as.undirected(G, mode="collapse")) # same as above
transitivity(G, type="local")
# CHECK WHAT TRANSITIVITY = 0 IMPLIES

# Triad types:
# 003  A, B, C, empty triad.
# 012  A->B, C 
# 102  A<->B, C  
# 021D A<-B->C 
# 021U A->B<-C 
# 021C A->B->C
# 111D A<->B<-C
# 111U A<->B->C
# 030T A->B<-C, A->C
# 030C A<-B<-C, A->C.
# 201  A<->B<->C.
# 120D A<-B->C, A<->C.
# 120U A->B<-C, A<->C.
# 120C A->B->C, A<->C.
# 210  A->B<->C, A<->C.
# 300  A<->B<->C, A<->C, completely connected.
triad_census(G) # for directed networks

# Diameter (longest geodesic distance)
#Note that edge weights are used by default, unless set to NA.
diameter(G, directed=F, weights=NA)
diameter(G, directed=T, weights=NA)
diam <- get_diameter(G, directed=T) # Longest transaction chain
diam

# Node degrees: 'degree' -has a mode of 'in' for in-degree, 'out' for out-degree,
# and 'all' or 'total' for total degree.
indeg <- degree(G, mode="in")
outdeg <- degree(G, mode="out")
deg <- degree(G, mode="all")
deg

hist(deg, breaks=1:50, main="Histogram of node degree") # histogram of node degree

# Degree distribution
deg.dist <- degree_distribution(G, cumulative=T, mode="all")
plot( x=0:max(deg), y=1-deg.dist, pch=19, cex=1.2, col="orange", 
      xlab="Degree", ylab="Cumulative Frequency") # this one desn't work with our graphs...
centr_degree(G, mode="in", normalized=T)
closeness(G, mode="all", weights=NA)
centr_clo(G, mode="all", normalized=T)
eigen_centrality(G, directed=T, weights=NA)
betweenness(G, directed=T, weights=NA)
edge_betweenness(G, directed=T, weights=NA)
centr_betw(G, directed=T, normalized=T)

hs <- hub_score(G, weights=NA)$vector
as <- authority_score(G, weights=NA)$vector

par(mfrow=c(1,2))
#plot(net, vertex.size=hs*50, main="Hubs")
#plot(net, vertex.size=as*30, main="Authorities")

mean_distance(G, directed=T)

# Length of all the shortest paths in the graph
distances(G)

l <- layout_with_fr(G) # This is a nice layout
G %>% ggraph(layout = l) +
  geom_edge_fan(aes(color=type, edge_width=amount), width = .5) +
  geom_node_point(aes(color=type), size = deg*3) +
  scale_color_viridis()



subgraph <- induced_subgraph(G, 10455:11000)
l <- layout_with_fr(subgraph) # This is a nice layout
subgraph_deg <- degree(subgraph, mode="all")
subgraph %>% ggraph(layout = l) +
  geom_edge_fan(aes(color=type, edge_width=amount), width = .5) +
  geom_node_point(aes(color=type), size = subgraph_deg*.22) +
  scale_color_viridis()
subgraph %>% ggraph(layout = l) +
  geom_edge_fan(aes(color=type, edge_width=amount), width = .5) +
  geom_node_point(aes(color=type), size = 1.7) +
  scale_color_viridis()
news.path <- shortest_paths(G, 
                            from = V(G)[name=="f6969e82920fc6a15b623f08ca61f1552ab05e11f510d1b26b354b2dc9d8a9f1"], 
                             to  = V(G)[name=="048ae38ab4c78b7609da8cb9c352f9d38fe43347ed6f799d655499d0694c3fa3"],
                             output = "both") # both path nodes and edges
# Generate edge color variable to plot the path:
ecol <- rep("gray80", ecount(G))
ecol[unlist(news.path$epath)] <- "orange"
# Generate edge width variable to plot the path:
ew <- rep(2, ecount(G))
ew[unlist(news.path$epath)] <- 4
# Generate node color variable to plot the path:
vcol <- rep("gray40", vcount(G))
vcol[unlist(news.path$vpath)] <- "gold"
plot(G, vertex.color=vcol, edge.color=ecol, 
     edge.width=ew, edge.arrow.mode=0)


G <- foo(1, 32426, edges)
G
plot(degree.distribution(G)) # PRETTIER
G.bp <- bipartite_projection(G)
l <- layout_randomly(G)
l <- layout_on_sphere(G)
l <- layout_with_fr(G) # This is a nice layout
l <- layout_with_kk(G)
G %>% ggraph(layout = l) +
  geom_edge_fan(aes(color=type, edge_width=amount), width = .5) +
  geom_node_point(aes(color=type), size = 3) +
  scale_color_viridis()
sV(G)$name
E(G)

foo1 <- function(i, j) {
  edges = read.csv("blocks/tseries/3_blocks_test.csv")
  filtered_edges = edges[i:j, ]
  unique_senders = unique(filtered_edges$sender)
  unique_receivers <- unique(filtered_edges$receiver)
  unique_values <- unique(c(unique_senders, unique_receivers))
  selected_edges <- edges[edges$sender %in% unique_values | edges$receiver %in% unique_values, ]
  head(selected_edges)
  return(selected_edges)
}
selected_edges <- foo1(1,13000)
selected_edges_nodes <- unique(c(selected_edges$sender, selected_edges$receiver))
selected_edges_nodes_df <- data.frame(name = selected_edges_nodes, stringsAsFactors = FALSE)
l1 <- nchar("e3a77159938953ea5a7a397faa360439ba0a9eae249fe158380d48ac8ad5e283")

selected_edges_nodes_df$type <- ifelse(nchar(selected_edges_nodes_df$name) < l1, 0, 1)
G = graph_from_data_frame(d=selected_edges, v = selected_edges_nodes_df, directed=T)
l <- layout_with_fr(G)
plot <- G %>% 
  ggraph(layout = l) +
  geom_edge_fan(aes(color = type, edge_width = amount), width = .5) +
  geom_node_point(aes(color = type), size = 3) +
  scale_color_viridis()
print(plot)
i <- 0
for (k in seq(from = 1, to = 32427, by = 525)) {
  selected_edges <- foo1(k, (k + 525))
  selected_edges_nodes <- unique(c(selected_edges$sender, selected_edges$receiver))
  selected_edges_nodes_df <- data.frame(name = selected_edges_nodes, stringsAsFactors = FALSE)
  l1 <- nchar("e3a77159938953ea5a7a397faa360439ba0a9eae249fe158380d48ac8ad5e283")
  
  selected_edges_nodes_df$type <- ifelse(nchar(selected_edges_nodes_df$name) < l1, 0, 1)
  G = graph_from_data_frame(d=selected_edges, v = selected_edges_nodes_df, directed=T)
  l <- layout_with_fr(G)
  plot <- G %>% 
    ggraph(layout = l) +
    geom_edge_fan(aes(color = type, edge_width = amount), width = .5) +
    geom_node_point(aes(color = type), size = 3) +
    scale_color_viridis()
  output_folder <- "blocks/tseries/plots/"
  plot_filename <- paste0(output_folder, "graph_plot_", i, ".png")
  png(filename = plot_filename, width = 1024, height = 768, res = 100)
  print(plot)
  dev.off()
  
  i = i + 1
  #Sys.sleep(3)
}





as_data_frame(G, what='edges')
for (k in seq(from = 1, to = 32427, by = 525)) {
  G <- foo(k, (525 + k))
  l <- layout_with_fr(G)
  plot <- G %>% 
    ggraph(layout = l) +
    geom_edge_fan(aes(color = type, edge_width = amount), width = .5) +
    geom_node_point(aes(color = type), size = 3) +
    scale_color_viridis()
  print(plot)
  Sys.sleep(3)
}
G %>% ggraph(layout = "sugiyama") +
  geom_edge_fan(aes(color=type, edge_width=amount), width = .5) +
  geom_node_point(aes(color=type), size = 3) +
  scale_color_viridis()
t <- mean_distance(G)
t

# node list
NL = read.csv("blocks/mod_txnodelist_0000000000000000ebed3e2b0cf036d577ffec8a7c4015d64499e8a791b82c0b.csv")
NL

head(filtered_edges)
head(filtered_edges_nodes)

G = graph_from_data_frame(d=filtered_edges, v = filtered_edges_nodes) %>% as_tbl_graph()
G %>%
  ggraph(layout = "circle")  +
  geom_edge_fan(aes(color=amount), width = .5) +
  geom_node_point(size = 3) +
  scale_color_viridis()
