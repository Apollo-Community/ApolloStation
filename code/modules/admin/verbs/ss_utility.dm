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
			usr << "<span class='danger'>This server is already compiling. Please try again in a few minutes.</span>"
		else
			usr << "<span class='danger'>Error: A catastrphic error has occured. Please contact a developer about this</span>"

	log_debug("IG UPDATE: exit code [result]")

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
