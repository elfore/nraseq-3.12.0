process SNPEFF {
    tag "$meta.id"
    label 'process_medium'

    container "biocontainers/snpeff:5.1d--hdfd78af_0"

    input:
    tuple val(meta), path(vcf)
    path db

    output:
    tuple val(meta), path("*.ann.vcf.gz"), emit: vcf
    path "*.csv"                        , emit: csv
    path "*.html"                       , emit: html
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    snpEff \\
        $args \\
        -csvStats ${prefix}.ann.csv \\
        -s ${prefix}.ann.html \\
        $db \\
        $vcf > ${prefix}.ann.vcf

    bgzip ${prefix}.ann.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snpeff: \$(snpEff -version | sed 's/SnpEff //')
    END_VERSIONS
    """
}
