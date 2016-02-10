/datum/department
	var/name
	var/list/positions = list()
	var/list/starting_positions = list()
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
	starting_positions = list( "Assistant" = "Low" )

/datum/department/engineering
	name = "Engineering Division"
	department_id = ENGINEERING
	background_color = "#ffeeaa"
	starting_positions = list( "Engineer Assistant" = "High" )

/datum/department/supply
	name = "Cargo Bay"
	department_id = SUPPLY
	background_color = "#FFF3D8"
	starting_positions = list( "Supply Technician" = "High" )

/datum/department/medical
	name = "Medical Bay"
	department_id = MEDICAL
	background_color = "#EEFFEE"
	starting_positions = list( "Nurse" = "High" )

/datum/department/science
	name = "Research Division"
	department_id = SCIENCE
	background_color = "#ffeeff"
	starting_positions = list( "Research Assistant" = "High" )

/datum/department/security
	name = "Security Department"
	department_id = SECURITY
	background_color = "#ffeeee"
	starting_positions = list( "Security Cadet" = "High" )

/datum/department/synthetic
	name = "Synthetic"
	department_id = SYNTHETIC
	background_color = "#ddffdd"
	starting_positions = list( "Cyborg" = "High" )
