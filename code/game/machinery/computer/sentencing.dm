/obj/machinery/computer/employment
	name = "criminal sentencing console"
	desc = "Used to generate a criminal sentence."
	icon_state = "sentence"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = "/obj/item/weapon/circuitboard/sentencing"

/obj/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"


	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "sentencing_computer.tmpl", src.name, 600, 700)
		ui.set_initial_data(data)
		ui.open()
