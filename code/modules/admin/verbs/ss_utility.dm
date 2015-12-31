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
    set name = "Add User to Whitelist"

    set desc = "Adds a user either alien or head whitelist mid-round."

    if(!check_rights(R_ADMIN|R_MOD))    return

    var/client/input = input("Please, select a player!", "Add user to Whitelist") as null|anything in sortKey(clients)
    if(!input)  return
    else        input = input.ckey

    var/file = browse_files("data/whitelists/")
    switch(file)
        if("data/whitelists/alienwhitelist.txt")
            var/race = input("Which species?") as null|anything in whitelisted_species
            if(!race)   return
            if(shell("grep '[input] - [race]' [file]" == 0))        //Grep exit code is 0 on sucessful matches
                usr << "<span class='warning'>This user is already whitelisted for this race.</span>"
            else
                shell("echo '[input] - [race]' >> [file]")
                message_admins("[key_name_admin(src)] has added '[input] - [race]' to : [file]")
                call("/proc/load_alienwhitelist")()     //Re-loads the alien-whitelist

        if("data/whitelists/whitelist.txt")
            if(shell("grep '[input]' [file]" == 0))
                usr << "<span class='warning'>This user is already head-whitelisted.</span>"
            else
                shell("echo '[input]' >> [file]")
                message_admins("[key_name_admin(src)] has added '[input]' to : [file]")
                call("/proc/load_whitelist")()         //Re-loads the whitelist

        else    return
