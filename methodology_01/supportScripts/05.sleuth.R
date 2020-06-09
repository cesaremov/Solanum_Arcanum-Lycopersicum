library(sleuth)
library(Biostrings)

setwd("~/LangebioWork/Zoltan_splicing/")
rm(list = ls())
gc()

# Paths
inPath = "kallisto/"
outPath = "sleuth/"
dir.create(outPath, showWarnings = FALSE)

# Pattern
patt = "abundance.h5"

# List h5 files
abFiles = list.files(path = inPath, pattern = patt, recursive = TRUE, full.names = TRUE)
names(abFiles) = basename(sub("abundance.h5", "", abFiles))

# Set pData file
s2c = read.table("Raw/phenoType.tsv", sep = "\t", header = TRUE, as.is = TRUE)
s2c = dplyr::mutate(s2c, path = abFiles)

# Prep sleuth
so = sleuth_prep(s2c, ~ condition)

so = sleuth_fit(so)

so = sleuth_wt(so, "conditionWT")

sleuth_live(so)

break

# Get differential expression table
deTab = so$tests$wt$full$conditionWT

# Re-order given statistical
deTab$b = deTab$b * 1
deTab = deTab[order(deTab$b, decreasing = FALSE), ]
row.names(deTab) = deTab$target_id

# Write differential expression table
deTab = data.frame("ID" = row.names(deTab), deTab)
write.table(deTab, file = gzfile(paste(outPath, "deTab.tab.gz", sep = "")), sep = "\t", quote = FALSE, row.names = FALSE)

wilcox.test(deTab$b[deTab$miRtarget], deTab$b[!deTab$miRtarget])
print(sum(deTab$miRtarget))

plot(ecdf(deTab$b[!deTab$miRtarget]), col = "black", xlim = c(-3, 2), lwd = 3)
lines(ecdf(deTab$b[deTab$miRtarget]), col = "red", lwd = 3)
grid()

# barcodeplot(deTab$wald_stat, index = deTab$miRtarget)


