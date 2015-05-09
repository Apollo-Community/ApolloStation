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


		WIP: TODO: **

			Improve efficency
*/


/datum/STUI
	var/cached_logs[6]			//stores changes to the logs
	var/entire_log[6]			//stores the entirety of the logs
	var/temp_logs[6]			//stores the temporary state of the logs
	var/process = 1

/datum/STUI/Topic(href, href_list)
	if(href_list["command"])
		usr.STUI_log = text2num(href_list["command"])

/datum/STUI/proc/ui_interact(mob/user, ui_key = "STUI", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	if(cached_logs[user.STUI_log])									//only need to do this if cached logs exist
		var/temp_split[]
		entire_log[user.STUI_log] += cached_logs[user.STUI_log]		//adds the cache to the entire log

		if(process)
			temp_split = split(entire_log[user.STUI_log],"<br>")
		else
			temp_split = split(addtext(temp_logs[user.STUI_log],cached_logs[user.STUI_log]),"<br>")

		if(temp_split.len > config.STUI_length+1)
			temp_split.Cut(,temp_split.len-config.STUI_length)
			process = 0

		temp_logs[user.STUI_log] = list2text(temp_split,"<br>")


		cached_logs[user.STUI_log] = null							//clears the cache-

		//show_vars()

	data["log"] = temp_logs[user.STUI_log]
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

//F_A's split
proc/split(txt, d)
    var/pos = findtext(txt, d)
    var/start = 1
    var/dlen = length(d)

    . = list()

    while(pos > 0)
        . += copytext(txt, start, pos)
        start = pos + dlen
        pos = findtext(txt, d, start)

    . += copytext(txt, start)