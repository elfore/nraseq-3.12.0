process FUSIONINSPECTOR {
    tag "$meta.id"
    label 'process_high'
    container "trinityctat/fusioninspector:2.4.0"

    input:
    tuple val(meta), path(fusion_list)
    path star_fusion_genome_dir
    tuple val(meta), path(reads)

    output:
    path "fusion_inspector_out/*"  , emit: results
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def left = reads[0]
    def right = reads[1]
    """
    FusionInspector --genome_lib_dir $star_fusion_genome_dir \\
        --fusions $fusion_list \\
        --left_fq $left \\
        --right_fq $right \\
        --output_dir fusion_inspector_out \\
        --CPU $task.cpus \\
        --vis

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fusion_inspector: 2.4.0
    END_VERSIONS
    """
}
