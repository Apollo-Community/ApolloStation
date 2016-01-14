proc/get_donator(client/C)
	establish_db_connection()
	if(!dbcon.IsConnected())
		return null

	var/donator = 0
	var/sql_ckey = sql_sanitize_text(ckey(C.key))

	var/DBQuery/query = dbcon.NewQuery("SELECT donator_flags FROM player WHERE ckey = '[sql_ckey]'")
	query.Execute()

	if(query.NextRow())
		donator |= text2num(query.item[1])

	if(C.IsByondMember())	// unlikely people will be byond members (sorry its tru)
		donator |= DONATOR_TIER_BYOND

	return donator

proc/donator_tier(client/C)
	if( C.donator & DONATOR_TIER_BYOND )
		return "BYOND"		// TIER BYOND MASTERRACE?
	else if( C.donator & DONATOR_TIER_2 )
		return 2
	else if( C.donator & DONATOR_TIER_1 )
		return 1

	return 0

/client/verb/CheckDonator()
	set name = "Check Donator"
	set desc = "Checks your donation status"
	set category = "OOC"

	if(donator)		//swippity swoppity
		src << "You are registed as a tier [donator_tier(src)] donator"
	else
		src << "You are not a registered donator. If you have donated please contact a member of staff to enquire."

/client/verb/cmd_don_say(msg as text)
	set category = "OOC"
	set name = "Donsay"
	set hidden = 1

	if(!msg)
		return

	if(!donator)
		if(!check_rights(R_ADMIN|R_MOD))
			usr << "Only donators and staff can use this command."
			return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	log_admin("DON: [key_name(src)] : [msg]")
	for(var/client/C in clients)
		if((C.holder && (C.holder.rights & R_ADMIN || C.holder.rights & R_MOD)) || C.donator)
			C << "<span class='donatorsay'>" + create_text_tag("don", "DON:", C) + " <b>[src]: </b><span class='message'>[msg]</span></span>"
