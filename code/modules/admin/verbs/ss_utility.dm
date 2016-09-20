/*
** Server Side utilities
** - Any admin commands using shell()
*/

/client/proc/update_server()
	set category = "Server"
	set name = "Update Server"

	set desc = "Updates the server if possible to latest release on master branch"

	if(!check_rights(R_SERVER))    return

	var/command = file2text("config/update_script_command.txt")		//Security measure to stop people changing command via config debug
	if(!command)
		usr << "<span class='danger'>The update command could not be found on the server.</span>"
		return

	message_admins("[src.ckey] is remotely updating the server. Shout at them if something goes horribly wrong.")
	usr << "<b>Update log can be accessed with '.getupdatelog'</b>"
	log_debug("IG UPDATE: Origin = [src.ckey]")
	shell(command)		//Error handling and such is handled server side. The data_log is sufficient to see what the issue was.

/* We don't use these anymore so should disable them for safety.

/proc/safe_write(var/text, var/file_path, var/type = "in the file")         //In-case we decide to do more with this
    if(text_exists(text, file_path))
        usr << "<span class='warning'>This user is already [type].</span>"
        switch(alert("Delete text instead?","Delete: [text] from [file_path]","Yes","No"))
            if("Yes")	delete_text(text, file_path)
    else
        write_text(text,file_path)

/proc/text_exists(var/message, var/path)
	var/code = shell("grep '[message]' [path]")		//Grep exit code is 0 on sucessful match
	return code ? 0 : 1		//Maybe this will fix the issue?

/proc/write_text(var/message, var/path)
    shell("echo '[message]' >> [path]")
    message_admins("[key_name_admin(usr)] has written '[message]' to : [path]")

/proc/delete_text(var/message, var/path)
    shell("sed '/[message]/d' [path]")
    message_admins("[key_name_admin(usr)] has deleted '[message]' from : [path]")
*/

/client/proc/generate_cpu_graph()
	set category = "Debug"
	set name = "CPU Graph"
	set desc = "Generates a graph of CPU and Tick Usage."

	if(!check_rights(R_SERVER))    return
	var/iterations = input("How many iterations do you want?", "iterations:") as num
	message_admins("[src.ckey] is generating a CPU/Tick Usage graph.")
	usr << "<b>Creating file and starting log.."
	var/f_name = "[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-[clients.len]"
	var/csv = file("data/graphs/csv/[f_name].csv")
	csv << "Time,CPU,TICK"

	var/c = iterations/10				//Stores a cached version so we don't calculate x/10 every loop
	for(var/i = 1, i<=iterations; i++)
		csv << "[world.time],[world.cpu],[world.tick_usage]"
		if(!(i % c))		usr << "<b>\[GEN-LOG\] Collected [i]/[iterations] entries."
		sleep(world.tick_lag)

	usr << "<b>\[GEN-LOG\] Logs have been gathered - generating graph.</b>"

	if(!shell("python scripts/graph.py '[f_name]'"))			//returns 0 if run without error
		usr << "<span class='notice'>Graph generated and saved on server as data/graph/[f_name].png</span>"
		var/new_filename="data/graphs/[f_name].png"
		usr << ftp(new_filename,"[f_name].png")					//would be nicer in a window but I'd prefer to save it localy
		usr << file2text("data/graphs/data.txt")
	else
		usr << "<span class='warning'>An error occurred generating the graph, please contract a developer</span>"

/proc/send_slack(var/source, var/target = "1", var/message, var/col = "0")
	//Sends the ahelp to slack chat
	shell("python scripts/slack.py [source] [target] [col] '[sanitize(message)]'")

// sends ahelps from the server to discord
/proc/send_discord(var/source, var/target = "1", var/message)
	//shell("python scripts/discord_bot.py [source] [target] '["[message]"]'") //For windows testing
	shell("python3.6 scripts/discord_bot.py [source] [target] '[sanitize(message)]'")

//Get stored ahelp from a file
/proc/check_discord_ahelp()
	//Lets start the extracting and parsing
	var/page = file2text("scripts/ahelps.txt")
	var/list/data = list()
	//No backloged messages
	if(isnull(page) || page == "")
		return
	var/list/lineList = text2list(page)
	for(var/i = 1, i <= lineList.len, i++)
		//End of the document.
		if(findtext(lineList[i], "start_ahelp") > 0)
			data["mod"] = lineList[i+1]
			data["ckey"] = lineList[i+2]
			i+=3
			var/message = ""
			while(!(findtext(lineList[i], "stop_ahelp") > 0))
				message += lineList[i]
				i++
			i++
			data["message"] = message
		discord_game_handler.discord_admin_pm(data["mod"], data["ckey"], data["message"])
	//Remove the file so you dont start over in again on the next process cycle.
	fdel("scripts/ahelps.txt")

var/global/datum/discord_game_pm_handler/discord_game_handler = new()

datum/discord_game_pm_handler/proc/discord_admin_pm(var/sender, var/target, var/msg = null, var/discord = 0)
	if(isnull(target) || isnull(sender))
		return
	var/client/C
	//Find for who the message is.
	for(var/client/c in clients)
		if(c.ckey == target)
			C = c
			break

	if(isnull(C) || !istype(C,/client))
		return

	if(!msg)
		return

	//Sanatize the message so no exploits can be had !
	msg = sanitize(msg)
	if(!msg)
		return

	var/recieve_pm_type = "Discord mod/admin"
	C << "<font color=red> <b>\[[recieve_pm_type] PM\] <a href='?src=\ref[discord_game_handler];receiver=discord'>[sender]</a>:</b> [msg]</font>"
	C << 'sound/effects/adminhelp.ogg'
	log_admin("PM: [sender]->[key_name(C)]: [msg]")
	STUI.staff.Add("\[[time_stamp()]] <font color=red>PM: </font><font color='#0066ff'>[sender] -> [key_name(C)] : [msg]</font><br>")
	STUI.processing |= 3

	log_debug("c = [C]([C.ckey]) , src = sender , msg = [msg]")

	send_discord(sender, discord ? discord : C.ckey, msg)

	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == discord)
			continue
		if(X.key != C.key && (X.holder.rights & (R_ADMIN|R_MOD|R_MENTOR)))
			X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[sender]</span> to <span class='name'>[key_name(C, X, 0)]</span>: <span class='message'>[msg]</span></span></span>"

datum/discord_game_pm_handler/Topic(href,href_list[])
	//Whoever clicks the link is the replier/sender of the pm back
	var/client/sender = usr.client
	if(isnull(sender) || !istype(sender))
		return
	var/reply = sanitize(input(usr, "", "Reply", "") as text|null)
	if(isnull(reply) || reply == "")
		return
	send_discord(sender.key, href_list["receiver"], reply)
	for(var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == sender)
			continue
		if(X.key != sender.key && (X.holder.rights & (R_ADMIN|R_MOD|R_MENTOR)))
			X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[sender.key]</span> to <span class='name'>["discord"]</span>: <span class='message'>[reply]</span></span></span>"
