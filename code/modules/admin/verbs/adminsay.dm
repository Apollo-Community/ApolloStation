/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN) || R_MOD & src.holder.rights)		return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)	return

	log_adminsay("ADMIN : [key_name(src)] : [msg]")
	//STUI.cached_logs[3] += "\[[time_stamp()]] <font color='#9611D4'>ADMIN : [key_name(src)] : [msg] </font><br>"
	for(var/client/C in admins)
		if((R_ADMIN & C.holder.rights))
			if(!(R_MOD & C.holder.rights))
				C << "<span class='admin_channel'>" + create_text_tag("admin", "ADMIN:", C) + " <span class='name'>[key_name(usr, 1)]</span>(<a href='?_src_=holder;adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"

	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mod_say(msg as text)
	set category = "Special Verbs"
	set name = "Msay"
	set hidden = 1

	if(!check_rights(R_ADMIN|R_MOD))	return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	log_adminsay("MOD: [key_name(src)] : [msg]")
	STUI.staff.Add("\[[time_stamp()]] <font color='#b82e00'>MOD: [key_name(src)] : [msg]</font><br>")
	STUI.processing |= 3

	if (!msg)
		return

	var/sender_name = src.key
	if(check_rights(R_ADMIN, 0))
		sender_name = "<span class='admin'>[sender_name]</span>"

	for(var/client/C in admins)
		if((R_ADMIN|R_MOD) & C.holder.rights)
			C << "<span class='mod_channel'>" + create_text_tag("mod", "MOD:", C) + " <span class='name'>[sender_name]</span>(<A HREF='?src=\ref[C.holder];adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"

	feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!