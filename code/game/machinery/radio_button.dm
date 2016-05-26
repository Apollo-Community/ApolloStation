obj/machinery/radio_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "radio signal button"

	anchored = 1
	power_channel = ENVIRON

	var/code = 30
	var/frequency = 1457
	var/master_tag
	var/command = "cycle"
	var/datum/radio_frequency/radio_connection
	var/on = 1

obj/machinery/radio_button/initialize()
	set_frequency(frequency)

obj/machinery/radio_button/New()
	..()
	if(radio_controller)
		set_frequency(frequency)

obj/machinery/radio_button/update_icon()
	if(on)
		icon_state = "access_button_standby"
	else
		icon_state = "access_button_off"

obj/machinery/radio_button/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/device/multitool))
		var/new_freq = input("Set button signal frequentie", "Button frequentie", frequency) as num|null
		var/new_code = input("Set button signal code", "Signal code", code) as num|null
		if(new_freq != frequency)
			set_frequency(new_freq)
		if(new_code != code)
			set_code(new_code)
		return

	//Swiping ID on the access button
	if (istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda))
		attack_hand(user)
		return
	..()

obj/machinery/radio_button/attack_hand(mob/user)
	add_fingerprint(usr)
	if(!allowed(user))
		user << "<span class='alert'>Access Denied</span>"

	else if(radio_connection)
		var/datum/signal/signal = new
		signal.source = src
		signal.encryption = code
		signal.data["message"] = "ACTIVATE"
		radio_connection.post_signal(src, signal)
	flick("access_button_cycle", src)

obj/machinery/radio_button/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)

obj/machinery/radio_button/proc/set_code(var/new_code = 30)
	code = new_code

obj/machinery/radio_button/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	..()

/*
RADIO BUTTON FRAME ITEM
Handheld radio button, for placing on walls
Code shamelessly copied from firealarm_frame
*/
/obj/item/radio_button_frame
	name = "radio button frame"
	desc = "Used for building radio buttons"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	flags = CONDUCT

/obj/item/radio_button_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		qdel(src)
		return
	..()

/obj/item/radio_button_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf(usr)
	if (!istype(loc, /turf/simulated/floor))
		usr << "<span class='alert'>Radio button can not be placed on this spot.</span>"
		return

	if(gotwallitem(loc, ndir))
		usr << "<span class='alert'>There's already an item on this wall!</span>"
		return

	new /obj/machinery/radio_button(loc, ndir, 1)

	qdel(src)