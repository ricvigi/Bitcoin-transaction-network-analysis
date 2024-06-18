library("igraph")
library("poweRlaw")
library("ggplot2")

# Just loading my data

G <- graph_from_data_frame(edges_slice)

# List of degrees
G.degrees <- degree(G)

# Let's count the frequencies of each degree
G.degree.histogram <- as.data.frame(table(G.degrees))

# Need to convert the first column to numbers, otherwise
# the log-log thing will not work (that's fair...)
G.degree.histogram[,1] <- as.numeric(paste(G.degree.histogram[,1]))

# Now, plot it!
ggplot(G.degree.histogram, aes(x = G.degrees, y = Freq)) +
  geom_point() +
  scale_x_continuous("Degree",
                     breaks = c(1, 3, 10, 30, 100, 300),
                     trans = "log10") +
  scale_y_continuous("Frequency",
                     breaks = c(1, 3, 10, 30, 100, 300, 1000),
                     trans = "log10") +
  ggtitle("100 blocks log-log Degree Distribution") +
  theme_bw()




