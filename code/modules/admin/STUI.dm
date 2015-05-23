/*

		STUI - System Tabbed User Interface

		A system that allows admins to filter their chats

		ATTACK_LOG 		1
		ADMIN_LOG 		2
		STAFF_CHAT 		3
		OOC_CHAT 		4
		GAME_CHAT 		5
		DEBUG 			6


		DEFAULT CONFIG LENGTH == 150

		TODO:

			** setup a way of opening a single log
*/


/datum/STUI

	var/list/attack	= list()		//Attack logs
	var/list/admin = list()			//Admin logs
	var/list/staff = list()			//Staff Chat
	var/list/ooc = list()			//OOC chat
	var/list/game = list()			//Game Chat
	var/list/debug = list()			//Debug info
	var/list/processing	= list()	//list of logs that need processing

/datum/STUI/Topic(href, href_list)
	if(href_list["command"])
		usr.STUI_log = text2num(href_list["command"])
		processing |= usr.STUI_log		//forces the UI to update

/datum/STUI/proc/ui_interact(mob/user, ui_key = "STUI", var/datum/nanoui/ui = null, var/force_open = 1,var/force_start = 0)
	if(!(user.STUI_log in processing) && !force_start)
		return

	var/data[0]

	data["current_log"] = user.STUI_log
	switch(user.STUI_log)
		if(1)
			data["colour"] = "bad"
			if(attack.len > config.STUI_length+1)
				attack.Cut(,attack.len-config.STUI_length)
			data["log"] = list2text(attack)
		if(2)
			data["colour"] = "blue"
			if(admin.len > config.STUI_length+1)
				admin.Cut(,admin.len-config.STUI_length)
			data["log"] = list2text(admin)
		if(3)
			data["colour"] = "average"
			if(staff.len > config.STUI_length+1)
				staff.Cut(,staff.len-config.STUI_length)
			data["log"] = list2text(staff)
		if(4)
			data["colour"] = "average"
			if(ooc.len > config.STUI_length+1)
				ooc.Cut(,ooc.len-config.STUI_length)
			data["log"] = list2text(ooc)
		if(5)
			data["colour"] = "white"
			if(game.len > config.STUI_length+1)
				game.Cut(,game.len-config.STUI_length)
			data["log"] = list2text(game)
		else
			data["colour"] = "average"
			if(debug.len > config.STUI_length+1)
				debug.Cut(,debug.len-config.STUI_length)
			data["log"] = list2text(debug)

	ui = nanomanager.try_update_ui(user, user, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, user, ui_key, "STUI.tmpl", "STUI", 700, 500)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/client/proc/open_STUI()
	set name = "Open STUI"
	set category = "Admin"

	STUI.ui_interact(usr, force_start=1)