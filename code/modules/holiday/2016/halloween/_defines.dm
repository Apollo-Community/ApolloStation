var/list/pumpkin_starts = list()

/proc/anounceHalloween()
	var/input = sanitize("Looks like your gateway is acting up, It's running a one way portal to a distant location. Be cautious.")
	var/customname = sanitizeSafe("Gateway Anomaly Detected")

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()

	command_announcement.Announce(input, customname, new_sound = 'sound/AI/commandreport.ogg');