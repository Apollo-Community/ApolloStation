/var/global/datum/controller/process/law/corp_regs

/datum/controller/process/law
	var/list/laws = list() // All laws

	var/list/low_severity = list()
	var/list/med_severity = list()
	var/list/high_severity = list()

/datum/controller/process/law/New()
	..()

	corp_regs = src

/datum/controller/process/law/setup()
	name = "Law"
	schedule_interval = 100

	low_severity = subtypes( /datum/law/low_severity )
	med_severity = subtypes( /datum/law/med_severity )
	high_severity = subtypes( /datum/law/high_severity )

	laws = low_severity + med_severity + high_severity
