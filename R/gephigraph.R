getwd()
library(tidyverse)
setwd("/home/rick/Ri/SecondYear/2ndSemester/DMAU2/project/blocks/tseries/APIrequests/0bigsequence/")

library(igraph)
library(ggplot2)
library(ggraph)
library(tidygraph)



slice <- function(i, j, edges) {
  filtered_edges = edges[i:j, ]
  filtered_edges_nodes <- unique(c(filtered_edges$sender, filtered_edges$receiver))
  filtered_edges_nodes_df <- data.frame(name = filtered_edges_nodes, stringsAsFactors = FALSE)
  l1 <- nchar("e3a77159938953ea5a7a397faa360439ba0a9eae249fe158380d48ac8ad5e283")
  filtered_edges_nodes_df$type <- ifelse(nchar(filtered_edges_nodes_df$name) < l1, 0, 1)
  G = graph_from_data_frame(d=filtered_edges, v = filtered_edges_nodes_df, directed=T)
  return(G)
}
display <- function(G, layout, edge_width, node_size) {
  G %>% ggraph(layout = layout) +
    geom_edge_fan(aes(color=type), width = edge_width) +
    geom_node_point(aes(color=type), size = node_size) +
    scale_color_viridis()
}
network <- function(edges, nodes) {
  len <- nchar("e3a77159938953ea5a7a397faa360439ba0a9eae249fe158380d48ac8ad5e283")
  nodes_df <- data.frame(name = nodes, stringsAsFactors = FALSE)
  nodes_df$type <- ifelse(nchar(nodes_df$name) < len, 0, 1)
  G <- graph_from_data_frame(d=edges, v = nodes_df, directed=T)
  return(G)
}

edges <- read.csv("500504.txedgelist_0000000000000000007a1349d6110e52dfb36624501cfb477c51f250d58e1565.csv")
edges <- rbind(edges, read.csv("500505.txedgelist_000000000000000000449df59a80b7b3f9c5a88274bf2d7e395dd0efc0eabc99.csv"))
edges <- rbind(edges, read.csv("500506.txedgelist_0000000000000000003815c407ba067e0edc5137c53b3665916f0d90067b9c57.csv"))
edges <- rbind(edges, read.csv("500507.txedgelist_00000000000000000095301884e2d314215e9b5c0a7cc2b19916c3e200877940.csv"))
edges <- rbind(edges, read.csv("500508.txedgelist_0000000000000000003b5704ba6244299f9b71ac4bba4cf7cbc1fd40c27becd2.csv"))
edges <- rbind(edges, read.csv("500509.txedgelist_0000000000000000006b64afc602c9495fd618ec841c0ee8255ba83d1f1ce510.csv"))
edges <- rbind(edges, read.csv("500510.txedgelist_00000000000000000084797b63dfa0adf2e4f010cda0fa03ae7aeb8a44f8e08a.csv"))
edges <- rbind(edges, read.csv("500511.txedgelist_000000000000000000048b10d7130a7dec5f2f7b743efb5aca5a1919829461c8.csv"))
edges <- rbind(edges, read.csv("500512.txedgelist_000000000000000000908db070869b9b8843fc12051cc3dd2886093831fd2415.csv"))
edges <- rbind(edges, read.csv("500513.txedgelist_00000000000000000061a4afab60bc30cf563ea724cdca4901eb5dfce318d820.csv"))
edges <- rbind(edges, read.csv("500514.txedgelist_0000000000000000002af9eb888cea98051bf19c0592876ab5801f949282ddd8.csv"))
edges <- rbind(edges, read.csv("500515.txedgelist_0000000000000000008abb306f6c51b4dfd3aed47a3e46099a92dc164d4d6059.csv"))
edges <- rbind(edges, read.csv("500516.txedgelist_000000000000000000123799cdf5257473d7c65a89c57a4c0ac17ef938a2b198.csv"))
edges <- rbind(edges, read.csv("500517.txedgelist_0000000000000000006ec7747ec98c2f58cf453ade77ae6ba84fa4b8522d2d87.csv"))
edges <- rbind(edges, read.csv("500518.txedgelist_0000000000000000001eee17b524e2ca1c01ec8f726f4dcf0456208bcf28c144.csv"))
edges <- rbind(edges, read.csv("500519.txedgelist_0000000000000000008050347698b0aeb99b012413a985d274da04f2bbf4edcb.csv"))
edges <- rbind(edges, read.csv("500520.txedgelist_0000000000000000000b6634cebe97a2b67863730f9612d5a9ec8f9273d9fa8d.csv"))
edges <- rbind(edges, read.csv("500521.txedgelist_0000000000000000000bfa75b9bc2ecd104386e7b6877a5fedd8a791469f3a99.csv"))
edges <- rbind(edges, read.csv("500522.txedgelist_000000000000000000773a8e67ecea68600babd7a0cf70d4c77d6167028aa8dc.csv"))
edges <- rbind(edges, read.csv("500523.txedgelist_000000000000000000498d003aa29ef0b4699ca719ed2278a7c47f08e1178726.csv"))
edges <- rbind(edges, read.csv("500524.txedgelist_00000000000000000062b773bf8935361a104b807782dd8ad73bf21d937cf33a.csv"))
edges <- rbind(edges, read.csv("500525.txedgelist_000000000000000000314550b5fd5105a92171e2123c706056f39aadb99d2947.csv"))
edges <- rbind(edges, read.csv("500526.txedgelist_0000000000000000008e2032ef0876509b0c0a26bfadd48edbdebf727fe5323a.csv"))
edges <- rbind(edges, read.csv("500527.txedgelist_00000000000000000095be6e09d627be44b815c7f03c804fcfbf4ae400e5ff53.csv"))
edges <- rbind(edges, read.csv("500528.txedgelist_0000000000000000008bf8cc09f7ff6cc2204f4bba8731a6e3cb703efb476a93.csv"))
edges <- rbind(edges, read.csv("500529.txedgelist_000000000000000000406166f3ff9a6f84f26495aa730222f25cdb4d16c695b4.csv"))
edges <- rbind(edges, read.csv("500530.txedgelist_00000000000000000079bb4131e4e6e222f7daba47a14d182676fac69ceedc6b.csv"))

