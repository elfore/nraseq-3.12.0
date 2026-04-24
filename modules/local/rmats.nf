process RMATS {
    tag "AS_Analysis"
    label 'process_high'
    container "biocontainers/rmats:4.1.2--py39h6f36829_1"

    input:
    tuple val(cond1), path(bams1)
    tuple val(cond2), path(bams2)
    path gtf

    output:
    path "rmats_out/*.txt"          , emit: txt
    path "rmats_out/*.pdf"          , emit: pdf, optional: true
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def b1 = bams1.join(',')
    def b2 = bams2.join(',')
    """
    echo $b1 > b1.txt
    echo $b2 > b2.txt
    
    rmats.py \\
        --gtf $gtf \\
        --b1 b1.txt \\
        --b2 b2.txt \\
        --od rmats_out \\
        --tmp tmp \\
        -t paired \\
        --readLength ${params.rmats_read_length} \\
        --nthread $task.cpus \\
        --variable-read-length \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rmats: \$(rmats.py --version | sed 's/v//')
    END_VERSIONS
    """
}
