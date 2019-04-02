data <- read.delim(file='ra360_dec-030', sep = "")
cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))

data <- read.delim(file='ra240_dec\ 030', sep = "")
cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))



# > data <- read.delim(file='ra360_dec-030', sep = "")
# > cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))
# [1] -0.4337652
# > 
# > data <- read.delim(file='ra240_dec\ 030', sep = "")
# > cor(data$cosx, data$vtec, method = c("pearson", "kendall", "spearman"))
# [1] 0.5362007

