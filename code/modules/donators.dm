var/list/donator_list = list()

proc/load_donators()
	donator_list = file2list("config/donators.txt")

proc/is_donator(client/C)
	if(donator_list)
		for(var/line in donator_list)
			if(findtext(line, "[C]"))
				return 1
	if(C.IsByondMember())	// unlikely people will be byond members (sorry its tru)
		return 1

proc/donator_tier(client/C)
	if(C.IsByondMember())
		return "BYOND"		// TIER BYOND MASTERRACE?
	if(donator_list)
		for(var/line in donator_list)
			if(!length(line))				continue
			//Return the tier
			if(findtext(line,"[C.ckey] - 1"))
				return 1
			else if(findtext(line,"[C.ckey] - 2"))
				return 2

	return 0

/client/verb/CheckDonator()
	set name = "Check Donator"
	set desc = "Checks your donation status"
	set category = "OOC"

	if(!is_donator(src))
		src << "You are not a registered donator. If you have donated please contact a member of staff to enquire."
	else
		src << "You are registed as a tier [donator_tier(src)] donator"

/client/verb/cmd_don_say(msg as text)
	set category = "OOC"
	set name = "Donsay"
	set hidden = 1

	if(!msg)
		return

	if(!is_donator(src))
		if(!check_rights(R_ADMIN|R_MOD))
			usr << "Only donators and staff can use this command."
			return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	log_admin("DON: [key_name(src)] : [msg]")
	for(var/client/C in clients)
		if((C.holder && (C.holder.rights & R_ADMIN || C.holder.rights & R_MOD)) || is_donator(C))
			C << "<span class='donatorsay'>" + create_text_tag("don", "DON:", C) + " <b>[src]: </b><span class='message'>[msg]</span></span>"
