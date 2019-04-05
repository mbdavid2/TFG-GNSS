# data <- read.delim(file='ra360_dec-030', sep = "")
# cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))

# data <- read.delim(file='ra240_dec\ 030', sep = "")
# cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))

files <- list.files(path="results/", pattern="*", full.names=TRUE, recursive=FALSE)
maxname = "empty"
max = -23;
for (i in files) {
    data <- read.delim(file=i, sep = "")
    correlation = cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))
    if (correlation > max) {
    	max = correlation
    	maxname = i
    }
    # cat(i, " ||   Correlation:", correlation, "\n")
}
cat("[R: RESULTS]", "\n")
cat("   -> Largest correlation coefficient:", max, "\n")
radec = substr(maxname, 10, nchar(maxname))
cat("   -> Estimated Sun's location: ", radec, "\n")


# > data <- read.delim(file='ra360_dec-030', sep = "")
# > cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))
# [1] -0.4337652
# > 
# > data <- read.delim(file='ra240_dec\ 030', sep = "")
# > cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))
# [1] 0.5362007

