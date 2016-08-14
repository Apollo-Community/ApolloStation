// Borrows code from cloning computer and gravity controll computer.
// Handles amost all user interaction with the fusion reactor.
/obj/machinery/computer/fusion

/obj/machinery/computer/fusion/New()
	..()

/obj/machinery/computer/fusion/proc/updatemodules()
	if(fusion_controller.findComponents())
		fusion_controller.fusion_components.Add(src)

/obj/machinery/computer/fusion/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/fusion/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()
	var/dat = "<h3>Tokamak Controll Panel</h3>"
	//dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>"
	if(fusion_controller.fusion_components.len < 5)
		dat += "<a href='byond://?src=\ref[src];findcomp=1'><font color=green> Connect to reactor components. </font></a>"
	else
	//font color=green
		dat += "<center>MCU status:</center><br>"
		dat += "Unit 1 - [fusion_components[1].status()]"
		dat += "Unit 2 - [fusion_components[2].status()]"
		dat += "Unit 3 - [fusion_components[3].status()]"
		dat += "Unit 4 - [fusion_components[4].status()]"
	user << browse(dat, "window=fusiongen")
	//onclose(user, "fusiongen")


/obj/machinery/computer/fusion/Topic(href, href_list)
	..()

	if(href_list["gentoggle"])
		if(gravity_generator:on)
			gravity_generator:on = 0

			for(var/area/A in gravity_generator:localareas)
				var/obj/machinery/gravity_generator/G
				for(G in machines)
					if((A in G.localareas) && (G.on))
						break
				if(!G)
					A.gravitychange(0,A)


		else
			for(var/area/A in gravity_generator:localareas)
				gravity_generator:on = 1
				A.gravitychange(1,A)

		src.updateUsrDialog()
		return