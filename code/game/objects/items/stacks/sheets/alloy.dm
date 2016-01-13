/* Alloys
 * Alloys have different properties depending on their composition
 * The "strength" of these properties depends on the metal/glass:mineral ratio, as well as the mineral
 * A 50/50 ratio gives full strength properties
 *
 * Mineral sheets have a list of effects. This is a list of all used effects. Most are multipliers
 * These multipliers are only used in full in a 50:50 alloy. So a mineral with str = 3 in a 30:80 alloy would give a multiplier of 2.25, not 3.
 * 		rot - determines chance of wallrot appearing. 1 gives full immunity. UNUSED so far
 *		str - determines wall strength/damage cap, this is a multiplier for an ADDITION to the damage cap, not a multiplier to the damage cap itself. 0.5 = 50% higher cap
 *		blastarmor - determines resistance against explosions
 *		rad - how much radiation the alloy sends out
 *		tempres - determines maximum temperature
 *		acidres - 1 or 0, determines whether or not the alloy resists acid
 *		projarmor - damage reduction (or increase) from projectiles
*/

/*
 * Alloy sheet
*/
/obj/item/stack/sheet/alloy
	name = "alloy"
	desc = "Synthesized alloys with special properties."
	singular_name = "alloy sheet"
	icon = 'icons/obj/items/materials.dmi'
	icon_state = "polysteel-1"
	item_state = "polysteel"
	origin_tech = "materials=3"

	var/list/materials = list()
	var/unique_id = ""
	var/list/effects = list()

/obj/item/stack/sheet/alloy/New(var/list/comp)
	..()
	if(!comp)
		usr << "<span class='warning'>This should never appear. There HAS to be a composition list!</span>"
		return

	materials = comp.Copy()

	var/pre = ""
	var/post = ""
	var/sum = 0
	for(var/M in materials)
		sum += materials[M]
		if(alloy_prefix[M])
			pre = alloy_prefix[M]
		else
			post = alloy_postfix[M]
	name = "[pre][post] alloy"
	singular_name = "[name] sheet"

	for(var/M in materials)
		materials[M] /= sum
		unique_id += "[M][materials[M]]"

/obj/item/stack/sheet/alloy/update_icon()
	switch(amount)
		if(1)
			icon_state = "[item_state]-1"
		if(2 to 16)
			icon_state = "[item_state]-2"
		if(17 to 32)
			icon_state = "[item_state]-3"
		if(33 to 49)
			icon_state = "[item_state]-4"
		else
			icon_state = "[item_state]-5"

// so that the alloy doesn't lose its properties
/obj/item/stack/sheet/alloy/split(var/tamount)
	var/obj/item/stack/sheet/alloy/stack = ..(tamount)
	stack.materials = materials.Copy()
	stack.unique_id = unique_id
	stack.name = name
	return stack

/obj/item/stack/sheet/alloy/transfer_to(obj/item/stack/S, var/tamount)
	var/obj/item/stack/sheet/alloy/stack = ..(S, tamount)
	stack.materials = materials.Copy()
	stack.unique_id = unique_id
	stack.name = name
	return stack

/*
 * Metal alloy
*/
/obj/item/stack/sheet/alloy/metal
	name = "metal alloy"
	desc = "Synthesized alloys of metal with special properties."
	singular name = "metal alloy sheet"

/*
 * Glass alloy
*/
/obj/item/stack/sheet/alloy/glass
	name = "glass alloy"
	desc = "Synthesized alloys of glass with special properties."
	singular name = "glass alloy sheet"
	icon_state = "polyglass-1"
	item_state = "polyglass"

/*
 * Catametallic alloy (new plasteel)
*/

/obj/item/stack/sheet/alloy/plasteel
	name = "catametallic alloy"
	desc = "Rich alloys made of platinum and metal, often refered to as \"plasteel\""
	icon_state = "plasteel-1"
	item_state = "plasteel"
	origin_tech = "materials=2" // plasteel gets a lower tech level because it's very common & accessible already
	flags = CONDUCT

	recipes = list(new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("RUST fuel assembly port frame", /obj/item/rust_fuel_assembly_port_frame, 12, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("RUST fuel compressor frame", /obj/item/rust_fuel_compressor_frame, 12, time = 50, one_per_turf = 1), \
	new/datum/stack_recipe("knife grip", /obj/item/butterflyhandle, 4, time = 20, one_per_turf = 0, on_floor = 1))

/obj/item/stack/sheet/alloy/plasteel/New(var/list/comp)
	if(!comp || !istype(comp))
		comp = list("platinum" = 0.5, "metal" = 0.5)
	..(comp)
