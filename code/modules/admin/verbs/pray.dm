/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='alert'>Speech is currently admin-disabled.</span>"
		return

	msg = sanitize(msg)
	if(!msg)	return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			usr << "<span class='alert'>You cannot pray (muted).</span>"
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	msg = "<span class='notice'><font color=purple>PRAY: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>) (<A HREF='?_src_=holder;admingivedrugs=\ref[src]'>DRG</a>):</b> [msg]</span>"
	log_admin(msg)

	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			if(C.prefs.toggles & CHAT_PRAYER)
				C << msg
	usr << "Your prayers have been received by the gods."

	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/proc/Centcomm_announce(var/text , var/mob/Sender , var/iamessage)
	var/msg = sanitize(text)
	msg = "<span class='notice'><b><font color=orange>CENTCOMM[iamessage ? " IA" : "</span>"]:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]"
	log_admin(msg)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			C << msg

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = sanitize(text)
	msg = "<span class='notice'><b><font color=crimson>ILLEGAL:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	log_admin(msg)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			C << msg
