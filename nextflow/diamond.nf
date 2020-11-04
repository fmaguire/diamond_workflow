#!/usr/bin/env nextflow

nextflow.enable.dsl=2


def helpMessage() {
    log.info """
\nUsage:
The typical command for running the pipeline is as follows:
nextflow run fmaguire/shared_gene_network --input_sequences data
Mandatory arguments:
    --input_sequences                       Path to input data: folder containing FASTA formatted genomes/contigs
    --reference_database                    Path to fasta file containing reference sequences you want to search against
Optional arguments:
    --outdir                                Path to output results into (default: "results")
    --cpus                                  Number of CPUs to assign to executor
"""
}

process predict_ORFS {
    tag { "Prodigal: ${assembly_fasta}" }
    conda "$baseDir/../conda_envs/prodigal.yml"
    input:
        path(assembly_fasta)
    output:
        path("*_orfs.faa")
    shell:
        """
        prodigal -a ${assembly_fasta.simpleName}_orfs.faa -i ${assembly_fasta}
        """
}


process make_diamond_database {
    tag { "diamond makedb" }
    conda "$baseDir/../conda_envs/diamond.yml"
    input:
        path(reference_fasta)
    output:
        path("diamond_reference_db.dmnd")
    shell:
        """
        diamond makedb --threads ${task.cpus} --in $reference_fasta --db diamond_reference_db
        """
}


// DIAMONDBLASTP
process run_diamond_blastp {
    tag { "diamond blastp: ${assembly_orfs}" }
    publishDir "nextflow_results/diamond_output", pattern: "*.out6", mode: "copy"
    conda "$baseDir/../conda_envs/diamond.yml"
    input:
        path(assembly_orfs)
        path(diamond_database) 
    output:
        path("*.out6")
    script:
        """
        diamond blastp --threads ${task.cpus} --max-target-seqs 25 --db ${diamond_database} --outfmt 6 --out ${assembly_orfs.simpleName}.out6 --more-sensitive --query ${assembly_orfs}
        """
} 


workflow {

	/* 	
		CLI interface
	*/

	if (params.help) {
		helpMessage()
		exit 0
	}
    
    if (!params.input_sequences) {
        println("\nMust provide folder of FASTA contigs/genomes/plasmids as --input_sequences\n")
        helpMessage()
        exit 1
    }

    if (!params.reference_database) {
        println("\nMust provide path to reference fasta as --reference_database\n")
        helpMessage()
        exit 1
    }



    // Detect ORFs and translate proteins using prodigal
    assemblies = Channel.fromPath( params.input_sequences + "/*.{fa,fasta,fna}" )
                .ifEmpty { error "\nCannot find any FASTA formatted sequences in ${params.input_sequences}\n" }

    database_path = Channel.fromPath( params.reference_database );

    database = make_diamond_database( database_path );

    orfs = predict_ORFS( assemblies );
    
    //diamond_input = orfs.combine( database );

    run_diamond_blastp ( orfs, database );

}
