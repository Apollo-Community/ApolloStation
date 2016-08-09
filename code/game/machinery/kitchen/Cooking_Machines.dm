
/obj/machinery/cooking_machines
	icon = 'icons/obj/kitchen.dmi'
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = OPENCONTAINER | NOREACT
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items // List of the items you can put in
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/global/max_n_of_items = 0
	var/image/cookimg
	var/machinetype
	var/icontype

/obj/machinery/cooking_machines/microwave
	name = "Microwave"
	icon_state = "mw"
	machinetype = "microwave"
	icontype = "mw"

/obj/machinery/cooking_machines/grill
	name = "Grill"
	icon_state = "gr"
	machinetype = "grill"
	icontype = "gr"

/obj/machinery/cooking_machines/oven
	name = "Oven"
	icon_state = "ov"
	machinetype = "oven"
	icontype = "ov"

/obj/machinery/cooking_machines/pot
	name = "Cooking Pot"
	icon_state = "pt"
	machinetype = "pot"
	icontype = "pt"

// see code/modules/food/recipes_cooking_machines.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/cooking_machines/New()
	..()
	reagents = new/datum/reagents(100)
	reagents.my_atom = src
	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe)-/datum/recipe))
			available_recipes+= new type
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if (recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.items.len)

		// This will do until I can think of a fun recipe to use dionaea in -
		// will also allow anything using the holder item to be cooking_machines'd into
		// impure carbon. ~Z
		acceptable_items |= /obj/item/weapon/holder

/*******************
*   Item Adding
********************/

