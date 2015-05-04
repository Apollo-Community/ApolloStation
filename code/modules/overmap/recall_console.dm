// ========= SHUTTLE RECALL CONSOLE =========

/obj/machinery/computer/pod_recall
	name = "Pod Recall"
	desc = "A console used to recall shuttles that are off-structure."
	icon_state = "shuttle"
	use_power = 0
	var/obj/spacepod/target = null
	var/target_name = null
	var/obj/machinery/gate_beacon/beacon = null
	var/beacon_name = null
	var/active = 0
	var/charge = 0
	var/charge_rate = 50
	var/max_charge = 300 // how high of a charge it needs to bring the shuttle back

/obj/machinery/computer/pod_recall/New()
	..()

	if( target_name ) // finding that troublesome pod that always runs off
		spawn( 30 )
			for( var/spacepod in spacepods_list )
				var/obj/spacepod/pod = spacepod
				if( target_name == pod.name )
					target = pod
					break

	if( beacon_name ) // getting our friendly neighborhood beacon
		spawn( 30 )
			beacon = bluespace_beacons["[beacon_name]"]

/obj/machinery/computer/pod_recall/attack_hand(var/mob/user as mob)
	recall_prompt( user )

	..()

/obj/machinery/computer/pod_recall/process()
	if( active )
		if( !beacon )
			processing_objects.Remove( src )
		if( !target )
			processing_objects.Remove( src )

		if( src.charge >= src.max_charge )
			new /obj/machinery/singularity/bluespace_gate/( src.target.loc, src.beacon.loc )
			src.charge = 0
			src.active = 0
		else
			src.charge += src.charge_rate

/obj/machinery/computer/pod_recall/proc/recall_prompt( var/mob/user = usr )
	if( !beacon )
		ping("[src] states, \"ERROR: No local beacon set!\"")
	if( !target )
		ping("[src] states, \"ERROR: No pod linked!\"")

	if( alert(usr, "Would you like recall [target]? \nWARNING: Do not recall the shuttle if it is inside a structure.", "Recall Shuttle", "Yes", "No") == "Yes")
		ping("[src] states, \"Recalling [target] to [beacon]\"")
		target.occupants_announce("Shuttle being recalled by [src]. Prepare for travel through a bluespace gate.")
		active = 1
