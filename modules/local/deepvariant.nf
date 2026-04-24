process DEEPVARIANT {
    tag "$meta.id"
    label 'process_high'

    // DeepVariant container
    container "${params.deepvariant_sif}"

    input:
    tuple val(meta), path(bam), path(bai)
    path fasta
    path fai

    output:
    tuple val(meta), path("*.vcf.gz")    , emit: vcf
    tuple val(meta), path("*.vcf.gz.tbi"), emit: tbi
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    /opt/deepvariant/bin/run_deepvariant \\
        --model_type=${params.deepvariant_model} \\
        --ref=$fasta \\
        --reads=$bam \\
        --output_vcf=${prefix}.vcf.gz \\
        --output_gvcf=${prefix}.g.vcf.gz \\
        --num_shards=$task.cpus \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deepvariant: \$(/opt/deepvariant/bin/run_deepvariant --version | sed 's/DeepVariant version //')
    END_VERSIONS
    """
}
