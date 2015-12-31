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
		usr << "<span class='danger'> The update command could not be found on the server.</span>"
		return

	var/result = shell(command)		//Use exit codes to determine what occured

	switch(result)
		if(0)
			message_admins("[src.ckey] is remotely updating the server. Shout at them if something goes horribly wrong.")
			usr << "<b>Server updated sucessfully. Currently re-compiling...</b>"
			usr << "<b>Update log can be accessed with '.getupdatelog'</b>"
		if(1)
			usr << "<b>Server is already running this commit.</b>"
		if(2)
			usr << "<b>Server requires the resource file to be re-compiled - update unsucessful.</b>"
		if(3)
			usr << "<span class='danger'> This server is already compiling. Please try again in a few minutes.</span>"
		else
			usr << "<span class='danger'> Error: A catastrphic error has occured. Please contact a developer about this</span>"

	log_debug("IG UPDATE: exit code [result]")

/client/proc/add_whitelist()
    set category = "Admin"
    set name = "Write to Whitelist"

    set desc = "Adds a user to any whitelist available in the directory mid-round."

    if(!check_rights(R_ADMIN|R_MOD))    return

    var/client/input = input("Please, select a player!", "Add user to Whitelist") as null|anything in sortKey(clients)
    if(!input)  return
    else        input = input.ckey

    var/file = browse_files("data/whitelists/")
    switch(file)
        if("data/whitelists/alienwhitelist.txt")
            var/race = input("Which species?") as null|anything in whitelisted_species
            if(!race)   return
            if(safe_write("[input] - [race]", file, "whitelisted for this race"))
                call("/proc/load_alienwhitelist")()     //Re-loads the alien-whitelist

        if("data/whitelists/donators.txt")
            var/tier = input("Which tier?") as null|anything in list("1","2")
            if(!tier)   return
            if(safe_write("[input] - [tier]", file, "a donator"))
                call("/proc/load_donators")()          //Re-loads the donator list

        if("data/whitelists/whitelist.txt")
            if(safe_write(input,file, "Head-whitelisted"))
                call("/proc/load_whitelist")()         //Re-loads the whitelist
                
        else    return

/proc/safe_write(var/text, var/file_path, var/type = "in the file")         //In-case we decide to do more with this
    if(text_exists(text, file_path))
        usr << "<span class='warning'>This user is already [type].</span>"
        switch(alert("Delete text instead?","Delete: [text] from [file_path]","Yes","No"))
            if("Yes")	delete_text(text, file_path)
    else
        write_text(text,file_path)

/proc/text_exists(var/message, var/path)
    return shell("grep '[message]' [path]") ? 0 : 1         //Grep exit code is 0 on sucess, so we flip it here to make sense

/proc/write_text(var/message, var/path)
    shell("echo '[message]' >> [path]")
    message_admins("[key_name_admin(src)] has written '[message]' to : [path]")

/proc/delete_text(var/message, var/path)
    shell("sed '/[message]/d' [path]")
    message_admins("[key_name_admin(src)] has deleted '[message]' from : [path]")
