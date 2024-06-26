process FASTQC {
    tag "$meta.id"
    label 'process_low'
    container 'quay.io/biocontainers/fastqc:0.11.9--0'
    errorStrategy "retry"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip") , emit: zip

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ' '
    // Add soft-links to original FastQs for consistent naming in pipeline
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (meta.single_end) {
        """
        [ ! -f  ${prefix}.fastq.gz ] && ln -s $reads ${prefix}.fastq.gz
        fastqc $args --threads $task.cpus ${prefix}.fastq.gz
        """
    } else {
        """
        [ ! -f  ${prefix}_1.fastq.gz ] && ln -s ${reads[0]} ${prefix}_1.fastq.gz
        [ ! -f  ${prefix}_2.fastq.gz ] && ln -s ${reads[1]} ${prefix}_2.fastq.gz
        fastqc $args --threads $task.cpus ${prefix}_1.fastq.gz ${prefix}_2.fastq.gz
        """
    }

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.html
    touch ${prefix}.zip
    """
}
