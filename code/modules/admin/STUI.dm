/*

		STUI - System Tabbed User Interface

		A system that allows admins to filter their chats

		ATTACK_LOG 		1
		ADMIN_LOG 		2
		STAFF_CHAT 		3
		OOC_CHAT 		4
		GAME_CHAT 		5
		DEBUG 			6


		WIP: TODO: **

			Stop mods seeing admin say
			integrate HREFS
			investigate possibilities for in-game grep

*/

/datum/STUI
	var/logs[6]

/datum/STUI/Topic(href, href_list)
	if(href_list["command"])
		usr.STUI_log = text2num(href_list["command"])

/datum/STUI/proc/ui_interact(mob/user, ui_key = "STUI", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["log"] = STUI.logs[user.STUI_log]
	data["current_log"] = user.STUI_log
	switch(user.STUI_log)
		if(1)		data["colour"] = "bad"
		if(2)		data["colour"] = "blue"
		if(5)		data["colour"] = "white"
		else 		data["colour"] = "average"

	ui = nanomanager.try_update_ui(user, user, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, user, ui_key, "STUI.tmpl", "STUI", 700, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/client/proc/open_STUI()
	set name = "Open STUI"
	set category = "Admin"

	STUI.ui_interact(usr)

