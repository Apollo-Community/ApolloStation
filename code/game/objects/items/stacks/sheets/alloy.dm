/* Alloys
 * Alloys have different properties depending on their composition
 * The "strength" of these properties depends on the metal/glass:mineral ratio
 * A 50/50 ratio gives full strength properties
 *
 * Mineral effects:
 * 		Diamond - Physically strengthens the alloy
 *		Uranium - The alloy emits radiation
 *		Phoron - Considerably increased heat resistance
 *		Gold
 *		Silver
 *		Iron - Weaker version of diamond
 *		Platinum
 *		Tritium
 *		Osmium
*/

var/list/prefix = list("diamond" = "ada", "uranium" = "ura", "solid phoron" = "phoro", "gold" = "dives", "silver" = "argent", "iron" = "ferro", "platinum" = "cata", "tritium" = "trit", "osmium" = "osi")
var/list/postfix = list("metal" = "metallic", "glass" = "glaseous")

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
	var/list/materials = list()

/obj/item/stack/sheet/alloy/New(var/list/comp)
	..()
	if(!comp)
		usr << "<span class='warning'>This should never appear. There HAS to be a composition list!</span>"
		return
	materials = comp
	var/pre = ""
	var/post = ""
	var/sum = 0
	for(var/M in comp)
		sum += comp[M]
		if(prefix[M])
			pre = prefix[M]
		else
			post = postfix[M]
	name = "[pre][post] alloy"
	for(var/M in materials)
		materials[M] /= sum
		stacktype += "[M][materials[M]]"

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
	stack.stacktype = stacktype
	stack.name = name
	return stack

/obj/item/stack/sheet/alloy/transfer_to(obj/item/stack/S, var/tamount)
	var/obj/item/stack/sheet/alloy/stack = ..(S, tamount)
	stack.materials = materials.Copy()
	stack.stacktype = stacktype
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