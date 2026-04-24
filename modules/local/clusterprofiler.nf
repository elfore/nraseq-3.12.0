process CLUSTERPROFILER {
    label 'process_medium'
    container "biocontainers/bioconductor-clusterprofiler:4.2.1--r41hdfd78af_0"

    input:
    path de_results

    output:
    path "enrichment/*.pdf"        , emit: pdf
    path "enrichment/*.csv"        , emit: csv, optional: true
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    clusterprofiler_enrichment.r --input $de_results --outdir enrichment
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bioconductor-clusterprofiler: \$(Rscript -e "library(clusterProfiler); cat(as.character(packageVersion('clusterProfiler')))")
    END_VERSIONS
    """
}
