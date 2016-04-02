/datum/antagonist/traitor/persistant
	name = "Autonomous Agent"
	greeting = "You are an autonomous agent."
	obligatory_contracts = 0

/datum/antagonist/traitor/persistant/New(var/datum/mind/us, var/datum/faction/syndicate/join_faction)
	..(us)

	faction = join_faction

/datum/antagonist/traitor/persistant/equip()
	