process DESEQ2_DIFFERENTIAL {
    label 'process_medium'

    conda "bioconda::bioconductor-deseq2=1.34.0 bioconda::bioconductor-pheatmap=1.0.12 bioconda::bioconductor-ggplot2=3.3.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-deseq2:1.34.0--r41bioc_0' :
        'quay.io/biocontainers/bioconductor-deseq2:1.34.0--r41bioc_0' }"

    input:
    path counts
    path samplesheet

    output:
    path "deseq2/*", emit: results
    path "versions.yml", emit: versions

    when:
    task.run

    script:
    """
    deseq2_dea.r $counts $samplesheet deseq2/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | head -n 1 | sed 's/R version //;s/ (.*//')
        deseq2: \$(Rscript -e "library(DESeq2); cat(as.character(packageVersion('DESeq2')))")
    END_VERSIONS
    """
}
