var/list/decoration_starts = list()

/proc/anounceChristmas()
	var/input = sanitize("A pine tree has mysteriously appeared in the arrivals foyer, and small baubles have appeared around the station. Please investigate.")
	var/customname = sanitizeSafe("AUTOMATED ALERT: Bluespace Anomalies")

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()

	command_announcement.Announce(input, customname, new_sound = 'sound/AI/commandreport.ogg');
