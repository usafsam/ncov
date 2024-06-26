import datetime
import re

# Set subsampling max date to the reference date
reference_date_match = re.search("\d{4}-\d\d-\d\d", config["inputs"]["gisaid"]["metadata"])
reference_date = datetime.datetime.strptime(reference_date_match.group(), "%Y-%m-%d").date()

# Set the earliest date to roughly 4 months ago (18 weeks)
early_cutoff = reference_date - datetime.timedelta(weeks=18, days=1)
late_cutoff = reference_date - datetime.timedelta(weeks=18)

for build in config["subsampling"]:
    for scheme in config["subsampling"][build]:
        if "priorities" in config["subsampling"][build][scheme]:
            continue
        if "_early" in scheme:
            config["subsampling"][build][scheme]["max_date"] = f"--max-date {early_cutoff.strftime('%Y-%m-%d')}"
        if "_late" in scheme:
            config["subsampling"][build][scheme]["min_date"] = f"--min-date {late_cutoff.strftime('%Y-%m-%d')}"
