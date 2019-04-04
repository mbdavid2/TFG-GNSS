# data <- read.delim(file='ra360_dec-030', sep = "")
# cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))

# data <- read.delim(file='ra240_dec\ 030', sep = "")
# cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))

files <- list.files(path="results/", pattern="*", full.names=TRUE, recursive=FALSE)
for (i in files) {
    data <- read.delim(file=i, sep = "")
    cat(i, " ||   Correlation:", cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman")), "\n")
}


# > data <- read.delim(file='ra360_dec-030', sep = "")
# > cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))
# [1] -0.4337652
# > 
# > data <- read.delim(file='ra240_dec\ 030', sep = "")
# > cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))
# [1] 0.5362007

