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
	if(isnull(fusion_controller.confield) || isnull(fusion_controller.max_field) || fusion_controller.confield == 0 || fusion_controller.max_field == 0)
		data["fieldstrengh"] = 0
	else
		data["fieldstrengh"] = round(fusion_controller.confield/(fusion_controller.max_field/100))
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

	ui_interact(user)

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
	return 1

/obj/machinery/computer/fusion/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		ctag = input(user,"Input Heat Dispersion Device tag","Input Tag",null) as text|null
	..()