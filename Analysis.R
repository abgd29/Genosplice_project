################################################################################
### 1 - Session preparation
################################################################################
#####
# 1.1 - Cleaning up the environnment
#####

rm(list = objects())
graphics.off()
set.seed(2002)

#####
# 1.2 - Loading Packages
#####

library(edgeR)
library(limma)
library(dplyr)
library(ggplot2)
library(pheatmap)
library(clusterProfiler)
library(org.Hs.eg.db)  
library(enrichplot)
library(forcats)


#####
# 1.3 - Global parameters
#####

pvalue_tresh = 0.01
input_dir = "./Data/Input/"
output_dir = "./Data/Output/"

#####
# 1.4 - Loading Data
#####

gene_counts = read.table(paste0(input_dir, "./GSE229613_gene_count_1.txt"), header = TRUE)
rownames(gene_counts) = gene_counts$gid
gene_counts$gid = NULL
gene_counts$gname = NULL

################################################################################
### 2 - Differential Gene Expression Analysis 
################################################################################
#####
# 2.1 - Data Preparation 
#####

group <- factor(c("control", "control", "control", "treated", "treated", "treated"))
mm <- model.matrix(~0 + group)

dge <- DGEList(counts = gene_counts)
dge <- calcNormFactors(dge, method = "TMM")

plotMDS(dge, col = as.numeric(group))
legend("topleft", legend = levels(group), col = 1:length(levels(group)), pch = 16)

#####
# 2.2 - Genes Filtration  
#####


cutoff <- 1
drop <- which(apply(cpm(dge), 1, max) < cutoff)
dge_filtered <- dge[-drop,] 
message(paste0( length(drop)," Genes were filtered ", "\n", dim(dge_filtered)[1], " Genes are left" ))

par(mfrow = c(1,2))
y <- voom(dge, mm, plot = TRUE)
title("Before filtration", line = 2.5 )

y_filtered  <- voom(dge_filtered, mm, plot = TRUE)
title("After filtration", line = 2.5)

par(mfrow = c(1,1))

#####
# 2.3 - Model fitting 
#####

fit <- lmFit(y_filtered, mm)
contr <- makeContrasts(grouptreated - groupcontrol , levels = colnames(coef(fit)))
tmp <- contrasts.fit(fit, contr)
tmp <- eBayes(tmp)
deg.table <- topTable(tmp, sort.by = "P", n = Inf)
deg.filtered <- deg.table[(which(deg.table$adj.P.Val < pvalue_tresh)),]

hist(deg.table$logFC, breaks = 50, main = "logFC distibution", xlab = "logFC")

#####
# 2.4 -DEG Analysis
#####
#---------------------------- Volcano plot ------------------------------------#

x = deg.table$logFC
y = -log10(deg.table$adj.P.Val)
pvalues = deg.table$adj.P.Val


ggplot(data = as.data.frame(cbind(x,y)), 
       mapping = aes(x,
                     y, 
                     color = ifelse(!is.na(pvalues) & pvalues > pvalue_tresh, 
                                    "Non Significant", 
                                    "Significant")))+
  geom_point()+
  scale_color_manual(values = c("Non Significant" = "black", "Significant" = "red"),
                     name = NULL) +
  xlab("Log2 fold change") +
  ylab("-Log10 pvalues adjusted")


#----------------------------- Clustering -------------------------------------#

genes_deg_id <- rownames(deg.filtered)
expr_mat <- y_filtered$E[genes_deg_id, ]  
expr_scaled <- t(scale(t(expr_mat)))


annotation <- data.frame(Condition = group)
rownames(annotation) <- colnames(expr_scaled)  


pheatmap(expr_scaled,
         annotation_col = annotation,
         show_rownames = FALSE,
         clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean",
         clustering_method = "complete",
         main = "Heatmap des gènes différentiellement exprimés")

#----------------------------- Statistics -------------------------------------#

summary(deg.filtered)
n_deg = dim(deg.filtered)[1]
n_deg_pos = length(which(deg.filtered$logFC > 0))
n_deg_neg = length(which(deg.filtered$logFC < 0))

n_deg
n_deg_pos
n_deg_neg

################################################################################
### 3 - Gene enrichissment analysis 
################################################################################

ORA_res <- enrichGO(gene = genes_deg_id,
                OrgDb = org.Hs.eg.db,
                keyType  = "ENSEMBL",
                ont = "BP",
                pAdjustMethod = "BH",
                qvalueCutoff = pvalue_tresh,
                readable = TRUE
                )

ORA_res_filtered <- ORA_res
ORA_res_filtered@result <- ORA_res@result[ORA_res@result$qvalue < pvalue_tresh, ]
summary(ORA_res_filtered@result)

top.20.func.cat = c("Protein synthesis & translation",
                           "Protein synthesis & translation",
                           "Nucleotide metabolism",
                           "Nucleotide metabolism",
                           "Energy metabolism and respiration",
                           "Nucleotide metabolism",
                           "Nucleotide metabolism",
                           "Nucleotide metabolism",
                           "Protein synthesis & translation",
                           "Nucleotide metabolism",
                           "Nucleotide metabolism",
                           "Energy metabolism and respiration",
                           "Embryo Developpemnt",
                           "Energy metabolism and respiration",
                           "Post-translational regulation",
                           "Energy metabolism and respiration",
                           "Nucleotide metabolism",
                           "Nucleotide metabolism",
                           "Nucleotide metabolism",
                           "Post-translational regulation"
                           )
ORA_res_filtered@result$func.cat <- NA
ORA_res_filtered@result$func.cat[1:20] <- top.20.func.cat

top20 <- ORA_res_filtered@result[1:20, ]
top20$GeneRatio_numeric <- sapply(top20$GeneRatio, function(x) eval(parse(text = x)))



ggplot(top20, aes(x = fct_reorder(Description, GeneRatio_numeric),
                  y = GeneRatio_numeric,
                  size = Count,
                  color = func.cat)) +
  geom_point() +
  coord_flip() +
  scale_color_brewer(palette = "Set2", name = "Functional Category") +
  labs(title = "      Top 20 Enriched Terms",
       x = NULL, y = "Gene Ratio") +
  theme_minimal(base_size = 12) +
  theme(legend.key.size = unit(1.5, "lines")) + 
  guides(color = guide_legend(override.aes = list(size = 6)))  


################################################################################
### 4 - Writing Output files 
################################################################################

write.csv(deg.table, paste0(output_dir, "DEG.csv"))
write.csv(ORA_res@result, paste0(output_dir, "ORA.csv"))
