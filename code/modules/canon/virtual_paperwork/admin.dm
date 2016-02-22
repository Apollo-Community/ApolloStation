/client/proc/modifyCharacterPromotions( mob/living/carbon/human/M as mob in world )
	set name = "Promote / Demote"
	set category = "Fun"

	if( !check_rights( R_FUN ))
		return

	var/mob/user = usr

	var/datum/character/C = M.character

	var/type = input( user, "What type of role modification?", "Set Department" ) as null|anything in list( "Set Department", "Promotion", "Demotion" )

	if( !type )
		return

	switch( type )
		if( "Promotion" )
			var/list/promotions = C.getAllPromotablePositions()
			var/role = input( user, "Choose a role to promote them to:", "Role Promote" ) as null|anything in promotions
			if( !role )
				return

			C.AddJob( role )
		if( "Demotion" )
			var/role = input( user, "Choose a role to demote them from:", "Role Demotion" ) as null|anything in C.getAllDemotablePositions()
			if( !role )
				return

			C.RemoveJob( role )
		if( "Set Department" )
			var/department = input( user, "Choose a department to induct them into:", "Department Induction" ) as null|anything in job_master.departments
			if( !department )
				return

			C.SetDepartment( department )
