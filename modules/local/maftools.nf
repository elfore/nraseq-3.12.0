process MAFTOOLS {
    tag "$meta.id"
    label 'process_medium'

    container "biocontainers/bioconductor-maftools:2.10.0--r41hdfd78af_0"

    input:
    tuple val(meta), path(vcf)

    output:
    path "maftools/*"   , emit: plots
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    maftools_stats.r \\
        --vcf $vcf \\
        --outdir maftools \\
        --prefix ${meta.id} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        maftools: \$(Rscript -e "library(maftools); cat(as.character(packageVersion('maftools')))")
    END_VERSIONS
    """
}