edges <- rbind(edges, read.csv("500531.txedgelist_00000000000000000009e08a2e1c6b340959c378615cf171c6a642ab591909d7.csv"))
edges <- rbind(edges, read.csv("500532.txedgelist_0000000000000000005f98fa34e85bc36d50cf98c5c3bf743f530dcd64513b6a.csv"))
edges <- rbind(edges, read.csv("500533.txedgelist_0000000000000000006dd51cf7c4d86852c19495a99f42788baf1c4ebadc7df5.csv"))
edges <- rbind(edges, read.csv("500534.txedgelist_0000000000000000006d9de32b354108dafca202f3a4474817db28c3f444ba07.csv"))
edges <- rbind(edges, read.csv("500535.txedgelist_0000000000000000001890602b21a79943601d127fd11b58fb4613d983deef01.csv"))
edges <- rbind(edges, read.csv("500536.txedgelist_000000000000000000233a540109a232a65aa3fff604c1385a33cca50f7708ad.csv"))
edges <- rbind(edges, read.csv("500537.txedgelist_0000000000000000008e5cff23415495727d5c15b90ec8c26e1cf6e001006484.csv"))
edges <- rbind(edges, read.csv("500538.txedgelist_00000000000000000077a424f04a7f114dc34af2d95466d597f6b0a33360d8fa.csv"))
edges <- rbind(edges, read.csv("500539.txedgelist_000000000000000000506defaf3aafe7c724faa1628f604f0d801266eb157c43.csv"))
edges <- rbind(edges, read.csv("500540.txedgelist_0000000000000000007ac8138db3a3ac34eea0eb6d07055ddc2028aaf90f6ba9.csv"))
edges <- rbind(edges, read.csv("500541.txedgelist_00000000000000000000ca94283c7cf0566133a04435454d678d9512fc26000b.csv"))
edges <- rbind(edges, read.csv("500542.txedgelist_00000000000000000083ca87f5e5cfb2d5b33402fe57ef1081eee0ad050095e6.csv"))
edges <- rbind(edges, read.csv("500543.txedgelist_0000000000000000007c1d3356fed582123f18d077f09097a5a0d7310c9f8606.csv"))
edges <- rbind(edges, read.csv("500544.txedgelist_0000000000000000001da9dae58f9066d3506cbf9472a8816b5108021530869f.csv"))
edges <- rbind(edges, read.csv("500545.txedgelist_0000000000000000002ce797f38c4727235dea9a0569285f5a23954f473d98d3.csv"))
edges <- rbind(edges, read.csv("500546.txedgelist_000000000000000000131d1df9ba77969ffef2f003a6d42d16765541e808d1df.csv"))
edges <- rbind(edges, read.csv("500547.txedgelist_0000000000000000005d4cbd52f7da656f012e37fc6229fde5e5821f5de0cece.csv"))
edges <- rbind(edges, read.csv("500548.txedgelist_0000000000000000006a22eff01aa49398422045a299139cdb5d2a5cc8c9f106.csv"))
edges <- rbind(edges, read.csv("500549.txedgelist_00000000000000000081c96870b33d78b2a7801eb980d73d44c2ee67febd6092.csv"))
edges <- rbind(edges, read.csv("500550.txedgelist_000000000000000000929391fc5ba1b0a7d088976c88509fefa0bdc356c8bf8d.csv"))
edges <- rbind(edges, read.csv("500551.txedgelist_000000000000000000752467872706d1e8cdbc213c575ec76e5b622d733c545b.csv"))
edges <- rbind(edges, read.csv("500552.txedgelist_0000000000000000002415e746e7380f2cd051edea70423408c63bd7f6769b4a.csv"))
edges <- rbind(edges, read.csv("500553.txedgelist_0000000000000000000580df1b70dbddac8402b2494da90d5edc6ab2ee7f467d.csv"))
edges <- rbind(edges, read.csv("500554.txedgelist_00000000000000000048a7165f2559af47027ae0bd6cfb2c71a2689fb8709493.csv"))
edges <- rbind(edges, read.csv("500555.txedgelist_0000000000000000005454aae55258064e4f29bbaad473400af67c6785521d8b.csv"))
edges <- rbind(edges, read.csv("500556.txedgelist_0000000000000000002ef3d6374bddfcd217522743aa7d212c5e215d57ec3431.csv"))
edges <- rbind(edges, read.csv("500557.txedgelist_000000000000000000510b554edcf18414f12142327a7f034564b8607e9b8c15.csv"))
edges <- rbind(edges, read.csv("500558.txedgelist_0000000000000000004da42d98c5411184164dc45b0fac970f86e7d3017f4886.csv"))
edges <- rbind(edges, read.csv("500559.txedgelist_00000000000000000004d781a5d3f217b5f316ee559761ed950d058e527fe4b8.csv"))
edges <- rbind(edges, read.csv("500560.txedgelist_0000000000000000003fb0c62d19840b06847cd8712afafb460d5ae74a45fee2.csv"))
edges <- rbind(edges, read.csv("500561.txedgelist_000000000000000000928ec15e3a558e6c5153fb1113e691c81ba0b89b85387f.csv"))
edges <- rbind(edges, read.csv("500562.txedgelist_00000000000000000027be168e55ad4f495ec00990ee449832ae6858c055d92b.csv"))
edges <- rbind(edges, read.csv("500563.txedgelist_00000000000000000027cbaa0b7b334bc9b74557775c911ef8da9e0e73910fae.csv"))
edges <- rbind(edges, read.csv("500564.txedgelist_0000000000000000009268f734340be52f5e2226d847b44a8b126e799ecaeec5.csv"))
edges <- rbind(edges, read.csv("500565.txedgelist_0000000000000000001f0403999aed6e58238883915781d3280eb048d90cd4e6.csv"))
edges <- rbind(edges, read.csv("500566.txedgelist_00000000000000000061b8d5a2cdeef696d234017e5e5374e0d984b68e01eb8c.csv"))
edges <- rbind(edges, read.csv("500567.txedgelist_00000000000000000047969c150c3ede84837cb1eb86c63839bf7d6e00b6934d.csv"))
edges <- rbind(edges, read.csv("500568.txedgelist_00000000000000000035a691c63d973f6dee879133b76ddfb01554928b86fb3f.csv"))
edges <- rbind(edges, read.csv("500569.txedgelist_0000000000000000003a3b29c9642efebc5e78612b26ab8a632809a199addffe.csv"))
edges <- rbind(edges, read.csv("500570.txedgelist_000000000000000000202aaa1207fb812261d259ed3015130fd579f16c0ad7a9.csv"))
edges <- rbind(edges, read.csv("500571.txedgelist_0000000000000000005d34cbb88f4b349c8c8a0f22dd0a4c1bdafe914e5e85cb.csv"))
edges <- rbind(edges, read.csv("500572.txedgelist_00000000000000000084207048ca1e4491c98811508350c63f637deedd2031c3.csv"))
edges <- rbind(edges, read.csv("500573.txedgelist_0000000000000000007945d5fb994ee4534c4d572aa1be4b1340e94c95d6cf4a.csv"))
edges <- rbind(edges, read.csv("500574.txedgelist_00000000000000000006b0a515695fd00ca56393e937477eef8c2531f61d0852.csv"))
edges <- rbind(edges, read.csv("500575.txedgelist_0000000000000000008c300bd55ab3908a50d7d6761187d57fd0b5680a658e4a.csv"))
edges <- rbind(edges, read.csv("500576.txedgelist_00000000000000000050fe1b95537fa2971d42216b3613308cbec41b38b9a259.csv"))
edges <- rbind(edges, read.csv("500577.txedgelist_0000000000000000003d099fe59659b3f30f0361d1366a3bfba3cabcd40321ab.csv"))
edges <- rbind(edges, read.csv("500578.txedgelist_0000000000000000001cfe50d91c20896ec526d21ff074d164a2588ea0188aca.csv"))
edges <- rbind(edges, read.csv("500579.txedgelist_000000000000000000748b844d0f79af9fa3c4563c77467f8abdb4645e781153.csv"))
edges <- rbind(edges, read.csv("500580.txedgelist_00000000000000000034e75f5cfba77736d21fd5acbda059b28555e2f81aba1a.csv"))
edges <- rbind(edges, read.csv("500581.txedgelist_000000000000000000826c5f32edca4b208c5852b68bcac20e9acbbea6d102c3.csv"))
edges <- rbind(edges, read.csv("500582.txedgelist_00000000000000000066d8227fd66eeb807699d6b868a4cec247437c2d5c9d95.csv"))
edges <- rbind(edges, read.csv("500583.txedgelist_00000000000000000088560e73b92355047ba71216f7b7a23eb69190fa96ca27.csv"))
edges <- rbind(edges, read.csv("500584.txedgelist_000000000000000000820c268ade90b2db2abace3c3a60e181bcccb066ad073a.csv"))
edges <- rbind(edges, read.csv("500585.txedgelist_00000000000000000029249dc30b9043dc2fced918bd8e7dcf3b8560d2fa55fa.csv"))
edges <- rbind(edges, read.csv("500586.txedgelist_0000000000000000004f61fa9d4e52f22abfea433a118319b20ad03dee035077.csv"))
edges <- rbind(edges, read.csv("500587.txedgelist_00000000000000000066845d0de20a2f015753ae8065ba2a2d73dd7fd7769b7e.csv"))
edges <- rbind(edges, read.csv("500588.txedgelist_00000000000000000087c46ef0b10022eb72721af23293e3c444ae9d25b056d2.csv"))
edges <- rbind(edges, read.csv("500589.txedgelist_0000000000000000006652a6b0280338069a4741b45e733899f0a964a663dce9.csv"))
edges <- rbind(edges, read.csv("500590.txedgelist_00000000000000000076b1a911031043cfa4ad29a8db404b6e0143f676945f55.csv"))
edges <- rbind(edges, read.csv("500591.txedgelist_00000000000000000011cf679184b06c349f25d236fd7c1c7a75dd4bb6f05574.csv"))
edges <- rbind(edges, read.csv("500592.txedgelist_00000000000000000039f1c6a65c58bff225c4875744a6ca2e0072781b67685e.csv"))
edges <- rbind(edges, read.csv("500593.txedgelist_00000000000000000002784ca68b0876b1e5342cc2b923f69a26e46e52bb4853.csv"))
edges <- rbind(edges, read.csv("500594.txedgelist_0000000000000000008a39aa8d086f580d763eb5bf1a23e3f5e5fa3468fc98ec.csv"))
edges <- rbind(edges, read.csv("500595.txedgelist_0000000000000000003fd81df8d3c54fbdcdcc7d0ad4f785c2ccf889f2e151cf.csv"))
edges <- rbind(edges, read.csv("500596.txedgelist_00000000000000000095709e6436548607faaa8cb16589a80a5d4b0492c03a7c.csv"))
edges <- rbind(edges, read.csv("500597.txedgelist_0000000000000000008d1d80475082d4b8c4cf2be6c29a5164ee984000542ecb.csv"))
edges <- rbind(edges, read.csv("500598.txedgelist_000000000000000000042db96df6cfcb65e666417f9e2f233eda52f15e951966.csv"))
edges <- rbind(edges, read.csv("500599.txedgelist_0000000000000000008b5452c9f6a1fca7b8c6de32838fd60deaba44d4ca0b18.csv"))
edges1 <- read.csv("500505.txedgelist_000000000000000000449df59a80b7b3f9c5a88274bf2d7e395dd0efc0eabc99.csv")
#edges <- edges[1:1000,]
head(edges)
# Create a set the unique nodes involved in the edges stored in the edges
nodes <- unique(c(edges$sender, edges$receiver))
head(nodes)

