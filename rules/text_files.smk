import glob
import os

rule a_s_files:
    output:
        a=expand("{OUTDIR}/a_{id}.txt", OUTDIR = OUTDIR, id = config['sample_id']),
        s=expand("{OUTDIR}/s_{id}.txt", OUTDIR = OUTDIR, id = config['sample_id'])
    resources:
        mem_mb=get_resource("a_s_files", "mem_mb"),
        walltime=get_resource("a_s_files", "walltime")
    params:
        samples = config["samples"],
        input_dir = config["input_dir"],
        input_format = config["input_format"],
        sample_id = config["sample_id"],
        sample_type = config["sample_type"],
        out = config["out"]
    log:
        "{}/a_s_files.log".format(LOGDIR)
    conda:
        "../envs/r.yaml"
    benchmark:
        "{}/a_s_files.bmk".format(LOGDIR)
    threads:
        threads=get_resource("a_s_files", "threads")
    script:
        "../scripts/a_s_file_generation.R"

rule i_file:
    output:
        i="{}/i_Investigation.txt".format(OUTDIR)
    params:
        sample_ID=config['sample_id'],
        template="resources/i_Investigation.txt"
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
        sed 's/PXXXX/{params.sample_ID}/g' {params.template} > {output.i}
        """

rule zip:
    input: 
        i=expand("{OUTDIR}/i_Investigation.txt", OUTDIR=OUTDIR),
        a=expand("{OUTDIR}/a_{id}.txt", OUTDIR = OUTDIR, id= config['sample_id']),
        s=expand("{OUTDIR}/s_{id}.txt", OUTDIR = OUTDIR, id= config['sample_id'])
    output:
        zip=expand("{OUTDIR}/{id}.zip", OUTDIR = OUTDIR, id= config['sample_id'])
    params:
        dir=expand("{OUTDIR}/{id}", OUTDIR = OUTDIR, id= config['sample_id'])
    resources:
        mem_mb=get_resource("zip", "mem_mb"),
        walltime=get_resource("zip", "walltime")
    log:
        "{}/zip.log".format(LOGDIR)
    benchmark:
        "{}/zip.bmk".format(LOGDIR)
    threads:
        threads=get_resource("zip", "threads")
    shell:
        """
        mkdir -p {params.dir}
        mv -t {params.dir} {input.i} {input.a} {input.s} 
        rm -fv {params.dir}/.snakemake_timestamp
        zip -r --junk-path {output.zip} {params.dir}  
        """
