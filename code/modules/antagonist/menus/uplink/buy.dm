/obj/item/device/uplink/proc/buy_menu(var/mob/user)
	if(!istype(user) || !user.client)	return

	var/tgroup = "buy"

	var/datum/antagonist/antag = user.mind.antagonist
	var/datum/money_account/A = find_account(user)

	. += "<html><head>"
	. += {"<style>
		body{
			background-color: #8f1414;
			background-image: url('uiBackground-Syndicate.png');
			background-position: 50% 0;
			background-repeat: repeat-x;
		}

		.white{
			color: #ffffff;
		}

		.red{
			color: #9f2828;
		}
		</style>"}
	. += "</head><body><center>"

	. += "<b><a href='byond://?src=\ref[src];tgroup=switch_menu;task=contract_menu'>Contracts</a></b>"
	. += " - <b>Equipment</b>"
	. += " - <b><a href='byond://?src=\ref[src];tgroup=switch_menu;task=info_menu'>Information</a></b>"
	. += " - <b><a href='byond://?src=\ref[src];tgroup=close'>Close</a></b>"
	. += "<hr></center>"

	// REMOVE USER.MIND.CHANGELING CHECK WHEN CHANGELING GETS PORTED! it's just there to prevent old lings having uplink access for now
	if(antag && antag.can_buy && !faction_controller.contract_ban && !antag.uplink_blocked && !user.mind.changeling)
		. += "<h2><span class='white'>Uplink Market</span></h2>"
		. += "<h3><span class='white'>Available Funds: $[A.money]</span></h3>"

		var/categories = ItemsCategory.Copy()
		if(!categories["[antag.faction.name] Equipment"] && antag.faction.equipment.len)
			categories["[antag.faction.name] Equipment"] = antag.faction.equipment

			// hacky workaround - if the equipment is left in ItemsCategory the player can still buy it even if their faction is changed
			ItemsCategory["[antag.faction.name] Equipment"] = antag.faction.equipment
			var/datum/nano_item_lists/IL = generate_item_lists()
			nanoui_items = IL.items_nano
			ItemsReference = IL.items_reference
			ItemsCategory["[antag.faction.name] Equipment"] = null

		for(var/category in categories)
			. += "<h3><span class='white'>[category]</span></h3>"
			. += "<table><center>"
			for(var/datum/uplink_item/I in categories[category])
				. += "<tr><table class='outline'>"
				. += "<th width=20%>[I.name]</th>"
				. += "<td width=40%>$[I.cost]</td>"
				. += "<th width=20%>"
				if(A.money >= I.cost)
					. += "<a href='byond://?src=\ref[src];tgroup=[tgroup];task=[I.reference]'>Purchase</a>"
				else
					. += "<i class='red'>Insufficient Funds</i>"
				. += "</th>"
			. += "</center></table><br>"

		. += "<h3><span class='white'>Other</span></h3>"
		. += "<center><table class='outline'>"
		. += "<th width=20%>Random Item</th>"
		. += "<td width=40%>$???</td>"
		. += "<th width=20%><a href='byond://?src=\ref[src];tgroup=[tgroup];task=random'>Purchase</a></th>"
		. += "</table></center>"
	else
		. += "<center><h2><span class='white'>The Uplink Market is Unavailable</span></h2>"
		. += "<span class='white'>Your employer has disabled your market service access.</span></center>"

	. += "</body></html>"

	menu.set_user(user)
	menu.set_content(.)
	menu.open()

/obj/item/device/uplink/proc/buy_topic(href, href_list, var/mob/user, var/secret=0)
	var/datum/money_account/A = find_account(user)

	if(A && href_list["task"] == "random")
		var/list/random_items = new
		for(var/IR in ItemsReference)
			var/datum/uplink_item/UI = ItemsReference[IR]
			if(A.money >= UI.cost)
				random_items += UI

		var/datum/uplink_item/I = pick(random_items)
		return buy(I, I ? I.reference : "", user, secret)

	var/datum/uplink_item/I = ItemsReference[href_list["task"]]
	for(var/datum/uplink_item/UI in ItemsReference)
		world << UI
	world << I
	return buy(I, I ? I.reference : "", user, secret)

/obj/item/device/uplink/proc/buy(var/datum/uplink_item/UI, var/reference, var/mob/user, var/secret=0)
	var/datum/money_account/A = find_account(user)
	
	if(A && A.money >= UI.cost)
		A.money -= UI.cost
		user.mind.antagonist.money_spent += UI.cost
		feedback_add_details("traitor_uplink_items_bought", reference)

		var/obj/I = new UI.path(get_turf(usr))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.put_in_any_hand_if_possible(I)

		purchase_log[UI] = purchase_log[UI] + 1

		if(!secret)
			buy_menu(user)
		return 1

	if(!secret)
		buy_menu(user)
	return 0