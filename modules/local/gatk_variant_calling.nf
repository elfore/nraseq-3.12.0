process GATK_VARIANT_CALLING {
    label 'process_high'

    conda "bioconda::gatk4=4.2.6.1"

    input:
    tuple val(meta), path(bam), path(bai)
    path fasta
    path fasta_fai
    path dict

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path "versions.yml", emit: versions

    script:
    """
    # 1. GATK SplitNCigarReads (针对 RNA-seq 的关键步骤)
    gatk SplitNCigarReads \\
        -R $fasta \\
        -I $bam \\
        -O split.bam

    # 2. HaplotypeCaller
    gatk HaplotypeCaller \\
        -R $fasta \\
        -I split.bam \\
        -O ${meta.id}.vcf.gz \\
        --native-pair-hmm-threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(gatk --version | grep GATK | sed 's/The Genome Analysis Toolkit (GATK) v//')
    END_VERSIONS
    """
}
