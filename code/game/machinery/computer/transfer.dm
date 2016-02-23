/obj/machinery/computer/transfer
	name = "\improper role transfer console"
	desc = "Terminal for handling role transfers. Employees can use this to switch to a role they have already been promoted to."
	icon_state = "id"

	circuit = "/obj/item/weapon/circuitboard/transfer"
	var/obj/item/weapon/card/id/scan = null

	light_color = COMPUTER_BLUE

	var/list/usage_record = list()

	var/wait_time = 36000 // time in deciseconds until they can transfer again

/obj/machinery/computer/transfer/attackby( obj/O, mob/user )
	if( istype( O, /obj/item/weapon/card/id ))
		var/obj/item/weapon/card/id/C = O

		if( usage_record[user] )
			var/time_passed = world.time-usage_record[user]
			if( time_passed < wait_time )
				buzz("\The [src] buzzes, \"You cannot change your role for another [round( wait_time/600 )-round( time_passed/600 )] minutes!\"")
				return

		if( !C.character )
			buzz("\The [src] buzzes, \"Card is not tied to a NanoTrasen Employee!\"")
			return

		var/job = input(usr, "Choose the role you want to change to:", "Department Transfer")  as null|anything in C.character.roles

		if( !job )
			return

		var/datum/job/job_datum = job_master.GetJob( job )

		if( !istype( job_datum ))
			buzz("\The [src] buzzes, \"Invalid role!\"")
			return

		if( job_datum.is_full() )
			buzz("\The [src] buzzes, \"Role is full!\"")
			return

		C.access = job_datum.get_access()
		C.assignment = job_datum.title
		C.rank = job_datum.title

		C.generateName()
		callHook("reassign_employee", list( C ))
		ping( "\The [src] pings, \"[C.name] has transferred to [job_datum.title]!\"" )

		usage_record[user] = world.time
		return

	..()
