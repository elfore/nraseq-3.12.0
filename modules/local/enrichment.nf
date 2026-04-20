process ENRICHMENT_ANALYSIS {
    label 'process_medium'

    conda "bioconda::bioconductor-clusterprofiler=4.2.0 bioconda::bioconductor-org.hs.eg.db=3.14.0 bioconda::bioconductor-org.mm.eg.db=3.14.0"

    input:
    path deg_list
    val species

    output:
    path "enrichment/*", emit: results
    path "versions.yml", emit: versions

    when:
    task.run

    script:
    """
    mkdir -p enrichment/
    enrichment.r $deg_list $species enrichment/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | head -n 1 | sed 's/R version //;s/ (.*//')
        clusterProfiler: \$(Rscript -e "library(clusterProfiler); cat(as.character(packageVersion('clusterProfiler')))")
    END_VERSIONS
    """
}
