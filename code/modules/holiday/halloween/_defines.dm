var/list/pumpkin_starts = list()

/proc/anounceHalloween()
	var/input = sanitize("We have detected a nuclear burst on a nearby moon. Any available personnel are requested to investigate.")
	var/customname = sanitizeSafe("Radar Anomaly Detected")

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()

	command_announcement.Announce(input, customname, new_sound = 'sound/AI/commandreport.ogg');