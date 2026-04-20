#!/usr/bin/env Rscript

library(WGCNA)
library(ggplot2)
options(stringsAsFactors = FALSE)
enableWGCNAThreads()

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
    stop("Usage: wgcna_analysis.r <normalized_counts.csv> <out_dir>")
}

counts_file <- args[1]
out_dir <- args[2]

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# 1. 数据清洗
datExpr0 = read.table(counts_file, header = TRUE, row.names = 1, check.names = FALSE)
# 移除可能的 gene_name 列 (如果存在)
if ("gene_name" %in% colnames(datExpr0)) {
    datExpr0 <- datExpr0[, !colnames(datExpr0) %in% "gene_name"]
}
datExpr = as.data.frame(t(datExpr0))

# 检查缺失值和离群样本
gsg = goodSamplesGenes(datExpr, verbose = 3)
if (!gsg$allOK) {
    datExpr = datExpr[gsg$goodSamples, gsg$goodGenes]
}

# 2. 选择软阈值 (Soft Thresholding)
powers = c(c(1:10), seq(from = 12, to=20, by=2))
sft = pickSoftThreshold(datExpr, powerVector = powers, verbose = 5)

# 保存软阈值图
png(file.path(out_dir, "soft_threshold_selection.png"), width=1000, height=800, res=150)
par(mfrow = c(1,2))
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
     xlab="Soft Threshold (power)", ylab="Scale Free Topology Model Fit,signed R^2",
     main="Scale independence")
plot(sft$fitIndices[,1], sft$fitIndices[,5],
     xlab="Soft Threshold (power)", ylab="Mean Connectivity", main="Mean connectivity")
dev.off()

# 3. 构建网络与模块识别
# 自动选择 power (如果没有明确指定，则根据 R^2 选择)
softPower = sft$powerEstimate
if (is.na(softPower)) softPower = 6 # 默认值

net = blockwiseModules(datExpr, power = softPower,
                       TOMType = "unsigned", minModuleSize = 30,
                       reassignThreshold = 0, mergeCutHeight = 0.25,
                       numericLabels = TRUE, pamRespectsDendro = FALSE,
                       saveTOMs = TRUE, saveTOMFileBase = file.path(out_dir, "TOM"),
                       verbose = 3)

# 4. 可视化模块聚类
mergedColors = labels2colors(net$colors)
png(file.path(out_dir, "module_clustering.png"), width=1200, height=800, res=150)
plotDendroAndColors(net$dendrograms[[1]], mergedColors[net$blockGenes[[1]]],
                    "Module colors", dendroLabels = FALSE, hang = 0.03,
                    addGuide = TRUE, guideHang = 0.05)
dev.off()

# 保存模块成员信息
gene_modules = data.frame(Gene = colnames(datExpr), Module = mergedColors)
write.csv(gene_modules, file.path(out_dir, "gene_module_membership.csv"), row.names = FALSE)

print("WGCNA analysis completed.")
