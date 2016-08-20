// Borrows code from cloning computer and gravity controll computer.
// Handles amost all user interaction with the fusion reactor.
/obj/machinery/computer/fusion
	icon = 'icons/obj/fusion.dmi'
	icon_state = "computer"
/obj/machinery/computer/fusion/New()
	..()

/obj/machinery/computer/fusion/proc/updatemodules()
	if(fusion_controller.findComponents())
		fusion_controller.addComp(src)
		return 1
	return 0

/obj/machinery/computer/fusion/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/fusion/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	var/dat = "<h3>Tokamak Control Panel</h3>"
	//dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>"
	if(!updatemodules())
		dat += "<a href='byond://?src=\ref[src];findcomp=1'>Connect to reactor components.</a><br>"
	else
	//font color=green
		var/obj/machinery/power/fusion/comp
		var/status
		dat += "Plasma Temperature: [isnull(fusion_controller.gas_contents) ? "No Gas" : "[fusion_controller.gas_contents.temperature]"]<br>"
		dat += "Plasma nr. Moles: [isnull(fusion_controller.gas_contents) ? "No Gas" : "[fusion_controller.gas_contents.total_moles]"]<br>"
		var/exchangers = 0
		for(var/obj/machinery/power/fusion/plasma/plasma in fusion_controller.plasma)
			if(!isnull(plasma.partner))
				exchangers ++
		dat += "Thermal Containment: [fusion_controller.heatpermability==1 ? "Inactive" : "Active"] - "
		dat += "<a href='byond://?src=\ref[src];toggleheatperm=1'>Toggle</a><br>"
		dat += "Exchanging with: [exchangers] Heat exchangers. <br>"
		dat += "<a href='byond://?src=\ref[src];event=1'><font color = red>Emergency Gas Vent</font></a><br>"
		dat += "<b><center>Dispertion Rod Status:</center></b><br>"
		comp = fusion_controller.fusion_components[13]
		status = comp.status()
		dat += status + "<br>"
		dat += "<br><b><center>MCR status:</center></b>"
		comp = fusion_controller.fusion_components[1]
		status = comp.status()
		dat += "Ring 1:<br>[status]<br>"
		comp = fusion_controller.fusion_components[4]
		status = comp.status()
		dat += "Ring 2:<br>[status]<br>"
		comp = fusion_controller.fusion_components[7]
		status = comp.status()
		dat += "Ring 3:<br>[status]<br>"
		comp = fusion_controller.fusion_components[10]
		status = comp.status()
		dat += "Ring 4:<br>[status]<br>"
		dat += "Containmentfield Power: [fusion_controller.conPower==1 ? "Active" : "Inactive"] - "
		dat += "<a href='byond://?src=\ref[src];togglecon=1'>Toggle</a><br>"
		dat += "Gas release: [fusion_controller.gas==1 ? "Open" : "Closed"] -"
		dat += "<a href='byond://?src=\ref[src];togglegas=1'>Toggle</a><br>"
	user << browse(dat, "window=fusiongen;size=600x750")
	//onclose(user, "fusiongen")


/obj/machinery/computer/fusion/Topic(href, href_list)
	..()
	if(href_list["togglecon"])
		fusion_controller.toggle_field()
	if(href_list["togglegas"])
		fusion_controller.toggle_gas()
	if(href_list["findcomp"])
		updatemodules()
	if(href_list["toggleheatperm"])
		fusion_controller.toggle_permability()
	if(href_list["event"])
		spawn(0)
			if(alert("Confrim Emergency Venting",,"Yes", "No") == "Yes")
				fusion_controller.emergencyVent()
	src.updateUsrDialog()
	return