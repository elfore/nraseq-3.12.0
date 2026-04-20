process WGCNA_ANALYSIS {
    label 'process_high'

    conda "bioconda::bioconductor-wgcna=1.70.3"

    input:
    path normalized_counts

    output:
    path "wgcna/*", emit: results
    path "versions.yml", emit: versions

    script:
    """
    mkdir -p wgcna/
    wgcna_analysis.r $normalized_counts wgcna/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | head -n 1 | sed 's/R version //;s/ (.*//')
        WGCNA: \$(Rscript -e "library(WGCNA); cat(as.character(packageVersion('WGCNA')))")
    END_VERSIONS
    """
}
