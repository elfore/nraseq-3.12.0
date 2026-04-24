process WGCNA {
    label 'process_high'
    container "biocontainers/r-wgcna:1.70.3--r41h063991c_0"

    input:
    path counts

    output:
    path "wgcna/*.pdf"             , emit: pdf
    path "wgcna/*.csv"             , emit: csv
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    wgcna_analysis.r \\
        --counts $counts \\
        --outdir wgcna \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wgcna: \$(Rscript -e "library(WGCNA); cat(as.character(packageVersion('WGCNA')))")
    END_VERSIONS
    """
}
