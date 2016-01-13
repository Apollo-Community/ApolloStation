/*
Alloy Synthesizer

Creates alloys that can be used to make stronger structures or more complex alloys.
*/

/obj/machinery/r_n_d/alloy_synth
	name = "alloy synthesizer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mechfab1"
	var/list/hoppers = list("base", "mineral")

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 5000

/obj/machinery/r_n_d/alloy_synth/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/alloy_synth(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)

/obj/machinery/r_n_d/alloy_synth/attackby(var/obj/O, var/mob/user)
	if(istype(O, /obj/item/weapon/screwdriver))
		if(!opened)
			opened = 1
			user << "You open the maintenance hatch of [src]."
		else
			opened = 0
			user << "You close the maintenance hatch of [src]."
		return 1
	if(opened && istype(O, /obj/item/weapon/crowbar))
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/I in component_parts)
			I.loc = src.loc
		qdel(src)
		return 1
	if(istype(O, /obj/item/stack/sheet/mineral) || istype(O, /obj/item/stack/sheet/glass) || istype(O, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/hopper_str = istype(O, /obj/item/stack/sheet/mineral) ? "mineral" : "base"
		var/obj/item/stack/sheet/hopper = hoppers[hopper_str]

		if(!isnull(hoppers[hopper_str]))
			if(!istype(O, hoppers[hopper_str]))
				user << "<span class='warning'>The [hopper_str] hopper is already loaded with [hopper]!</span>"
				return
			if(hopper.amount >= 50)
				user << "<span class='warning'>The [hopper_str] hopper of [src] is full!</span>"
				return

		var/obj/item/stack/sheet/S = O
		var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
		if(amount < 0)//No negative numbers
			amount = 0
		if(amount == 0)
			return
		if(amount > S.amount)
			amount = S.amount

		if(isnull(hoppers[hopper_str]))
			if(amount == S.amount)
				hoppers[hopper_str] = O
				user.drop_item()
				O.loc = src
			else
				hoppers[hopper_str] = S.split(amount)
		else
			S.transfer_to(hoppers[hopper_str], amount)

		user << "You add [O] to [src]."
		flick("mechfab2", src)
		spawn(10)
			busy = 0
		return 1
	else
		user << "\The [src] refuses \the [O]."
	return

/obj/machinery/r_n_d/alloy_synth/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/r_n_d/alloy_synth/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER)) return
	if(user.stat || user.restrained()) return
	var/obj/item/stack/sheet
		base = hoppers["base"]
		mineral = hoppers["mineral"]

	var/data[0]
	data["busy"] = busy ? 1 : 0
	data["base"] = base
	data["mineral"] = mineral

	data["base_name"] = isnull(base) ? "" : base.name
	data["mineral_name"] = isnull(mineral) ? "" : mineral.name
	data["base_amount"] = isnull(base) ? 0 : base.amount
	data["mineral_amount"] = isnull(mineral) ? 0 : mineral.amount

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "alloy_synth.tmpl", "Alloy Synthesizer", 440, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/r_n_d/alloy_synth/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	usr.set_machine(src)

	var/obj/item/stack/sheet
		base = hoppers["base"]
		mineral = hoppers["mineral"]

	if(href_list["eject_base"]) // eject base material
		base.loc = get_turf(src)
		hoppers["base"] = null
	else if(href_list["eject_mineral"]) // eject mineral
		mineral.loc = get_turf(src)
		hoppers["mineral"] = null
	else if(href_list["combine"]) // combine the base material and mineral
		busy = 1
		var/comp[0]
		comp[base.name] = base.amount
		comp[mineral.name] = mineral.amount
		flick("mechfab3", src)
		spawn(50)
			var/obj/item/stack/sheet/alloy/A = null
			var/obj/item/stack/sheet/mineral/M = mineral
			if(base.name == "metal")
				A = new /obj/item/stack/sheet/alloy/metal(comp)

				// >= 40% platinum is considered plasteel
				// can't do this in the alloy New() :(
				if(A.materials["platinum"] && A.materials["platinum"] >= 0.4)
					qdel(A)
					A = new /obj/item/stack/sheet/alloy/plasteel(comp)
			else
				A = new /obj/item/stack/sheet/alloy/glass(comp)
			A.effects = M.mineral_effect
			A.amount = base.amount
			A.loc = get_turf(src)
			A.update_icon()

			qdel(hoppers["base"])
			qdel(hoppers["mineral"])
			hoppers = list("base", "mineral")
			busy = 0
			updateUsrDialog()
	updateUsrDialog()
