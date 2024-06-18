library(igraph)
library(tidygraph)
library(tidyverse )
library(ggraph)
set_graph_style()

G <- erdos.renyi.game(50, .4)
G <- as_tbl_graph(G)
G

create_notable("zachary") %>%
  activate(nodes) %>% 
  mutate(degree = centrality_degree())

# Because the networks are just stored as data frames, that means that we can
# export them as tibbles and then do things like use ggplot to graph attributes 
# of a network. This code below creates an edge attribute called bw which 
# is a measure of edge betweenness, and then makes a histogram of the
# distribution of bw.
create_notable('zachary') %>%
  activate(edges) %>%
  mutate(bw = centrality_edge_betweenness()) %>%
  as_tibble() %>%
  ggplot() +
  geom_histogram(aes(x=bw)) +
  theme_minimal()

# Do the same thing, but on the centrality degree (remember to also activate
# the nodes)
create_notable('zachary') %>%
  activate(edges) %>%
  activate(nodes) %>%
  mutate(degree = centrality_degree()) %>%
  as_tibble() %>%
  ggplot() +
  geom_histogram(aes(x=degree)) +
  theme_minimal()


create_notable('zachary') %>%
  activate(nodes) %>% 
  mutate(group = as.factor(group_infomap())) %>% # Creates a `group` variable based on the infomap algorithm
  ggraph(layout = 'stress') +
  geom_edge_fan(width = .5, color = 'lightblue') + 
  geom_node_point(aes(color = group)) + 
  coord_fixed() + 
  theme_graph()



nodes = read_csv('https://raw.githubusercontent.com/jdfoote/Communication-and-Social-Networks/spring-2021/resources/school_graph_nodes.csv')
edges = read_csv('https://raw.githubusercontent.com/jdfoote/Communication-and-Social-Networks/spring-2021/resources/school_graph_edges.csv')

G = graph_from_data_frame(d=edges, v = nodes) %>% as_tbl_graph()
G

head(nodes)
head(edges)
G %>%
  ggraph(layout = 'stress') +
  geom_edge_fan(width = .5, color = 'gray') +
  geom_node_point(aes(color=alcohol_use), size = 3) +
  scale_color_viridis()

G %>%
  ggraph(layout = 'stress') +
  geom_edge_fan(aes(color=type),width = .5) +
  geom_node_point(aes(color=alcohol_use), size = 3) +
  scale_color_viridis()
