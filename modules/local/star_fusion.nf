process STAR_FUSION {
    tag "$meta.id"
    label 'process_high'
    container "trinityctat/star-fusion:1.12.0"

    input:
    tuple val(meta), path(reads)
    path star_fusion_genome_dir

    output:
    path "star-fusion_out/*"       , emit: results
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def left = reads[0]
    def right = reads[1]
    """
    STAR-Fusion --genome_lib_dir $star_fusion_genome_dir \\
        --left_fq $left \\
        --right_fq $right \\
        --output_dir star-fusion_out \\
        --CPU $task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        star_fusion: \$(STAR-Fusion --version | sed 's/STAR-Fusion version: //')
    END_VERSIONS
    """
}
