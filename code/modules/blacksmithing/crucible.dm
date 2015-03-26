/*

	crucible  - Simple machine used to add small pieces of metal together to create a bar of metal.

*/

/obj/machinery/crucible
	name = "Crucible"
	desc = "A large crucible with an ignot mould attached."
	icon = 'icons/obj/machines/weapon_lab.dmi'
	icon_state = "crucible_empty"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	var/on = 0
	var/metal_amount = 0


/obj/machinery/crucible/examine()
	..()
	if(on)
		usr << "\blue An ignot mould is currently filling!"
	else
		switch(metal_amount)
			if(0 to 100)		usr << "\blue It doesn't look like there is much metal inside."
			if(100 to 250)		usr << "\blue It looks like there is around half an ignot of metal inside"
			if(250 to 450)		usr << "\blue It looks like I need just a little bit more metal to make an ignot"
			else				usr << "\blue There's <b>loads</b> of metal in there!"

/obj/machinery/crucible/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/tongs))
		if(on)
			usr << "\blue You should wait until the mould has been cast before doing this!"
			return
		var/obj/item/weapon/tongs/W = I

		if(W.held)		//if there is an object inside the tongs

			//now we've established the item inside the tongs is definately a superheated metal
			var/obj/item/forge/heated_metal/S = W.held

			if(S.temperature >= T20C+380)				//If the bar is > 400c you get a bonus for being a good lil' blacksmith
				usr << "\blue You put [S.name] into the [src.name]."
				spawn(rand(70))
					usr << "\blue [S.name] melts and begins to bubble away in the [src.name]"
					metal_amount += (S.matter["metal"] * 1.04)		//slightly more efficient to make ignots
			else if(S.temperature >= T20C+40)
				usr << "\blue You put [S.name] into the [src.name]."
				spawn(rand(70))
					usr << "\blue [S.name] slowly melts and begins to bubble away in the [src.name]"
					metal_amount += (S.matter["metal"] * 0.95)
			else
				usr << "\blue You don't think the bar is hot enough to melt properly."
				return

			W.held = null
			W.icon_state = "tongs"

			spawn(70)
				if(metal_amount > 300)
					icon_state = "crucible_filled"

/obj/machinery/crucible/attack_hand(var/mob/user as mob)
	//Opens the tap - spawns a ignot
	if(metal_amount >= 450)
		metal_amount -= 450
		usr << "\blue You open the tap on the [src.name] and molten metal begins to flow into the mould."
		icon_state = "crucible_pour"
		var/obj/item/forge/heated_metal/ignot/S = new()
		S.temperature = (T0C+1000)+rand(500)
		spawn(40)
			usr << "\blue You close the tap on the [src.name]"
			if(metal_amount > 300)
				icon_state = "crucible_filled"
			else
				icon_state = "crucible_empty"
		spawn(80)
			S.loc = get_turf(src)
			S.color = "#FF704D"

		spawn(200)		S.color = null
		return
	else
		usr << "\red It does not look like you have enough metal in the [src.name] to make an ignot."



