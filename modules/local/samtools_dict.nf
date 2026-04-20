process SAMTOOLS_DICT {
    tag "$fasta"
    label 'process_low'

    conda "bioconda::samtools=1.17"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00c71ee_0' :
        'quay.io/biocontainers/samtools:1.17--h00c71ee_0' }"

    input:
    path fasta

    output:
    path "*.dict"      , emit: dict
    path "versions.yml", emit: versions

    when:
    task.run

    script:
    """
    samtools dict $fasta > ${fasta.baseName}.dict

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
