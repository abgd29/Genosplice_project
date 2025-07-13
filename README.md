# Transcriptomic Analysis — GSE229613

This repository contains a R project for performing differential gene expression analysis based on raw count data from the experiment **GSE229613**.

---

## 📁 Project Structure

```
.
├── Data/
│   ├── Input/
│   │   └── GSE229613_gene_count_1.txt
│   └── Output/
├── analyse_transcriptome.R
├── analyse_transcriptome.qmd
├── analyse_transcriptome.Rmd
├── README.md
```

---

## 🔧 Requirements

Before running the analysis, make sure the following R packages are installed:

```r
install.packages(c("dplyr", "ggplot2", "pheatmap", "forcats"))
BiocManager::install(c("edgeR", "limma", "clusterProfiler", "org.Hs.eg.db", "enrichplot"))
```

> You may need to install **Bioconductor** first:

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
```

---

## ▶️ How to Run the Analysis

You can execute the analysis by opening one of the following in **RStudio**:

- `analyse_transcriptome.R` — raw R script version
- `nalyse_transcriptome.qmd` — literate code version with output

### To render the HTML report (recommended):

Open the `.qmd` file and click **"RENDER"** or use:

```r
quarto::render("analyse_transcriptome.qmd")
```

---

## 📅 Input

The input file is:

```
./Data/Input/GSE229613_gene_count_1.txt
```
You should download this file form the GEO database at [GSE229613](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE229613)
This file must contain **raw gene counts** (rows = genes, columns = samples). It should include the gene ID column `gid`, which will be used as row names.

---

## 📄 Output

After execution, output files will be written to:

```
./Data/Output/
```

Including:

- `DEG.csv`: full table of differentially expressed genes
- `ORA.csv`: enrichment analysis results

---

## 📊 Workflow Overview

1. **Data Import & Preprocessing**
2. **Normalization and Filtering**
3. **Differential Expression Analysis** using `edgeR` and `limma`
4. **Visualization**: MDS plot, volcano plot, heatmap
5. **Gene Ontology Enrichment Analysis** using `clusterProfiler`
6. **Export of Results**

---

## 🧬 Reference Dataset

- **GEO Accession**: [GSE229613](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE229613)
- Organism: *Homo sapiens*
- Format: Raw gene counts

---

## 📌 Notes

- You **must update** the input/output paths to your environment.
- For reproducibility, a fixed random seed (`set.seed(2002)`) is used.

---



