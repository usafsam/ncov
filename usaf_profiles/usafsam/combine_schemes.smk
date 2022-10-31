for build in config["subsampling"]:
    for scheme in config["subsampling"][build]:
        if "priorities" in config["subsampling"][build][scheme]:
            continue
        if "combine" in config["subsampling"][build][scheme]:
            include_files = [f"results/{build}/sample-{s}.txt" for s in config["subsampling"][build][scheme]["combine"]]
            config["subsampling"][build][scheme]["exclude"] = "--exclude-all"

def _get_include_files(wildcards):
    subsampling_settings = _get_subsampling_settings(wildcards)

    combine_schemes = subsampling_settings["combine"]

    return [f"results/{wildcards.build_name}/sample-{s}.txt" for s in combine_schemes]

# XXX: This is an **extremely hacky** workaround that MAY BREAK!
#      Use this rule with EXTREME CAUTION!
rule subsample_with_include_files:
    message:
        """
        Subsample all sequences by '{wildcards.subsample}' scheme for build '{wildcards.build_name}' with the following parameters:

         - group by: {params.group_by}
         - sequences per group: {params.sequences_per_group}
         - subsample max sequences: {params.subsample_max_sequences}
         - min-date: {params.min_date}
         - max-date: {params.max_date}
         - {params.exclude_ambiguous_dates_argument}
         - exclude: {params.exclude_argument}
         - include: {params.include_argument}
         - query: {params.query_argument}
         - priority: {params.priority_argument}
        """
    input:
        include_files = _get_include_files,
        metadata = _get_unified_metadata,
        include = config["files"]["include"],
        priorities = get_priorities,
        exclude = config["files"]["exclude"]
    output:
        strains="results/{build_name}/sample-{subsample}.txt",
    log:
        "logs/subsample_{build_name}_{subsample}.txt"
    benchmark:
        "benchmarks/subsample_{build_name}_{subsample}.txt"
    params:
        group_by = _get_specific_subsampling_setting("group_by", optional=True),
        sequences_per_group = _get_specific_subsampling_setting("seq_per_group", optional=True),
        subsample_max_sequences = _get_specific_subsampling_setting("max_sequences", optional=True),
        sampling_scheme = _get_specific_subsampling_setting("sampling_scheme", optional=True),
        exclude_argument = _get_specific_subsampling_setting("exclude", optional=True),
        include_argument = _get_specific_subsampling_setting("include", optional=True),
        query_argument = _get_specific_subsampling_setting("query", optional=True),
        exclude_ambiguous_dates_argument = _get_specific_subsampling_setting("exclude_ambiguous_dates_by", optional=True),
        min_date = _get_specific_subsampling_setting("min_date", optional=True),
        max_date = _get_specific_subsampling_setting("max_date", optional=True),
        priority_argument = get_priority_argument
    resources:
        # Memory use scales with the number of sequences per group * number of groups.
        # We pin this to a reasonably high value based on Nextstrain production builds.
        mem_mb=4000
    conda: config["conda_environment"]
    shell:
        """
        augur filter \
            --metadata {input.metadata} \
            --include {input.include} {input.include_files} \
            --exclude {input.exclude} \
            {params.min_date} \
            {params.max_date} \
            {params.exclude_argument} \
            {params.include_argument} \
            {params.query_argument} \
            {params.exclude_ambiguous_dates_argument} \
            {params.priority_argument} \
            {params.group_by} \
            {params.sequences_per_group} \
            {params.subsample_max_sequences} \
            {params.sampling_scheme} \
            --output-strains {output.strains} 2>&1 | tee {log}
        """

ruleorder: subsample_with_include_files > subsample