/obj/machinery/cooking_machines/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(operating)	return 		//stops people doing stuff while the cooking_machines is active

	if(broken > 0)
		if(broken == 2 && istype(O, /obj/item/weapon/screwdriver)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [machinetype].</span>", \
				"<span class='notice'>You start to fix part of the [machinetype].</span>" \
			)
			if (do_after(user,20))
				user.visible_message( \
					"<span class='notice'>[user] fixes part of the [machinetype].</span>", \
					"<span class='notice'>You have fixed part of the [machinetype].</span>" \
				)
				broken = 1 // Fix it a bit
		else if(broken == 1 && istype(O, /obj/item/weapon/wrench)) // If it's broken and they're doing the wrench
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [machinetype].</span>", \
				"<span class='notice'>You start to fix part of the [machinetype].</span>" \
			)
			if (do_after(user,20))
				user.visible_message( \
					"<span class='notice'>[user] fixes the [machinetype].</span>", \
					"<span class='notice'>You have fixed the [machinetype].</span>" \
				)
				icon_state = "mw"
				broken = 0 // Fix it!
				dirty = 0 // just to be sure
				flags = OPENCONTAINER
		else
			user << "<span class='alert'>It's broken!</span>"
			return 1
	else if( istype( O, /obj/item/weapon/wrench ))
		if( anchored )
			user.visible_message( \
				"<span class='notice'>[user] unwrenches the securing bolts from the [machinetype].</span>", \
				"<span class='notice'>You have unwrenched the securing bolts from the [machinetype].</span>" \
			)

			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 0
		else
			user.visible_message( \
				"<span class='notice'>[user] secures the bolts on the [machinetype].</span>", \
				"<span class='notice'>You have secured the bolts on the [machinetype].</span>" \
			)

			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 1
	else if(dirty==100) // The cooking_machines is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/reagent_containers/spray/cleaner)) // If they're trying to clean it then let them
			user.visible_message( \
				"<span class='notice'>[user] starts to clean the [machinetype].</span>", \
				"<span class='notice'>You start to clean the [machinetype].</span>" \
			)
			if (do_after(user,20))
				user.visible_message( \
					"<span class='notice'>[user]  has cleaned  the [machinetype].</span>", \
					"<span class='notice'>You have cleaned the [machinetype].</span>" \
				)
				dirty = 0 // It's clean!
				broken = 0 // just to be sure
				icon_state = "mw"
				flags = OPENCONTAINER
		else //Otherwise bad luck!!
			user << "<span class='alert'>It's dirty!</span>"
			return 1
	else if(is_type_in_list(O,acceptable_items))
		if (contents.len>=max_n_of_items)
			user << "<span class='alert'>This [src] is full of ingredients, you cannot put more.</span>"
			return 1
		if(istype(O, /obj/item/stack) && O:get_amount() > 1) // This is bad, but I can't think of how to change it
			var/obj/item/stack/S = O
			new O.type (src)
			S.use(1)
			user.visible_message( \
				"<span class='notice'>[user] has added one of [O] to \the [src].</span>", \
				"<span class='notice'>You add one of [O] to \the [src].</span>")
			if(machinetype == "grill")
				cookimg = new(O.icon, O.icon_state)
				//cookimg.pixel_y = 5
				overlays += cookimg
		else
		//	user.before_take_item(O)	//This just causes problems so far as I can tell. -Pete
			user.drop_item()
			O.loc = src
			user.visible_message( \
				"<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
				"<span class='notice'>You add \the [O] to \the [src].</span>")
			if(machinetype == "grill")
				cookimg = new(O.icon, O.icon_state)
				//cookimg.pixel_y = 5
				overlays += cookimg
	else if(istype(O,/obj/item/weapon/reagent_containers/glass) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/drinks) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/condiment) \
		)
		if (!O.reagents)
			return 1
		for (var/datum/reagent/R in O.reagents.reagent_list)
			if (!(R.id in acceptable_reagents))
				user << "<span class='alert'>Your [O] contains components unsuitable for cookery.</span>"
				return 1
		//G.reagents.trans_to(src,G.amount_per_transfer_from_this)
	else if(istype(O,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		user << "<span class='alert'>This is ridiculous. You can not fit \the [G.affecting] in this [src].</span>"
		return 1
	else
		user << "<span class='alert'>You have no idea what you can cook with this [O].</span>"
		return 1
	updateUsrDialog()

/obj/machinery/cooking_machines/attack_ai(mob/user as mob)
	return 0

/obj/machinery/cooking_machines/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/**********************
*cooking_machines Menu
**********************/

/obj/machinery/cooking_machines/interact(mob/user as mob) // The cooking_machines Menu
	var/dat = "<div class='statusDisplay'>"
	if(broken > 0)
		dat += "ERROR: 09734014-A2379-D18746 --Bad memory<BR>Contact your operator or use command line to rebase memory ///git checkout {HEAD} -a commit pull --rebase push {*NEW HEAD*}</div>"    //Thats how all the git fiddling looks to me
	else if(operating)
		dat += "Cooking in progress!<BR>Please wait...!</div>"
	else if(dirty==100)
		dat += "ERROR: >> 0 --Responce input zero<BR>Contact your operator of the device manifactor support.</div>"
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for (var/obj/O in contents)
			var/display_name = O.name
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Donk Pockets"
				items_measures[display_name] = "donk pocket"
				items_measures_p[display_name] = "donk pockets"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for (var/O in items_counts)
			var/N = items_counts[O]
			if (!(O in items_measures))
				dat += "[capitalize(O)]: [N] [lowertext(O)]\s<BR>"
			else
				if (N==1)
					dat += "[capitalize(O)]: [N] [items_measures[O]]<BR>"
				else
					dat += "[capitalize(O)]: [N] [items_measures_p[O]]<BR>"

		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if (R.id == "capsaicin")
				display_name = "hot sauce"
			if (R.id == "frostoil")
				display_name = "cold sauce"
			dat += "[display_name]: [R.volume] unit\s<BR>"

		if (items_counts.len==0 && reagents.reagent_list.len==0)
			dat += "The [machinetype] is empty.</div>"
		else
			dat = "<h3>Ingredients:</h3>[dat]</div>"
		dat += "<A href='?src=\ref[src];action=cook'>Turn on</A>"
		dat += "<A href='?src=\ref[src];action=dispose'>Eject ingredients</A>"

	var/datum/browser/popup = new(user, "[machinetype]", name, 300, 300)
	popup.set_content(dat)
	popup.open()
	return


/***********************************
*   cooking_machines Menu Handling/Cooking
************************************/

/obj/machinery/cooking_machines/proc/cook()
	world << "cook begin"
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		world << "dry run called"
		if (!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	if (!recipe|(recipe.cookingmethod != machinetype))
		dirty += 1
		if (prob(max(10,dirty*5)))
			world << "bad recipe"
			if (!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			cooked = fail()
			cooked.loc = loc
			return
		else if (has_extra_item())
			if (!wzhzhzh(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.loc = loc
			return
		else
			if (!wzhzhzh(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.loc = loc
			return
	else
		world << "cooking success"
		var/halftime = round(recipe.time/10/2)
		if (!wzhzhzh(halftime))
			abort()
			return
		if (!wzhzhzh(halftime))
			abort()
			cooked = fail()
			cooked.loc = loc
			return
		cooked = recipe.make_food(src)
		stop()
		if(cooked)
			cooked.loc = loc
		return

/obj/machinery/cooking_machines/proc/wzhzhzh(var/seconds as num)
	world << "wzhzhzh called"
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		if (i < 2)
			overlays = 0
			cookimg.color = "#A34719"
			overlays += cookimg
		else if (i >2)
			overlays = 0
			cookimg.color = "#C28566"
			overlays += cookimg
		sleep(10)
	return 1

/obj/machinery/cooking_machines/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

/obj/machinery/cooking_machines/proc/start()
	visible_message("<span class='notice'>The [machinetype] turns on.</span>", "<span class='notice'>You hear food being cooked.</span>")
	operating = 1
	icon_state = "[icontype]1"
	updateUsrDialog()

/obj/machinery/cooking_machines/proc/abort()
	operating = 0 // Turn it off again aferwards
	icon_state = "[icontype]"
	updateUsrDialog()

/obj/machinery/cooking_machines/proc/stop()
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	operating = 0 // Turn it off again aferwards
	icon_state = "[icontype]"
	updateUsrDialog()
	overlays.Cut()

/obj/machinery/cooking_machines/proc/dispose()
	for (var/obj/O in contents)
		O.loc = loc
	if (reagents.total_volume)
		dirty++
	reagents.clear_reagents()
	usr << "<span class='notice'>You dispose of the [machinetype] contents.</span>"
	overlays.Cut()
	cookimg.color = null
	updateUsrDialog()

/obj/machinery/cooking_machines/proc/muck_start()
	playsound(loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	icon_state = "[icontype]bloody1" // Make it look dirty!!

/obj/machinery/cooking_machines/proc/muck_finish()
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	visible_message("<span class='alert'>The [machinetype] gets covered in muck!</span>")
	dirty = 100 // Make it dirty so it can't be used util cleaned
	flags = null //So you can't add condiments
	icon_state = "[icontype]bloody" // Make it look dirty too
	operating = 0 // Turn it off again aferwards
	overlays.Cut()
	cookimg.color = null
	updateUsrDialog()

/obj/machinery/cooking_machines/proc/broke()
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	icon_state = "[icontype]b" // Make it look all busted up and shit
	visible_message("<span class='alert'>The [machinetype] breaks!</span>") //Let them know they're stupid
	broken = 2 // Make it broken so it can't be used util fixed
	flags = null //So you can't add condiments
	operating = 0 // Turn it off again aferwards
	updateUsrDialog()

/obj/machinery/cooking_machines/proc/fail()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("toxin", amount/10)
	return ffuu

/obj/machinery/cooking_machines/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook()

		if ("dispose")
			dispose()
	return
