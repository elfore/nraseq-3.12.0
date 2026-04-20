#!/usr/bin/env Rscript

library(clusterProfiler)
library(ggplot2)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    stop("Usage: enrichment.r <deg_list.csv> <species> <out_dir>")
}

deg_file <- args[1]
species <- args[2] # human or mouse
out_dir <- args[3]

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# 确定物种数据库
org_db <- if(species == "human") "org.Hs.eg.db" else if(species == "mouse") "org.Mm.eg.db" else stop("Unsupported species")
library(org_db, character.only = TRUE)

# 加载差异基因
deg_data <- read.csv(deg_file, row.names = 1)
# 筛选显著差异基因 (padj < 0.05)
genes <- rownames(deg_data[which(deg_data$padj < 0.05), ])

if (length(genes) < 10) {
    stop("Too few differentially expressed genes for enrichment analysis.")
}

# 处理 Ensembl ID (去除版本号，如 ENSG00000000003.16 -> ENSG00000000003)
genes_clean <- gsub("\\..*$", "", genes)

# 转换 ID (尝试从 ENSEMBL 转换)
gene_entrez <- bitr(genes_clean, fromType = "ENSEMBL", toType = "ENTREZID", OrgDb = org_db)

# 1. GO 富集分析
go_res <- enrichGO(gene         = gene_entrez$ENTREZID,
                   OrgDb        = org_db,
                   ont          = "ALL",
                   pAdjustMethod = "BH",
                   pvalueCutoff  = 0.05,
                   qvalueCutoff  = 0.2,
                   readable     = TRUE)

write.csv(as.data.frame(go_res), file.path(out_dir, "GO_enrichment_results.csv"))
p_go <- dotplot(go_res, showCategory=20) + labs(title="GO Enrichment")
ggsave(file.path(out_dir, "GO_dotplot.png"), p_go, width=10, height=8)

# 2. KEGG 通路分析
kegg_species <- if(species == "human") "hsa" else "mmu"
kegg_res <- enrichKEGG(gene         = gene_entrez$ENTREZID,
                       organism     = kegg_species,
                       pvalueCutoff = 0.05)

write.csv(as.data.frame(kegg_res), file.path(out_dir, "KEGG_enrichment_results.csv"))
if (!is.null(kegg_res) && nrow(kegg_res) > 0) {
    p_kegg <- dotplot(kegg_res, showCategory=20) + labs(title="KEGG Enrichment")
    ggsave(file.path(out_dir, "KEGG_dotplot.png"), p_kegg, width=10, height=8)
}

print("Enrichment analysis completed.")
