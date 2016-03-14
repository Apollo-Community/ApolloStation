/obj/item/device/uplink/hidden/Topic(href, href_list)
	var/mob/user = usr
	if(!user)	return

	switch(href_list["tgroup"])
		if("switch_menu")
			if("contract_menu")	contract_menu(user)
			//if("buy_menu")	buy_menu(user)
			//if("info_menu")	info_menu(user)

		if("close")
			toggle()
			menu.close()

		if("contracts")
			contract_topic(href, href_list, user)

		/*
		if("buy")
			buy_topic(href, href_list)

		if("info")
			buy_topic(href, href_list)
		*/

	return 1