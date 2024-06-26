process CADD {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'docker.io/biocontainers/cadd-scripts:1.7--hdfd78af_0'

    containerOptions {
        (workflow.containerEngine == 'singularity') ?
            "-B ${annotation_dir}:/opt/CADD-scripts-1.7/data/annotations" :
            "-v ${annotation_dir}:/opt/CADD-scripts-1.7/data/annotations"
        }

    input:
    tuple val(meta), path(vcf)
    path(annotation_dir)

    output:
    tuple val(meta), path("*.tsv.gz"), emit: tsv
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = "1.7" // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    """
    cadd.sh \\
        -o ${prefix}.tsv.gz \\
        $args \\
        $vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cadd: $VERSION
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = "1.7" // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    """
    echo echo "" | gzip > ${prefix}.tsv.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cadd: $VERSION
    END_VERSIONS
    """
}
