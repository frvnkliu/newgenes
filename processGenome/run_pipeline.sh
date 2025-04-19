
---

## run_pipeline.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --r1 <R1.fastq.gz> --r2 <R2.fastq.gz> --prefix <sample> \\
          --ref <GRCh38.fa> --bed <genes.bed>

Align, call variants, filter to genes, and annotate with VEP.
EOF
  exit 1
}

# parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --r1)    R1="$2"; shift 2;;
    --r2)    R2="$2"; shift 2;;
    --prefix)PREFIX="$2"; shift 2;;
    --ref)   REF="$2"; shift 2;;
    --bed)   BED="$2"; shift 2;;
    *)       usage;;
  esac
done

: "${R1:?--r1 is required}"
: "${R2:?--r2 is required}"
: "${PREFIX:?--prefix is required}"
: "${REF:?--ref is required}"
: "${BED:?--bed is required}"

# derived names
SORTED_BAM="${PREFIX}.sorted.bam"
RAW_VCF="${PREFIX}.raw.vcf.gz"
GENE_VCF="${PREFIX}.genes.vcf.gz"
VEP_VCF="${PREFIX}.vep.vcf.gz"

echo "[1/5] Aligning with BWA-MEM..."
bwa mem -t 16 "$REF" "$R1" "$R2" \
  | samtools sort -@ 8 -o "$SORTED_BAM"

samtools index "$SORTED_BAM"

echo "[2/5] Calling variants with GATK HaplotypeCaller..."
gatk --java-options "-Xmx32G" HaplotypeCaller \
  -R "$REF" \
  -I "$SORTED_BAM" \
  -O "$RAW_VCF" \
  -ERC GVCF

echo "[3/5] Filtering to genes of interest with bcftools..."
bcftools view -R "$BED" "$RAW_VCF" -Oz -o "$GENE_VCF"
bcftools index "$GENE_VCF"

echo "[4/5] Annotating with VEP..."
vep \
  --input_file "$GENE_VCF" \
  --output_file "$VEP_VCF" \
  --vcf \
  --cache \
  --offline \
  --assembly GRCh38 \
  --terms SO \
  --plugin LoF \
  --fork 4

echo "[5/5] Done!
  - Aligned BAM:      $SORTED_BAM
  - Raw VCF:          $RAW_VCF
  - Gene VCF:         $GENE_VCF
  - VEP Annotated:    $VEP_VCF
"
