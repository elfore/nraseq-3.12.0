process CANCER_GENE_ANNOTATION {
    tag "$meta.id"
    label 'process_low'

    container "biocontainers/bioconductor-deseq2:1.34.0--r41hf17093f_0"

    input:
    tuple val(meta), path(deseq_results)

    output:
    tuple val(meta), path("*.cancer_annotated.csv"), emit: results
    path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    cancer_annotate.r \\
        --input $deseq_results \\
        --output ${prefix}.cancer_annotated.csv \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
    END_VERSIONS
    """
}
