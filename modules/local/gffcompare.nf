process GFFCOMPARE {
    tag "Boundary_Optimization"
    label 'process_medium'
    container "biocontainers/gffcompare:0.12.6--h43ee347_0"

    input:
    tuple val(meta), path(gtf)
    path ref_gtf

    output:
    path "gffcompare/*"    , emit: results
    path "versions.yml"    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mkdir gffcompare
    gffcompare \\
        -r $ref_gtf \\
        -o gffcompare/out \\
        $args \\
        $gtf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gffcompare: \$(gffcompare --version 2>&1 | sed 's/gffcompare v//')
    END_VERSIONS
    """
}
