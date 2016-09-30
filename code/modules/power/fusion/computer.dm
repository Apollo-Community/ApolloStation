// Borrows code from cloning computer and gravity controll computer.
// Handles amost all user interaction with the fusion reactor.
/obj/machinery/computer/fusion
	name = "Tokamak Control Console"
	icon = 'icons/obj/fusion.dmi'
	icon_state = "computer"
	var/datum/fusion_controller/fusion_controller
	//var/obj/machinery/power/fusion/core/c
	var/ctag = ""

/obj/machinery/computer/fusion/New()
	fusion_controller = new()
	..()

/obj/machinery/computer/fusion/proc/reboot()
	fusion_controller = new()

/obj/machinery/computer/fusion/proc/updatemodules()
	var/tmp/obj/t_core = locate(ctag)
	if(isnull(t_core) || !istype(t_core, /obj/machinery/power/fusion/core))
		return
	if(fusion_controller.findComponents(t_core))
		fusion_controller.computer = src

/obj/machinery/computer/fusion/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/fusion/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	data["gas_temp"] = round(fusion_controller.gas_contents.temperature)
	data["gas_moles"] = round(fusion_controller.gas_contents.total_moles)
	data["nr_comp"] = fusion_controller.fusion_components.len
	data["gas"] = fusion_controller.gas
	data["rod_insert"] = round(fusion_controller.rod_insertion*100)
	data["fieldstrengh"] = round(fusion_controller.confield/400)
	data["conpower"] = fusion_controller.conPower
	data["heat_exchange"] = fusion_controller.heatpermability
	var/exchangers = 0
	for(var/obj/machinery/power/fusion/plasma/plasma in fusion_controller.plasma)
		if(!isnull(plasma.partner))
			exchangers ++
	data["exchangers"] = exchangers
	if(fusion_controller.fusion_components.len == 13)
		var/tmp/obj/machinery/power/fusion/core/c = fusion_controller.fusion_components[13]
		data["IDDpower"] = round(c.last_power/1000)
	else
		data["IDDpower"] = 0
	var/list/ring_list = list()
	if(fusion_controller)
		for(var/obj/machinery/power/fusion/ring_corner/ring in fusion_controller.fusion_components)
			ring_list += ring.integrity/10
	data["rings"] = ring_list
	// update the ui with data if it exists, returns null if no ui is passed/found or if force_open is 1/true
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	//nanomanager.update_uis(src)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "tokamak_computer.tmpl", "Tokamak Control Panel", 550, 800)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/fusion/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(isnull(fusion_controller))
		fusion_controller = new()

	if(stat & (BROKEN|NOPOWER))
		return

/*	var/dat = "<h3>Tokamak Control Panel</h3>"
	//dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>"
	if(fusion_controller.fusion_components.len != 13)
		dat += "<a href='byond://?src=\ref[src];findcomp=1'>Connect to reactor components.</a><br>"
	else
		var/obj/machinery/power/fusion/comp
		var/status
		dat += "Plasma Temperature: [isnull(fusion_controller.gas_contents) ? "No Gas" : "[fusion_controller.gas_contents.temperature]"]<br>"
		dat += "Plasma nr. Moles: [isnull(fusion_controller.gas_contents) ? "No Gas" : "[fusion_controller.gas_contents.total_moles]"] "
		if(fusion_controller.gas_contents.temperature < 50000)
			dat += "<a href='byond://?src=\ref[src];drain=1'><font color = red>Drain Gas</font></a><br>"
		else
			dat += "<a href='byond://?src=\ref[src];event=1'><font color = red>Emergency Gas Vent</font></a><br>"
		//Stuff for the confield percentage
		dat += "Containment field status: "
		dat += "[fusion_controller.confield/400]% "
		if(!fusion_controller.gas && fusion_controller.gas_contents.total_moles < 1)
			dat += "<a href='byond://?src=\ref[src];reset_field=1'>Reset</a>"
		//dat += "Containment field strengh: [fusion_controller.confield]<br>"
		dat += "<br>Neutron rods exposure: "
		dat += "<a href='byond://?src=\ref[src];change1=1'>--</a> "
		dat += "<a href='byond://?src=\ref[src];change2=1'>-</a>"
		dat += " [fusion_controller.rod_insertion*100] % "
		dat += "<a href='byond://?src=\ref[src];change3=1'>+</a> "
		dat += "<a href='byond://?src=\ref[src];change4=1'>++</a><br>"
		dat += "<b><center>Distribution Device Status</center></b><br>"
		comp = fusion_controller.fusion_components[13]
		status = comp.status()
		dat += status + "<br>"
		dat += "<br><b><center>Integrety status:</center></b>"
		comp = fusion_controller.fusion_components[1]
		status = comp.status()
		dat += "Ring 1: [status]<br>"
		comp = fusion_controller.fusion_components[4]
		status = comp.status()
		dat += "Ring 2: [status]<br>"
		comp = fusion_controller.fusion_components[7]
		status = comp.status()
		dat += "Ring 3: [status]<br>"
		comp = fusion_controller.fusion_components[10]
		status = comp.status()
		dat += "Ring 4: [status]<br>"
		dat += "Containmentfield Power: [fusion_controller.conPower==1 ? "Active" : "Inactive"] - "
		dat += "<a href='byond://?src=\ref[src];togglecon=1'>Toggle</a><br>"
		dat += "Gas release: [fusion_controller.gas==1 ? "Open" : "Closed"] -"
		dat += "<a href='byond://?src=\ref[src];togglegas=1'>Toggle</a><br>"
		var/exchangers = 0
		for(var/obj/machinery/power/fusion/plasma/plasma in fusion_controller.plasma)
			if(!isnull(plasma.partner))
				exchangers ++
		dat += "Thermal Containment: [fusion_controller.heatpermability==1 ? "Inactive" : "Active"] - "
		dat += "<a href='byond://?src=\ref[src];toggleheatperm=1'>Toggle</a><br>"
		dat += "Exchanging with: [exchangers] Heat exchangers. <br>"
	user << browse(dat, "window=fusiongen;size=600x750")
	*/
	ui_interact(user)
	//onclose(user, "fusiongen")


/obj/machinery/computer/fusion/Topic(href, href_list)
	..()
	if(href_list["reset_field"])
		fusion_controller.reset_field()
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
	if(href_list["drain"])
		fusion_controller.drainPlasma()
	if(href_list["change1"])
		fusion_controller.change_rod_insertion(-0.1)
	if(href_list["change2"])
		fusion_controller.change_rod_insertion(-0.01)
	if(href_list["change3"])
		fusion_controller.change_rod_insertion(0.01)
	if(href_list["change4"])
		fusion_controller.change_rod_insertion(0.1)
	nanomanager.update_uis(src)
	//src.updateUsrDialog()
	return 1

/obj/machinery/computer/fusion/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		ctag = input(user,"Input Heat Dispersion Device tag","Input Tag",null) as text|null
	..()