import datetime
import re

# Set subsampling max date to the reference date
gisaid_index = next((i for i, item in enumerate(config["inputs"] if item["name"] == "gisaid")), None)
reference_date_match = re.search("\d{4}-\d\d-\d\d", config["inputs"][gisaid_index]["metadata"])
reference_date = datetime.strptime(match.group(), "%Y-%m-%d").date()

# Set the earliest date to roughly 6 months ago (26 weeks)
early_late_cutoff = reference_date - datetime.timedelta(weeks=26)

for build in config["subsampling"]:
	for scheme in config["subsampling"][build]:
    if "priorities" in config["subsampling"][build][scheme]:
      continue
		if "_early" in scheme:
			config["subsampling"][build][scheme]["max_date"] = f"--max-date {early_late_cutoff.strftime('%Y-%m-%d')}"
		if "_late" in scheme:
			config["subsampling"][build][scheme]["min_date"] = f"--min-date {early_late_cutoff.strftime('%Y-%m-%d')}"
