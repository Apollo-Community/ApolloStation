/*
Mentor code by xRev.
I'll try to comment as much as I can.
Famous last words.
*/

/client/verb/mentorhelp(msg as text)
	set category = "Admin"
	set name = "Mentorhelp"

	if(prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: Mentor-PM: You cannot send mentorhelps (Muted).</font>"
		return

	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	if(!msg) //Sanitizing the given message.
		return
	msg = sanitize(msg)
	if(!msg)
		return
	var/original_msg = msg

	if(!mob) //Generally won't happen.
		return

	//Now we add it to STUI.
	STUI.staff.Add("\[[time_stamp()]] <font color=red>MHELP: </font><font color='#0066ff'>[key_name(mob)]:</b> [msg]</font><br>")
	STUI.processing |= 3

	msg = "<span class='notice'><b><font color=green>Request for Mentor:: </font>[get_options_bar(mob, 4, 1, 1)]:</b> [msg]</span>"

	for(var/client/X in admins) //Let's go send it to the mentors (and other staff)
		if((R_ADMIN|R_MENTOR) & X.holder.rights)
			X << msg
			X << 'sound/effects/adminhelp.ogg'

	src << "<font color='blue'>PM to-<b>Mentors </b>: [original_msg]</font>" //Let's show it back to the person Mentorhelping

/client/proc/cmd_mentor_say(msg as text)
	set category = "Special Verbs"
	set name = "Hsay"
	set hidden = 1

	if(!msg) //Sanitizing the given message again.
		return
	msg = sanitize(msg)
	if(!msg)
		return

	if(!check_rights(R_MENTOR))	return //Don't use this if you're not a mentor.

	log_adminsay("MENTOR: [key_name(src)] : [msg]")

	STUI.staff.Add("\[[time_stamp()]] <font color='#b82e00'>MENTOR: [key_name(src)] : [msg]</font><br>")
	STUI.processing |= 3

	var/sender_name = src.key
	for(var/client/C in admins)
		if((R_MENTOR) & C.holder.rights)
			C << "<span class='mentor_channel'>" + create_text_tag("mentor", "MENTOR:", C) + " <span class='name'>[sender_name]</span>(<A HREF='?src=\ref[C.holder];adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"

	feedback_add_details("admin_verb","MENS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!