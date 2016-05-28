//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	use_power = 1
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/opened = 0
	var/sabotaged = 0
	var/obj/machinery/computer/rdconsole/linked_console
	var/datum/wires/r_n_d/wires = null


/obj/machinery/r_n_d/New()
	..()
	wires = new(src)

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if(shocked)
		shock(user,50)
	if(panel_open == 1)
		wires.Interact(user)
	return
