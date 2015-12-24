var/list/decoration_starts = list()

/proc/anounceChristmas()
	var/input = sanitize("A christmas tree has been installed in the arrivals foyer. Add some decorations to boost crew moral, complient crew will be rewarded.")
	var/customname = sanitizeSafe("Christmas Tree")

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()

	command_announcement.Announce(input, customname, new_sound = 'sound/AI/commandreport.ogg');
