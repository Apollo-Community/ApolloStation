
//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as")

/client/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='alert'>Speech is currently admin-disabled.</span>"
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>"
		return

	adminhelped = 1 //Determines if they get the message to reply by clicking the name.

	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the input msg
	if(!msg)
		return
	msg = sanitize(msg)
	if(!msg)
		return
	var/original_msg = msg

	//explode the input msg into a list
	var/list/msglist = text2list(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)	indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = text2list(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							msg += "<b><font color='black'>[original_word] (<A HREF='?_src_=holder;adminmoreinfo=\ref[found]'>?</A>)</font></b> "
							continue
			msg += "[original_word] "

	if(!mob) //this doesn't happen
		return

	var/ai_cl
	if(ai_found)
		ai_cl = " (<A HREF='?_src_=holder;adminchecklaws=\ref[mob]'>CL</A>)"

			//Options bar:  mob, details ( admin = 2, dev = 3, mentor = 4, character name (0 = just ckey, 1 = ckey and character name), link? (0 no don't make it a link, 1 do so),
			//		highlight special roles (0 = everyone has same looking name, 1 = antags / special roles get a golden name)

	var/mentor_msg = "<span class='notice'><b><font color=red>Request for Help: </font>[get_options_bar(mob, 4, 1, 1, 0)][ai_cl]:</b> [msg]</span>"
	STUI.staff.Add("\[[time_stamp()]] <font color=red>AHELP: </font><font color='#0066ff'>[key_name(mob)]:</b> [msg]</font><br>")
	STUI.processing |= 3

	//Sends the ahelp to slack chat
	spawn(0)	//So we don't hold up the rest
		shell("python scripts/adminbus.py ahelp [usr.ckey] '*[usr.ckey]*: `[original_msg]`'")
		if(!recent_slack_msg.Find(usr.ckey))
			recent_slack_msg.Add(usr.ckey)
		recent_slack_msg[usr.ckey] = "`[msg]`"

	msg = "<span class='notice'><b><font color=red>Request for Help:: </font>[get_options_bar(mob, 2, 1, 1)][ai_cl]:</b> [msg]</span>"

	var/admin_number_afk = 0

	for(var/client/X in admins)
		if((R_ADMIN|R_MOD|R_MENTOR) & X.holder.rights)
			if(X.is_afk())
				admin_number_afk++

			X << 'sound/effects/adminhelp.ogg'

			if(X.holder.rights == R_MENTOR)
				X << mentor_msg		// Mentors won't see coloring of names on people with special_roles (Antags, etc.)
			else
				X << msg

	//show it to the person adminhelping too
	src << "<font color='blue'>PM to-<b>Staff </b>: [original_msg]</font>"

	var/admin_number_present = admins.len - admin_number_afk
	var/active_admins = ""
	for(var/client/C in admins)		//So we can simplify trialmod logs
		if(!C.afk)	active_admins+= "[C.key],"
	log_adminpm("HELP: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins. ([active_admins])")
	if(admin_number_present <= 0)
		send2adminirc("Request for Help from [key_name(src)]: [html_decode(original_msg)] - !![admin_number_afk ? "All admins AFK ([admin_number_afk])" : "No admins online"]!!")
	else
		send2adminirc("Request for Help from [key_name(src)]: [html_decode(original_msg)]")
	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/proc/slack_admin(var/client/C, var/admin, var/message, var/dir)
	C << "<span class='pm'><span class='in'>" + create_text_tag("pm_[dir ? "out" : "in"]", "", C) + " <b>\[SLACK PM\]</b> <span class='name'><b><a href='?priv_msg_slack=\ref[C];admin=[admin]'>[admin]</a></b></span>: <span class='message'>[message]</span></span></span>"

	//STUI stuff
	log_admin("PM: [admin]->[key_name(C)]: [message]")
	STUI.staff.Add("\[[time_stamp()]] <font color=red>PM: </font><font color='#0066ff'>[admin] -> [key_name(C)] : [message]</font><br>")
	STUI.processing |= 3

	//We can blindly send this to all admins cause it is from slack
	for(var/client/X in admins)
		X << "<span class='pm'><span class='other'>" + create_text_tag("pm_other", "PM:", X) + " <span class='name'>[admin]:</span> to <span class='name'>[key_name(C, X, 0)]</span>: <span class='message'>[message]</span></span></span>"
