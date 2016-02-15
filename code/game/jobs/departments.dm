/datum/department
	var/name
	var/list/positions = list()
	var/list/starting_positions = list()
	var/department_id
	var/color = "#FFFFFF"
	var/background_color = "#FFFFFF"
	var/font_color = "#000000"
	var/faction = "Station"
	var/region_access = list()

/datum/department/New()
	..()

	for( var/datum/job/job in job_master.occupations )
		if( job.department_id == department_id )
			positions += job

/datum/department/proc/getPositionNames()
	var/list/names = list()

	for( var/datum/job/position in positions )
		names.Add( position.title )

	return names

/datum/department/civilian
	name = "Civilian"
	department_id = CIVILIAN
	background_color = "#dddddd"
	starting_positions = list( "Assistant" = "Low" )
	region_access = list(access_kitchen,access_bar, access_hydroponics, access_janitor, access_chapel_office, access_crematorium, access_library, access_theatre, access_lawyer, access_clown, access_mime)

/datum/department/engineering
	name = "Engineering Division"
	department_id = ENGINEERING
	background_color = "#ffeeaa"
	starting_positions = list( "Engineer Assistant" = "High" )
	region_access = list(access_construction, access_maint_tunnels, access_engine, access_engine_equip, access_external_airlocks, access_tech_storage, access_atmospherics, access_ce, access_energy_barrier)

/datum/department/supply
	name = "Cargo Bay"
	department_id = SUPPLY
	background_color = "#FFF3D8"
	starting_positions = list( "Supply Technician" = "High" )
	region_access = list(access_mailsorting, access_mining, access_mining_station, access_cargo, access_qm)

/datum/department/medical
	name = "Medical Bay"
	department_id = MEDICAL
	background_color = "#EEFFEE"
	starting_positions = list( "Nurse" = "High" )
	region_access = list(access_medical, access_genetics, access_morgue, access_chemistry, access_psychiatrist, access_virology, access_surgery, access_cmo)

/datum/department/science
	name = "Research Division"
	department_id = SCIENCE
	background_color = "#ffeeff"
	starting_positions = list( "Research Assistant" = "High" )
	region_access = list(access_research, access_tox, access_tox_storage, access_robotics, access_xenobiology, access_xenoarch, access_rd)

/datum/department/security
	name = "Security Department"
	department_id = SECURITY
	background_color = "#ffeeee"
	starting_positions = list( "Security Cadet" = "High" )
	region_access = list(access_sec_doors, access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)

/datum/department/synthetic
	name = "Synthetic"
	department_id = SYNTHETIC
	background_color = "#ddffdd"
	starting_positions = list( "Cyborg" = "High" )

/datum/department/synthetic/New()
	region_access = get_all_accesses()

// for eventual command department
//list(access_heads, access_RC_announce, access_keycard_auth, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_tcomsat, access_gateway, access_all_personal_lockers, access_heads_vault, access_hop, access_captain)
