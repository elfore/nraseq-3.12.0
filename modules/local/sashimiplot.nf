process SASHIMIPLOT {
    tag "AS_Visualization"
    label 'process_medium'
    container "biocontainers/rmats2sashimiplot:2.0.4--py39h6f36829_1"

    input:
    path rmats_results
    tuple val(cond1), path(bams1)
    tuple val(cond2), path(bams2)

    output:
    path "sashimi/*.pdf"   , emit: plots
    path "versions.yml"    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def b1 = bams1.join(',')
    def b2 = bams2.join(',')
    """
    rmats2sashimiplot \\
        --b1 $b1 \\
        --b2 $b2 \\
        -t SE \\
        -e $rmats_results \\
        --lfl 100 \\
        -o sashimi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rmats2sashimiplot: 2.0.4
    END_VERSIONS
    """
}
