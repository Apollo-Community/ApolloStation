
//frame assembly

/obj/item/rust_fuel_assembly_port_frame
	name = "Fuel Assembly Port frame"
	icon = 'icons/rust.dmi'
	icon_state = "port2"
	w_class = 4
	flags = CONDUCT

/obj/item/rust_fuel_assembly_port_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/alloy/plasteel( get_turf(src.loc), 12 )
		qdel(src)
		return
	..()

/obj/item/rust_fuel_assembly_port_frame/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "<span class='alert'>Port cannot be placed on this spot.</span>"
		return
	if (A.requires_power == 0 || A.name == "Space")
		usr << "<span class='alert'>Port cannot be placed in this area.</span>"
		return
	new /obj/machinery/rust_fuel_assembly_port(loc, ndir, 1)
	qdel(src)

//construction steps
/obj/machinery/rust_fuel_assembly_port/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		set_dir(ndir)
	else
		has_electronics = 3
		opened = 0
		icon_state = "port0"

	//20% easier to read than apc code
	pixel_x = (dir & 3)? 0 : (dir == 4 ? 32 : -32)
	pixel_y = (dir & 3)? (dir ==1 ? 32 : -32) : 0

/obj/machinery/rust_fuel_assembly_port/attackby(obj/item/W, mob/user)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (istype(W, /obj/item/weapon/crowbar))
		if(opened)
			if(has_electronics & 1)
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "You begin removing the circuitboard" //lpeters - fixed grammar issues
				if(do_after(user, 50))
					user.visible_message(\
						"<span class='alert'>[user.name] has removed the circuitboard from [src.name]!</span>",\
						"<span class='notice'>You remove the circuitboard.</span>")
					has_electronics = 0
					new /obj/item/weapon/module/rust_fuel_port(loc)
					has_electronics &= ~1
			else
				opened = 0
				icon_state = "port0"
				user << "<span class='notice'>You close the maintenance cover.</span>"
		else
			if(cur_assembly)
				user << "<span class='alert'>You cannot open the cover while there is a fuel assembly inside.</span>"
			else
				opened = 1
				user << "<span class='notice'>You open the maintenance cover.</span>"
				icon_state = "port2"
		return

	else if (istype(W, /obj/item/stack/cable_coil) && opened && !(has_electronics & 2))
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 10)
			user << "<span class='alert'>You need more wires.</span>"
			return
		user << "You start adding cables to the frame..."
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 20) && C.amount >= 10)
			C.use(10)
			user.visible_message(\
				"<span class='alert'>[user.name] has added cables to the port frame!</span>",\
				"You add cables to the port frame.")
			has_electronics &= 2
		return

	else if (istype(W, /obj/item/weapon/wirecutters) && opened && (has_electronics & 2))
		user << "You begin to cut the cables..."
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 50))
			new /obj/item/stack/cable_coil(loc,10)
			user.visible_message(\
				"<span class='alert'>[user.name] cut the cabling inside the port.</span>",\
				"You cut the cabling inside the port.")
			has_electronics &= ~2
		return

	else if (istype(W, /obj/item/weapon/module/rust_fuel_port) && opened && !(has_electronics & 1))
		user << "You trying to insert the port control board into the frame..."
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, 10))
			has_electronics &= 1
			user << "You place the port control board inside the frame."
			qdel(W)
		return

	else if (istype(W, /obj/item/weapon/weldingtool) && opened && !has_electronics)
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.get_fuel() < 3)
			user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
			return
		user << "You start welding the port frame..."
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(do_after(user, 50))
			if(!src || !WT.remove_fuel(3, user)) return
			new /obj/item/rust_fuel_assembly_port_frame(loc)
			user.visible_message(\
				"<span class='alert'>[src] has been cut away from the wall by [user.name].</span>",\
				"You detached the port frame.",\
				"<span class='alert'>You hear welding.</span>")
			qdel(src)
		return

	..()
