/obj/machinery/computer/transfer
	name = "\improper job transfer console"
	desc = "Terminal for handling job transfers. Employees can use this to switch to a role that they've previously been promoted to."
	icon = 'icons/obj/computer_transfer.dmi'
	icon_state = "jobchange"
	density = 0

	circuit = "/obj/item/weapon/circuitboard/transfer"
	var/obj/item/weapon/card/id/scan = null

	light_color = COMPUTER_BLUE

	var/global/list/usage_record = list()

	var/wait_time = 36000 // time in deciseconds until they can transfer again

/obj/machinery/computer/transfer/attackby( obj/O, mob/user )
	if( istype( O, /obj/item/weapon/card/id ))
		var/obj/item/weapon/card/id/C = O

		if( usage_record[user] )
			var/time_passed = world.time-usage_record[user]
			if( time_passed < wait_time )
				buzz("\The [src] buzzes, \"You cannot change your role for another [round( wait_time/600 )-round( time_passed/600 )] minutes!\"")
				flick( "jobchange_deny", src )
				return

		if( !C.character )
			buzz("\The [src] buzzes, \"Card is not tied to a NanoTrasen Employee!\"")
			flick( "jobchange_deny", src )
			return

		var/job = input(usr, "Choose the role you want to change to:", "Department Transfer")  as null|anything in C.character.roles

		if( !job )
			return

		var/datum/job/job_datum = job_master.GetJob( job )

		if( !istype( job_datum ))
			buzz("\The [src] buzzes, \"Invalid role!\"")
			flick( "jobchange_deny", src )
			return

		if( !job_datum.can_join( user.client ))
			buzz("\The [src] buzzes, \"Cannot transfer to [job_datum.title]!\"")
			flick( "jobchange_deny", src )
			return

		if( job_datum.rank_succesion_level >= COMMAND_SUCCESSION_LEVEL )
			buzz("\The [src] buzzes, \"Cannot transfer to a command role on this console!\"")
			flick( "jobchange_deny", src )
			return

		if( "No" == alert(user, "Are you sure you want to transfer to being a [job_datum.title]?", "\The [src]", "Yes", "No"))
			return

		flick( "jobchange_accept", src )
		C.access = job_datum.get_access()
		C.assignment = job_datum.title
		C.rank = job_datum.title

		C.generateName()
		callHook("reassign_employee", list( C ))
		ping( "\The [src] pings, \"[C.name] has transferred to [job_datum.title]!\"" )

		usage_record[user] = world.time
		return

	..()
