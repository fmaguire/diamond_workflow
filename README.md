# DIAMOND workflows

Trivial DIAMOND nextflow and snakemake workflows to perform ORF calling on a 
set of genomes and using DIAMOND-BLASTP to query ORF amino acid sequences 
against a user supplied reference database to act as examples

## Running nextflow

Move to the `nextflow` directory

    cd nextflow

Install nextflow (requires Java 8 or later and conda on your system):

    curl -s https://get.nextflow.io | bash

Execute workflow (in this example on test data with 2 CPUs), requires a folder
containing genomes fastas (i.e. `../data`) and a protein reference database fasta `../reference/small_cazy.faa`

    ./nextflow run diamond.nf --input_sequences ../data --reference_database ../reference/small_cazy.faa --cpus 2

Results files will be output to `nextflow_results/diamond_output/`

    nextflow_results/
    └── diamond_output
        ├── GCF_000662585_orfs.out6
        └── GCF_902827215_orfs.out6

## Running snakemake

Move to the `snakemake` directory
    
    cd snakemake

Install snakemake (requires conda installed):
    
    conda install -c conda-forge mamba
    mamba create -c conda-forge -c bioconda -n snakemake snakemake conda
    conda activate snakemake
 
Execute workflow (in this example on test data with 2 CPUs), requires a folder
containing genomes fastas (i.e. `../data`) and a protein reference database fasta `../reference/small_cazy.faa`

    snakemake --use-conda --cores 2 --config input_sequences=../data reference_database=../reference/small_cazy.faa  

Results files will be output to `snakemake_results/diamond_output`

    snakemake_results/
    └── diamond_output
        ├── GCF_000662585.1.out6
        └── GCF_902827215.1_SB5881_genomic.out6

