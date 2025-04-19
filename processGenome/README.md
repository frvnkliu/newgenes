# Raw Data Genome Pipeline

This pipeline processes a **30× human whole‑genome FASTQ** through alignment, variant calling, filtering to genes of interest, and functional annotation.

### Prerequisites

- **BWA** ≥0.7.17  
- **SAMtools** ≥1.10  
- **GATK** ≥4.2  
- **bcftools** ≥1.11  
- **VEP** (Ensembl Variant Effect Predictor) with cache for GRCh38  
- Reference files (all indexed):
  - `GRCh38.fa` & its BWA/SAMtools index
  - `GRCh38.fa.fai`
  - GATK dictionary: `GRCh38.dict`
  - VEP cache under `~/.vep/`
- A BED file of target gene regions: `genes_of_interest.bed`

### Input

- `genome_R1.fastq.gz`  
- `genome_R2.fastq.gz`  (if paired end)

### Outputs

1. **Aligned BAM**: `sample.sorted.bam`  
2. **Raw VCF**: `sample.raw.vcf.gz`  
3. **Gene‑filtered VCF**: `sample.genes.vcf.gz`  
4. **VEP‑annotated VCF**: `sample.vep.vcf.gz`

---

## Usage

```bash
chmod +x run_pipeline.sh
./run_pipeline.sh \
  --r1 genome_R1.fastq.gz \
  --r2 genome_R2.fastq.gz \
  --prefix sample \
  --ref /path/to/GRCh38.fa \
  --bed genes_of_interest.bed
