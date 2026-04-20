#!/usr/bin/env Rscript

library(DESeq2)
library(ggplot2)
library(pheatmap)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    stop("Usage: deseq2_dea.r <counts_matrix> <samplesheet> <out_dir>")
}

counts_file <- args[1]
samplesheet_file <- args[2]
out_dir <- args[3]

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# 1. 加载数据
# 注意: 这里假设输入是基因层面的 Count 矩阵
counts <- read.table(counts_file, header = TRUE, row.names = 1, check.names = FALSE)
# 移除可能的 gene_name 列 (如果存在)
if ("gene_name" %in% colnames(counts)) {
    counts <- counts[, !colnames(counts) %in% "gene_name"]
}
samplesheet <- read.csv(samplesheet_file, check.names = FALSE, comment.char = "#")
# 清理 samplesheet，仅保留在 count 矩阵中存在的样本
samplesheet <- samplesheet[samplesheet$sample %in% colnames(counts), ]
rownames(samplesheet) <- samplesheet$sample
counts <- counts[, samplesheet$sample]

# 2. 差异表达分析 (DEA)
# 设定比较条件 (假设 condition 是主要变量)
samplesheet$condition <- as.factor(samplesheet$condition)
dds <- DESeqDataSetFromMatrix(countData = round(counts),
                              colData = samplesheet,
                              design = ~ condition)

# 过滤低表达基因
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

# 运行 DESeq2
dds <- DESeq(dds)

# 3. 提取结果
# 找到所有可能的 condition 组合
conditions <- levels(samplesheet$condition)
if (length(conditions) >= 2) {
    for (i in 1:(length(conditions)-1)) {
        for (j in (i+1):length(conditions)) {
            res_name <- paste0(conditions[i], "_vs_", conditions[j])
            res <- results(dds, contrast=c("condition", conditions[i], conditions[j]))
            
            # 保存结果
            write.csv(as.data.frame(res), file = file.path(out_dir, paste0(res_name, ".results.csv")))
            
            # 筛选差异基因 (DEG)
            deg <- res[which(res$padj < 0.05 & abs(res$log2FoldChange) > 1), ]
            write.csv(as.data.frame(deg), file = file.path(out_dir, paste0(res_name, ".deg_list.csv")))
            
            # 火山图
            res_df <- as.data.frame(res)
            res_df$change <- ifelse(res_df$padj < 0.05 & abs(res_df$log2FoldChange) > 1, 
                                   ifelse(res_df$log2FoldChange > 1, "UP", "DOWN"), "NOT")
            p_vol <- ggplot(res_df, aes(x=log2FoldChange, y=-log10(padj), color=change)) +
                geom_point(alpha=0.4, size=1.5) +
                scale_color_manual(values=c("UP"="#ff4b2b", "DOWN"="#1e90ff", "NOT"="#dcdcdc")) +
                theme_minimal() +
                labs(title=res_name, x="log2(Fold Change)", y="-log10(adj.P-value)")
            ggsave(file.path(out_dir, paste0(res_name, ".volcano.png")), p_vol, width=8, height=6)
        }
    }
}

# 4. 可视化 (PCA, Heatmap)
vsd <- vst(dds, blind=FALSE)
p_pca <- plotPCA(vsd, intgroup="condition") + theme_minimal() + labs(title="PCA Plot")
ggsave(file.path(out_dir, "pca_plot.png"), p_pca, width=8, height=6)

# 热图 (Top 50 差异最显著基因)
select <- order(rowMeans(counts(dds, normalized=TRUE)), decreasing=TRUE)[1:50]
df <- as.data.frame(colData(dds)[, "condition", drop=FALSE])
p_heat <- pheatmap(assay(vsd)[select,], cluster_rows=TRUE, show_rownames=TRUE,
                  cluster_cols=TRUE, annotation_col=df, main="Top 50 Expressed Genes")
save_pheatmap_png <- function(x, filename, width=1200, height=1000, res=150) {
  png(filename, width = width, height = height, res = res)
  grid::grid.newpage()
  grid::grid.draw(x$gtable)
  dev.off()
}
save_pheatmap_png(p_heat, file.path(out_dir, "heatmap_top50.png"))

print("DESeq2 DEA analysis completed successfully.")
