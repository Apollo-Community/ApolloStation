/obj/machinery/tokamakFabricator
	name = "Tokamak Component Fabricator"
	desc = "A large automated factory for producing components and fuel for the Tokamak reacor."

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
	var/obj/item/weapon/tank/hydrogen/tank

/obj/machinery/tokamakFabricator/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/alloy_synth(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	var/datum/reagents/liquid = new(1000)
	var/datum/gas_mixture/gas_contents = new()

/obj/machinery/tokamakFabricator/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/tokamakFabricator/process()

	if(stat & NOPOWER)
		if(icon_state != "drone_fab_nopower") icon_state = "drone_fab_nopower"
		return
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
	if(opened && istype(O, /obj/item/weapon/crowbar))
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/I in component_parts)
			I.loc = src.loc
		qdel(src)
		return 1

	if(istype(O, /obj/item/stack/sheet/alloy))
		if(isnull(O)		//Something has gone wrong
			return
		if(!isnull(alloy))	//No alloy in the fab yet
			if((O.material[base]/O.material[mineral]) == 1)
				var/tmp/amount = min(round(input("How many sheets do you want to add?") as num), 25)
				user << "You add [amount] sheets to the fabricator"
				O.use(amount)
				alloy = new(O.material, O.mineral, O.base)
				alloy.amount = amount
				return
			else
				user << "<span class='warning'>The alloy does not have the right composition!</span>"
				return
		else				//Alloy in the fab
			if(alloy.amount >= 25)	//Fab is full
				user << "<span class='warning'>The fabricator is already full of [alloy]!</span>"
				return
			if(O.mineral == alloy.mineral && O.base == alloy.base)
				var/tmp/max = 25 - alloy.amount
				var/tmp/amount = min(round(input("How many sheets do you want to add?") as num), max)
				user << "You add [amount] sheets to the fabricator"
				O.use(amount)
				alloy.amount += amount
				return
	if(istype(O, /obj/item/weapon/reagent_containers))
		if(!O.reagents.has_reagent("water"))
			user << "<span class='warning'>No water detected in container!</span>"
			return
		var/tmp/max = 1000 - liquid.get_reagent_amount("water")
		var/tmp/amount = min(get_reagent_amount("water")
		liquid.add_reagent("water" , amount, safety = 1)
		O.reagents.remove_reagent("water", amount)
	..()

//Browser menu
/obj/machinery/tokamakFabricator/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	var/dat = "<h3>Tokamak Component Fabricator</h3><br>"
	dat += "Alloy: [!isnull(alloy) ? "[alloy].", "Alloy store empty."] <br>"
	dat += "Amount: [!isnull(alloy) ? "[alloy.amount].", "0"]<br>"
	dat += "Liquid: [!isnull(liquid) ? "[liquid.units].", "Liquid store empty"]<br>"
	if(!isnull(alloy)
		dat += "<a href='byond://?src=\ref[src];crystal=1'>Produce Field Crystal</a><br>"
		dat += "<a href='byond://?src=\ref[src];rod=1'>Produce Neutron Rod</a><br>"
	if(!isnull(liquid)
		dat += "<a href='byond://?src=\ref[src];liquid=1'>Electrolyze Liquid</a><br>"
	if(!isnull(tank)
		dat += "<a href='byond://?src=\ref[src];release=1'>Fill tank</a><br>"
	user << browse(dat, "window=tokamakfab;size=500x500")

//Topic by browser
/obj/machinery/tokamakFabricator/Topic(href, href_list)
	..()
	if(href_list["crystal"])
		produceCrystal()
	if(href_list["rod"])
		produceRod()
	if(href_list["liquid"])
		produceHydrogen()
	if(href_list["release"])
		fillTank()
	src.updateUsrDialog()

//produce a field crystal
/obj/machinery/tokamakFabricator/produceCrystal()
	if(alloy.base != "glass")
		usr << "<span class='warning'>Stored alloy is of the wrong base.</span>"
		return
	if(alloy.amount < 5)
		usr << "<span class='warning'>Not enough alloy in store.</span>"
		return
	alloy.use(5)
	var/obj/item/weapon/shieldCrystal/crystal = new(alloy.mineral)
	crystal.loc = get_turf(src)

//produce a neutron rod
/obj/machinery/tokamakFabricator/produceRod()
	if(alloy.base != "metal")
		usr << "<span class='warning'>Stored alloy is of the wrong base.</span>"
		return
	if(alloy.amount < 5)
		usr << "<span class='warning'>Not enough alloy in store..</span>"
		return
	alloy.use(5)
	var/obj/item/weapon/neutronRod/rod = new(alloy.mineral)
	rod.loc = get_turf(src)

//Produce hydrogen
/obj/machinery/tokamakFabricator/produceHydrogen()
	if(!liquid.has_reagent("water", 25)
		usr << "<span class='warning'>Not enough watter present in liquid stores.</span>"
		return
	reagent.remove_reagent("water", 25, 1)
	gas_contents.adjust_gas("hydrogen", 120)

//Fill present tank
/obj/machinery/tokamakFabricator/fillTank()
	if(gas_contents.total_moles < 10)
		usr << "<span class='warning'>Not enough hydrogen present in gass stores.</span>"
		return
	if(isnull(tank))
		usr << "<span class='warning'>No tank present to pump hydrogen into.</span>"
		return

