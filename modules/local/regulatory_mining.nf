process REGULATORY_MINING {
    label 'process_medium'
    container "biocontainers/bioconductor-dorothea:1.6.0--r41hdfd78af_0"

    input:
    path de_results

    output:
    path "regulatory/*.pdf"        , emit: pdf
    path "regulatory/*.csv"        , emit: csv, optional: true
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    regulatory_mining.r --input $de_results --outdir regulatory
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorothea: \$(Rscript -e "library(dorothea); cat(as.character(packageVersion('dorothea')))")
    END_VERSIONS
    """
}
