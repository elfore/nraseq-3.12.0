process RMATS {
    label 'process_high'

    conda "bioconda::rmats=4.1.2"

    input:
    tuple val(condition1), path(bam1)
    tuple val(condition2), path(bam2)
    path gtf
    val read_length

    output:
    path "rmats_results/*", emit: results
    path "versions.yml", emit: versions

    script:
    def group1 = bam1.join(',')
    def group2 = bam2.join(',')
    """
    echo "$group1" > b1.txt
    echo "$group2" > b2.txt

    rmats.py \\
        --b1 b1.txt \\
        --b2 b2.txt \\
        --gtf $gtf \\
        -t paired \\
        --readLength $read_length \\
        --nthread ${task.cpus} \\
        --od rmats_results \\
        --tmp tmp_rmats

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rmats: \$(rmats.py --version | sed 's/v//')
    END_VERSIONS
    """
}
