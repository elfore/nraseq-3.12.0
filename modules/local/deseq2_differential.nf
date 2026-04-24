process DESEQ2_DIFFERENTIAL {
    label 'process_medium'
    container "biocontainers/bioconductor-deseq2:1.34.0--r41hf17093f_0"

    input:
    path counts
    path samplesheet

    output:
    path "*.results.csv"           , emit: results
    path "*.plots.pdf"             , emit: plots
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    deseq2_differential.r \\
        --counts $counts \\
        --samplesheet $samplesheet \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        bioconductor-deseq2: \$(Rscript -e "library(DESeq2); cat(as.character(packageVersion('DESeq2')))")
    END_VERSIONS
    """
}