# Slice the (huge) edges object and create filtered objects containing
# all unique elements in the slice that appear in the full object
edges_slice <- edges1[0:50,]
nodes_slice <- unique(c(edges_slice$sender, edges_slice$receiver))
edges_filtered <- edges[edges$sender %in% nodes_slice | edges$receiver %in% nodes_slice, ]
nodes_filtered <- unique(c(edges_filtered$sender, edges_filtered$receiver))
G <- network(edges_filtered, nodes_filtered)
G <- network(edges_slice, nodes_slice)

main()
main <- function() {
  G <- network(edges, nodes)
  #G <- network(edges_filtered, nodes_filtered)
  l <- layout_with_fr(G) # network layout
  #l <- layout_with_graphopt(G)
  
  #display(G, l, .5, 1.5)
  display(G, l, .5, 3)
}
main()


# Network descriptives
G <- network(edges, nodes)
l <- layout_with_fr(G) # network layout
edge_density(G, loops=F) # edge density
reciprocity(G)
dyad_census(G) # Mutual, asymmetric, and null node pairs
2*dyad_census(G)$mut/ecount(G) # Calculating reciprocity
transitivity(G, type="global")  # G is treated as an undirected network
diameter(G, directed=F, weights=NA) # Longest geodesic distance
diam <- get_diameter(G, directed=T)
diam
plot(degree_distribution(G))
giant.component <- function(graph) {
  cl <- components(graph)
  induced_subgraph(graph, which(cl$membership == which.max(cl$csize)))}
# Get the giant component
G.giant_component <- giant.component(G)
summary(G.giant_component)
edge_density(G.giant_component)           
transitivity(G.giant_component, type = "global")
diameter(G.giant_component, directed = FALSE, weights = NA)

# Get the giant component, alternative method
components <- igraph::clusters(G, mode="weak")
biggest_cluster_id <- which.max(components$csize)

# ids
vert_ids <- V(G)[components$membership == biggest_cluster_id]

# subgraph
G.giant_component <- igraph::induced_subgraph(G, vert_ids)

max(degree(G.giant_component)
