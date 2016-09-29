/obj/machinery/tokamakFabricator
	name = "Tokamak Component Fabricator"
	desc = "A large automated factory for producing components for the Tokamak reacor."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000

	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/obj/item/stack/sheet/alloy/alloy
	var/datum/reagents/liquid
	var/datum/gas_mixture/gas_contents
	var/obj/item/weapon/tank

/obj/machinery/tokamakFabricator/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/alloy_synth(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)

/obj/machinery/tokamakFabricator/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/tokamakFabricator/process()
	if(stat & NOPOWER)
		if(icon_state != "drone_fab_nopower")
			icon_state = "drone_fab_nopower"
/*
	if()
		icon_state = "drone_fab_idle"
		return

	icon_state = "drone_fab_active"
*/
/obj/machinery/tokamakFabricator/attackby(var/obj/O, var/mob/user)
	if(istype(O, /obj/item/weapon/screwdriver))
		if(!panel_open)
			panel_open = 1
			user << "You open the maintenance hatch of [src]."
		else
			panel_open = 0
			user << "You close the maintenance hatch of [src]."
		return 1
	if(panel_open && istype(O, /obj/item/weapon/crowbar))
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/I in component_parts)
			I.loc = src.loc
		qdel(src)
		return 1

	if(istype(O, /obj/item/stack/sheet/alloy))
		var/tmp/obj/item/stack/sheet/alloy/A = O
		if(isnull(O))		//Something has gone wrong
			return
		if(isnull(alloy))	//No alloy in the fab yet
			if((A.materials[A.base]/A.materials[A.mineral]) == 1)
				var/tmp/amount = min(round(input("How many sheets do you want to add?") as num), 25)
				user << "You add [amount] sheets to the fabricator"
				A.use(amount)
				alloy = new(A.materials, A.mineral, A.base)
				alloy.amount = amount
				return
			else
				user << "<span class='warning'>The alloy does not have the right composition!</span>"
				return
		else				//Alloy in the fab
			if(alloy.amount >= 25)	//Fab is full
				user << "<span class='warning'>The fabricator is already full of [alloy]!</span>"
				return
			if(A.mineral == alloy.mineral && A.base == alloy.base)
				var/tmp/max = 25 - alloy.amount
				var/tmp/amount = min(round(input("How many sheets do you want to add?") as num), max)
				user << "You add [amount] sheets to the fabricator"
				A.use(amount)
				alloy.amount += amount
				return
	..()

//Browser menu
/obj/machinery/tokamakFabricator/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	var/dat = "<h3>Tokamak Component Fabricator</h3><br>"
	dat += "Alloy: [!isnull(alloy) ? "[alloy].":"Alloy store empty."] <br>"
	dat += "Amount: [!isnull(alloy) ? "[alloy.amount].":"0"]<br>"
	if(!isnull(alloy))
		dat += "<a href='byond://?src=\ref[src];crystal=1'>Produce Field Crystal</a><br>"
		dat += "<a href='byond://?src=\ref[src];rod=1'>Produce Neutron Rod</a><br>"
		dat += "<a href='byond://?src=\ref[src];eject=1'>Eject Alloy</a><br>"
	user << browse(dat, "window=tokamakfab;size=500x500")

//Topic by browser
/obj/machinery/tokamakFabricator/Topic(href, href_list)
	..()
	if(usr.machine != src)
		message_admins("Tokamak Fabricator href hacks in progress by [usr] ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	if(href_list["crystal"])
		produceCrystal()
	if(href_list["rod"])
		produceRod()
	if(href_list["eject"])
		ejectAlloy()
	src.updateUsrDialog()

//produce a field crystal
/obj/machinery/tokamakFabricator/proc/produceCrystal()
	if(alloy.base != "glass")
		usr << "<span class='warning'>Stored alloy is of the wrong base.</span>"
		return
	if(alloy.amount < 5)
		usr << "<span class='warning'>Not enough alloy in store.</span>"
		return
	alloy.use(5)
	var/obj/item/weapon/shieldCrystal/crystal = new(alloy.mineral)
	crystal.loc = get_turf(get_step(src, EAST))

//produce a neutron rod
/obj/machinery/tokamakFabricator/proc/produceRod()
	if(alloy.base != "metal")
		usr << "<span class='warning'>Stored alloy is of the wrong base.</span>"
		return
	if(alloy.amount < 5)
		usr << "<span class='warning'>Not enough alloy in store..</span>"
		return
	alloy.use(5)
	var/obj/item/weapon/neutronRod/rod = new(alloy.mineral)
	rod.loc = get_turf(get_step(src, EAST))

//Eject alloy from the machine
/obj/machinery/tokamakFabricator/proc/ejectAlloy()
	if(alloy.amount = 0)
		usr << "<span class='warning'>Nothing to be ejected.</span>"
		return
	var/amount_ejected = alloy.amount
	alloy.use(alloy.amount)
	alloy = new()
	var/tmp/obj/item/stack/sheet/alloy/ejected = alloy
	ejected.loc = get_turf(usr)
	ejected.amount = amount_ejected
	alloy = null