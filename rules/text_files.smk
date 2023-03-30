import glob
import os


rule a_s_files:
    output:
        a=expand("{OUTDIR}/a_{id}.txt", OUTDIR = OUTDIR, id = config['sample_id']),
        s=expand("{OUTDIR}/s_{id}.txt", OUTDIR = OUTDIR, id = config['sample_id'])
    resources:
        mem_mb=get_resource("a_s_files", "mem_mb"),
        walltime=get_resource("a_s_files", "walltime")
    log:
        "{}/a_s_files.log".format(LOGDIR)
    benchmark:
        "{}/a_s_files.bmk".format(LOGDIR)
    threads:
        threads=get_resource("a_s_files", "threads")
    script:
        """
        ../scripts/a_s_file_generation.R
        """

rule i_file:
    input:
        sample_ID=config['sample_id'],
        template="resources/i_Investigation.txt"
    output:
        i="{}/i_Investigation.txt".format(OUTDIR)
    resources:
        mem_mb=get_resource("i_file", "mem_mb"),
        walltime=get_resource("i_file", "walltime")
    log:
        "{}/i_file.log".format(LOGDIR)
    benchmark:
        "{}/i_file.bmk".format(LOGDIR)
    threads: 
        threads=get_resource("i_file", "threads")
    shell:
        """
        sed -i 's/PXXXX/{input.sample_ID}/' {input.template} > {output.i}
        """
