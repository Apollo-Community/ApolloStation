/datum/objective/ninja_highlander
	explanation_text = "You aspire to be a Grand Master of the Spider Clan. Kill all of your fellow acolytes."

/datum/objective/ninja_highlander/check_completion()
	if(owner)
		for(var/datum/mind/ninja in ticker.mode.ninjas)
			if(ninja != owner)
				if(ninja.current.stat < 2) return 0
		return 1
	return 0