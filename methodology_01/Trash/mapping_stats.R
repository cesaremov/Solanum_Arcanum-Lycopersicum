#!/usr/bin/env Rscript

library(gplots)
library(ggplot2)
library(reshape2)

rm(list = ls())
gc()

# Paths
inPath <- system("find .. -name 'hisat2'", intern = TRUE)
outPath <- "mapping_stats"
dir.create(outPath, showWarnings = FALSE)

# Patterns
inPatt <- ".log$"

# Get Log.txt bowtieShortStack files to process
alnFiles <- list.files(pattern = inPatt, path = inPath, recursive = TRUE, full.names = TRUE)

libList <- list()
mumList <- list()
for (alnFile in alnFiles) {
  
  print(alnFile)
  
  # Scan alnFile
  logFile <- scan(file = alnFile, what = "character", sep = "\t")
  
  # Get map stats
  mapStats <- logFile[grepl("Total|Aligned", logFile)]
  mapStats <- gsub("\\s+\\(.+$", "", mapStats)
  mapStatsTab0 <- do.call(rbind, strsplit(mapStats, split = "\\:\\s+"))
  mapStatsTab <- data.frame(lib = gsub("^.+\\/+|\\.log", "", alnFile), type = mapStatsTab0[, 1], fragments = as.numeric(mapStatsTab0[, 2]))
  
# Get map/unmap table
  # mumTab <- mapStatsTab[!grepl("Total", mapStatsTab$type),]
  readsMap <- sum(c(mapStatsTab[grepl("tly.+1", mapStatsTab$type), "fragments"], 
                    mapStatsTab[!grepl("tly|0|Total", mapStatsTab$type), "fragments"]/2))
  total <- mapStatsTab[mapStatsTab$type == "Total pairs", "fragments"]
  mumTab <- data.frame(lib =  gsub("^.+\\/+|\\.log", "", alnFile), 
                       Map = readsMap, MapProp = readsMap/total*100,
                       UnMap = total-readsMap, UnMapProp = 100-readsMap/total*100)
  
# Set tables to lists
 libList[[alnFile]] <- mapStatsTab  
 mumList[[alnFile]] <- mumTab
}

# Get table
allTab <- do.call(rbind, libList)
mapUnmaptab <- do.call(rbind, mumList)

# Save table
write.table(x = mapUnmaptab, file = paste0(outPath, "/mapUnmsp.tab"), sep = "\t", quote = FALSE, col.names = TRUE, 
            row.names = FALSE)

# Melt table
mapUnmaptab <- melt(mapUnmaptab)
colnames(mapUnmaptab) <- c("lib", "type", "fragments")

# Save plot
pdf(paste(outPath, "/mapping_stats.pdf", sep = ""), width = 10, height = 6)

# Plot
g <- ggplot(allTab[!grepl("Total", allTab$type),], aes(x = lib, y = fragments, fill = type)) +
  geom_bar(stat = "identity", position=position_dodge()) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_fill_brewer(palette = "Dark2")
print(g)

gmum <- ggplot(mapUnmaptab[!grepl("Prop", mapUnmaptab$type),], aes(x = lib, y = fragments, fill = type)) +
  geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  scale_fill_manual(values = c("skyblue", "gray"))
print(gmum)

gmumProp <- ggplot(mapUnmaptab[grepl("Prop", mapUnmaptab$type),], aes(x = lib, y = fragments, fill = type)) +
  geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  scale_fill_manual(values = c("skyblue", "gray"))
print(gmumProp)

dev.off()

# Save matrix
write.table(x = allTab, file = paste(outPath, "/mapping_stats.tab", sep = ""),
            sep = "\t", quote = FALSE)


