#' Make a movie of the diffusion of probability, P1, from a starting node.
#'
#' Recursively diffuse probability from a starting node based on the connectivity of the background knowledge graph, representing the
#' likelihood that a variable will be most influenced by a perturbation in the starting node.
#' @param adj_mat - The adjacency matrix that encodes the edge weights for the network, G. 
#' @param G - A list of probabilities, with names of the list being the node names in the background knowledge graph.
#' @param output_dir -  The local directory at which you want still PNG images to be saved.
#' @param p1 - The probability being dispersed from the starting node, startNode, which is preferentially distributed 
#'             between network nodes by the probability diffusion algorithm based solely on network connectivity.
#' @param startNode - The first variable drawn in the node ranking, from which p1 gets dispersed.
#' @param visitedNodes - A character vector of node names, storing the history of previous draws in the node ranking.
#' @param imgNum - The image number for this snapshot. If images are being generated in a sequence, this serves as
#'                 an iterator for file naming.
#' @param recursion_level - The current depth in the call stack caused by a recursive algorithm.
#' @return imgNum - The updated image count for the next image in the image-generated movie sequence.
#' @export graph.takeDiffusionSnapShot
#' @import igraph
#' @importFrom grDevices dev.off png
#' @importFrom graphics legend title
#' @examples
#' # 7 node example graph illustrating diffusion of probability based on network connectivity
#' # from Thistlethwaite et al., 2020.
#' adj_mat = rbind(c(0,2,1,0,0,0,0), # A
#'                 c(2,0,1,0,0,0,0), # B
#'                 c(1,0,0,1,0,0,0), # C
#'                 c(0,0,1,0,2,0,0), # D
#'                 c(0,0,0,2,0,2,1), # E
#'                 c(0,0,0,1,2,0,1), # F
#'                 c(0,0,0,0,1,1,0)  # G
#'                 )
#' rownames(adj_mat) = c("A", "B", "C", "D", "E", "F", "G")
#' colnames(adj_mat) = c("A", "B", "C", "D", "E", "F", "G")
#' ig = graph.adjacency(as.matrix(adj_mat), mode="undirected", weighted=TRUE)
#' G=vector(mode="list", length=7)
#' G[seq_len(length(G))] = 0
#' names(G) = c("A", "B", "C", "D", "E", "F", "G")
#' startNode = "A"
#' visitedNodes = startNode
#' coords = layout.fruchterman.reingold(ig)
#' V(ig)$x = coords[,1]
#' V(ig)$y = coords[,2]
#' imgNum = graph.takeDiffusionSnapShot(adj_mat, G, output_dir=getwd(), p1=1.0, startNode, visitedNodes, imgNum=1, recursion_level=1)
graph.takeDiffusionSnapShot = function(adj_mat, G, output_dir, p1, startNode, visitedNodes, imgNum=1, recursion_level=1) {
  ig = graph.adjacency(adj_mat, mode="undirected", weighted = TRUE)
  coords = layout.fruchterman.reingold(ig)
  
  V(ig)$color = rep("blue", length(G))
  V(ig)$color[which(V(ig)$name %in% visitedNodes)] = "red"
  V(ig)$label = sprintf("%s:%.2f", V(ig)$name, G)
  png(sprintf("%s/diffusionP1Movie%d.png", output_dir, .GlobalEnv$imgNum), 500, 500)
  plot.igraph(ig, layout=cbind(V(ig)$x, V(ig)$y), vertex.color=V(ig)$color,
              vertex.label=V(ig)$label, vertex.label.dist = 3, edge.width=5*abs(E(ig)$weight),
              mark.col="black", mark.border = "black", mark.groups = startNode)
  title(sprintf("Diffuse %.2f from %s at recursion level %d.", p1, startNode, recursion_level), cex.main=1)
  legend("bottomright", legend=c("Visited", "Unvisited"), fill=c("red", "blue"))
  dev.off()
  
  return(imgNum+1)
}


