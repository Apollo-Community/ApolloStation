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
	shell("python scripts/discord_bot.py [source] [target] '["[message]"]'") //For windows testing
	//shell("python3.6 scripts/discord_bot.py [source] [target] '[sanitize(message)]'")

/proc/discord_admin(var/client/C, var/admin, var/message, var/dir)
	C << "<span class='pm'><span class='in'>" + create_text_tag("pm_[dir ? "out" : "in"]", "", C) + " <b>\[DISCORD ADMIN PM\]</b> <span class='name'><b><a href='?priv_msg=\ref[C];discord=[admin]'>[admin]</a></b></span>: <span class='message'>[message]</span></span></span>"

	//STUI stuff
	log_admin("PM: [admin]->[key_name(C)]: [message]")
	STUI.staff.Add("\[[time_stamp()]] <font color=red>PM: </font><font color='#0066ff'>[admin] -> [key_name(C)] : [message]</font><br>")
	STUI.processing |= 3

	//now send it back to slack
	send_discord(admin, C.ckey, message)

	//We can blindly send this to all admins cause it is from slack
	for(var/client/X in admins)
		X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[admin]:</span> to <span class='name'>[key_name(C, X, 0)]</span>: <span class='message'>[message]</span></span></span>"