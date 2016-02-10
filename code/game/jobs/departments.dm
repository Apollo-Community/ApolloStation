/datum/department
	var/name
	var/list/positions = list()
	var/department_id
	var/color = "#FFFFFF"
	var/background_color = "#FFFFFF"
	var/font_color = "#000000"
	var/faction = "Station"

/datum/department/New()
	..()

	for( var/datum/job/job in job_master.occupations )
		if( job.department_id == department_id )
			positions += job

/datum/department/civilian
	name = "Civilian"
	department_id = CIVILIAN
	background_color = "#dddddd"

/datum/department/engineering
	name = "Engineering Division"
	department_id = ENGINEERING
	background_color = "#ffeeaa"

/datum/department/supply
	name = "Supply Division"
	department_id = SUPPLY
	background_color = "#FFF3D8"

/datum/department/medical
	name = "Medical Division"
	department_id = MEDICAL
	background_color = "#EEFFEE"

/datum/department/science
	name = "Research Division"
	department_id = SCIENCE
	background_color = "#ffeeff"

/datum/department/security
	name = "Security Division"
	department_id = SECURITY
	background_color = "#ffeeee"

/datum/department/synthetic
	name = "Synthetic"
	department_id = SYNTHETIC
	background_color = "#ddffdd"
