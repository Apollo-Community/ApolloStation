	////////////
	//SECURITY//
	////////////
#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	0		//Just an ambiguously low version for now, I don't want to suddenly stop people playing.
									//I would just like the code ready should it ever need to be used.
#define REC_CLIENT_VERSION	510 	// Alerts people when their BYOND version is below this
	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	//Reduces spamming of links by dropping calls that happen during the delay period
	if(next_allowed_topic_time > world.time)
		return
	next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		world.log << "Attempted use of scripts within a topic call, by [src]"
		message_admins("Attempted use of scripts within a topic call, by [src]")
		//Destroy(usr)
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		cmd_admin_pm(C,null,href_list["discord"])
		return

	if(href_list["irc_msg"])
		if(!holder && received_irc_pm < world.time - 6000) //Worse they can do is spam IRC for 10 minutes
			usr << "<span class='warning'>You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you</span>"
			return
		if(mute_irc)
			usr << "<span class='warning'You cannot use this as your client has been muted from sending messages to the admins on IRC</span>"
			return
		cmd_admin_irc_pm(href_list["irc_msg"])
		return

	//Logs all hrefs
	if(config && config.log_hrefs && href_logfile)
		href_logfile << "<small>[time2text(world.timeofday,"hh:mm")] [src] (usr:[usr])</small> || [hsrc ? "[hsrc] " : ""][href]<br>"

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("vars")		return view_var_Topic(href,href_list,hsrc)

	..()	//redirect to hsrc.Topic()

/client/proc/loadTokens()
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/DBQuery/query

	query = dbcon.NewQuery("SELECT character_tokens FROM player WHERE ckey = '[ckey( ckey )]'")
	query.Execute()

	if( !query.NextRow() )
		return

	character_tokens = params2list( query.item[1] )

	for( var/type in character_tokens )
		character_tokens[type] = text2num( character_tokens[type] )

/client/proc/loadAntagWeights()
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/DBQuery/query

	query = dbcon.NewQuery("SELECT antag_weights FROM player WHERE ckey = '[ckey( ckey )]'")
	query.Execute()

	if( !query.NextRow() )
		return

	if( !isnull( query.item[1] ))
		antag_weights = params2list( query.item[1] )

/client/proc/handle_spam_prevention(var/message, var/mute_type)
	if(config.automute_on && !holder && src.last_message == message && non_spawn_check(message))
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			src << "<span class='alert'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>"
			cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			src << "<span class='alert'>You are nearing the spam filter limit for identical messages.</span>"
			return 0
	else
		last_message = message
		src.last_message_count = 0
		return 0

//Checks if the message is not in the allowed list
//UPDATE: also checks if the message around the sring check is not to long for abuse reasons
/client/proc/non_spawn_check(var/message)
	if(message == "gasps for air!")		return
	for(var/string in non_spawn_emote)
		if(findtext(message, string) && ((lentext(message) - lentext(string)) < 6))
			continue
		else
			return 1

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		src << "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>"
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		src << "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>"
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	TopicData = null							//Prevent calls to client.Topic from connect

	if(!(connection in list("seeker", "web")))					//Invalid connection type.
		return null
	if( byond_version < MIN_CLIENT_VERSION )		//Out of date client.
		return null

	if(!config.guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		del(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	src << "<span class='alert'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>"

	for(var/client/target in clients)
		if( !target )
			continue

		if(target.prefs)											//Rare runtime
			if(target.prefs.toggles & CHAT_OOC)
				target << "<span class='notice'><b>[src.key] has connected to the server.</b></span>"

				if( target.prefs.toggles & SOUND_NOTIFICATIONS )
					target << sound( 'sound/effects/oocjoin.ogg' )

	clients += src
	directory[ckey] = src

	//Admin Authorisation
	holder = admin_datums[ckey]
	if(holder)
		control_freak = 0
		admins += src
		holder.owner = src

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.client = src
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	if(!prefs.joined_date)				//So this is only called once to generate it.
		var/list/http[] = world.Export("http://www.byond.com/members/[key]?format=text")  // Retrieve information from BYOND
		if(http && http.len && ("CONTENT" in http))
			var/String = file2text(http["CONTENT"])  //  Convert the HTML file to text
			var/JoinPos = findtext(String, "joined")+10  //  Parse for the joined date
			prefs.joined_date = copytext(String, JoinPos, JoinPos+10)  //  Get the date in the YYYY-MM-DD format

	if(!prefs.passed_date)		//Re-calculate this each round until it passes
		if(round(world.realtime/864000)- text2days(prefs.joined_date) >= 30)
			prefs.passed_date = 1

	if(!prefs.country_code  && !address == "127.0.0.1")		//Stops localhost trying to be resolved.
		var/list/http[] = world.Export("http://www.freegeoip.net/json/[address]")
		if(http && http.len && ("CONTENT" in http))
			var/regex/R = new("country_code\":\"(\\w+)\"")
			if(R.Find(file2text(http["CONTENT"])))
				prefs.country_code = R.group[1]		//There should only ever be one!

	. = ..()	//calls mob.Login()

	if(custom_event_msg && custom_event_msg != "")
		src << "<h1 class='alert'>Custom Event</h1>"
		src << "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>"
		src << "<span class='alert'>[custom_event_msg]</span>"
		src << "<br>"

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_show()

	// Forcibly enable hardware-accelerated graphics, as we need them for the lighting overlays.
	// (but turn them off first, since sometimes BYOND doesn't turn them on properly otherwise)
	if(src)
		winset(src, null, "command=\".configure graphics-hwmode off\"")
		spawn(10) // Lets wait 1 second instead, 0.5 doesn't seem like enough
			winset(src, null, "command=\".configure graphics-hwmode on\"")

	session_start_time = world.realtime

	donator = get_donator( src )

	if(!stat_player_list.Find(key))			//Don't add the same person twice? How does this even happen
		var/obj/playerlist/O = new()
		O.icon = icon('./icons/playerlist.dmi')
		O.player = src

		if (holder && (R_MOD & holder.rights))
			O.name = "Moderator"
			O.icon_state = "mod"
		else if(holder && (R_ADMIN & holder.rights))
			O.name = "Admin"
			O.icon_state = "admin"
		else if(holder && (R_DEBUG & holder.rights))
			O.name = "Developer"
			O.icon_state = "dev"
		else if(holder && (R_MENTOR & holder.rights))
			O.name = "Mentor"
			O.icon_state = "mentor"
		else if(donator)
			O.name = "Donator"
			O.icon_state = "donator"
		else
			O.name = "Player"
			O.icon_state = "player"

		stat_player_list.Add(key)
		stat_player_list[key] = O
		stat_player_list = sortAssoc(stat_player_list)

	if( log_client_to_db() == 2.0 ) // if we're an entirely new player
		src << "<span class='admin_channel'>Hello and welcome to Apollo Station! Since this is your first time connecting, we'll be tossing some info \
		your way. If you've never played SS13 before, we highly recommend you read this <a href='https://apollo-community.org/wiki/index.php?title=The_Basics'>new player guide</a>. \
		Otherwise, if you're a veteran SS13 player who's new to Apollo, we'd recommend this <a href='https://apollo-community.org/wiki/index.php?title=A_Crash_Course_in_Roleplaying'>crash course guide</a> \
		which explains the major differences between Apollo station and other SS13 servers.\
		<br>In addition, feel free to message a staff member for help at any time by either pressing <b>F1</b> or using the <b>\"ahelp\"</b> command.<br><br><i>~Apollo Team</i></span>"
	else if( !prefs.passed_date )
		src << "<span class='admin_channel'>We have detected that your ckey is less than a month old. To help you get started we strongly recommend \
		reading <a href='https://apollo-community.org/wiki/index.php?title=The_Basics'>this helpful wiki page</a>.<br>In addition, feel free to message a staff \
		member for help at any time by either pressing <b>F1</b> or using the <b>\"ahelp\"</b> command.<br><br><i>~Apollo Team</i></span>"

	loadTokens()
	loadAntagWeights()

	gen_infraction_table()

	loadAccountItems()
	send_resources()
	nanomanager.send_resources(src)

	spawn( 50 )
		if( byond_version < REC_CLIENT_VERSION )
			alert(src,"Your BYOND client version is older than the recommended version. Please go to http://www.byond.com/download/ and download version [REC_CLIENT_VERSION].","BYOND Version","OK")


	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
	if( prefs )
		prefs.savePreferences()
	log_client_to_db( 1 )
	saveTokens()

	if(holder)
		holder.owner = null
		admins -= src
	directory -= ckey
	clients -= src

	return ..()


// here because it's similar to below

/*											This can wait until we get a RU translation
/client/proc/handle_country_codes()
	if(!prefs.country_code)		return
	switch(prefs.country_code)
		if("BRA")	src << "<span class='admin_channel'>Esperamos que você fale inglês corretamente. Se você não fala inglês fluentemente, esse servidor pode não ser adequado para você.</span>"
*/
/client/proc/gen_infraction_table()
	if(!holder && (!prefs.passed_date || (related_accounts_ip && !findtext(related_accounts_ip, "[ckey]")) || (related_accounts_cid && !findtext(related_accounts_cid, "[ckey]"))))
		var/message =  "<br><font color='#386AFF'><table><tr>"
		message += "<td>Ckey</td><td>Country</td><td>Join Date</td><td>Related CIDs</td><td>Related IPs</td>"
		message += "</tr><tr>"
		message += "<td>[ckey]</td>"
		message += "<td>[prefs.country_code]</td>"
		message += "<td>[prefs.passed_date ? "[prefs.joined_date]" : "<font color='#ff0000'>[prefs.joined_date]</font>"]</td>"
		message += "<td>[related_accounts_cid]</td>"
		message += "<td>[related_accounts_ip]</td>"
		message += "</tr></table></font>"

/*		var/list/padding_ammount = list(16 - (lentext(ckey) + 3) ,7 - lentext(prefs.country_code), 1, 33 - lentext(related_accounts_cid), 33 - lentext(related_accounts_ip))
		var/list/padding_message = list("| <a href='?src=\ref[usr];priv_msg=\ref[src.mob]'>[padding_ammount[1] < 0 ? "[copytext(ckey,1,12)].." : "[ckey]"]</a>(<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</a>) ",
										"| [prefs.country_code] ",
										"| [prefs.passed_date ? "[prefs.joined_date]" : "<font color='#ff0000'>[prefs.joined_date]</font>"] ",
										"| [padding_ammount[4] < 0 ? "[copytext(related_accounts_cid,1,32)].." : "[related_accounts_cid]"] ",
										"| [padding_ammount[5] < 0 ? "[copytext(related_accounts_ip,1,32)].." : "[related_accounts_ip]"] ")

		for(var/i = 1 to 5)
			message += padding_message[i]
			for(var/p = 1; p <= padding_ammount[i]; p++)	message += " "

		message += "|\n+------------------+---------+------------+-----------------------------------+-----------------------------------+</font></tt>\n"	//Closing table
*/

		for(var/client/C in admins)		C << "[message]"

// Returns null if no DB connection can be established, or -1 if the requested key was not found in the database
/proc/get_player_age(key)
	if( IsGuestKey( key ))
		return -1

	establish_db_connection()
	if(!dbcon.IsConnected())
		return -1

	var/sql_ckey = sql_sanitize_text(ckey(key))

	var/DBQuery/query = dbcon.NewQuery("SELECT datediff(Now(),firstseen) as age FROM player WHERE ckey = '[sql_ckey]'")
	query.Execute()

	if(query.NextRow())
		return text2num(query.item[1])
	else
		return -1


/client/proc/saveTokens()
	if ( IsGuestKey(src.key) )
		return 0

	if( !character_tokens || !character_tokens.len )
		return 0

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/tokens
	if( !character_tokens || !character_tokens.len )
		tokens = "null"
	else
		tokens = "'[list2params( character_tokens )]'"

	var/sql_ckey = ckey( ckey )

	var/DBQuery/query_insert = dbcon.NewQuery("UPDATE player SET character_tokens = [tokens] WHERE ckey = '[sql_ckey]'")
	query_insert.Execute()

/client/proc/saveAntagWeights()
	if ( IsGuestKey(src.key) )
		return 0

	if( !antag_weights )
		return 0

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/DBQuery/query_insert = dbcon.NewQuery("UPDATE player SET antag_weights = '[list2params( antag_weights )]' WHERE ckey = '[ckey( ckey )]'")
	query_insert.Execute()

/client/proc/log_client_to_db( var/log_playtime = 0 )
	if ( IsGuestKey(src.key) )
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/sql_ckey = ckey(src.ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM player WHERE ip = '[address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM player WHERE computerid = '[computer_id]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break

	var/total_playtime = 0
	if( log_playtime && sql_id )
		total_playtime = total_playtime_seconds()

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"
	if(src.holder)
		admin_rank = src.holder.rank

	var/sql_ip = sql_sanitize_text(src.address)
	var/sql_computerid = sql_sanitize_text(src.computer_id)
	var/sql_admin_rank = sql_sanitize_text(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables

		var/DBQuery/query_update

		if( total_playtime && log_playtime )
			query_update = dbcon.NewQuery("UPDATE player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]', playtime = '[total_playtime]' WHERE id = [sql_id]")
		else
			query_update = dbcon.NewQuery("UPDATE player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()

		return 1
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert
		if( total_playtime && log_playtime )
			query_insert = dbcon.NewQuery("INSERT INTO player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank, playtime) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]', '[total_playtime]')")
		else
			query_insert = dbcon.NewQuery("INSERT INTO player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]')")
		query_insert.Execute()
		return 2

	//Logging player access
	//var/serverip = "[world.internet_address]:[world.port]"
	//var/DBQuery/query_accesslog = dbcon.NewQuery("INSERT INTO `connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[sql_ckey]','[sql_ip]','[sql_computerid]');")
	//query_accesslog.Execute()


// Returns total recorded playtime in seconds
/client/proc/total_playtime_seconds()
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/total_playtime = 0

	var/sql_ckey = ckey(src.ckey)

	var/DBQuery/query_playtime = dbcon.NewQuery("SELECT playtime FROM player WHERE ckey = '[sql_ckey]'")
	query_playtime.Execute()

	while(query_playtime.NextRow())
		total_playtime = text2num( query_playtime.item[1] )
		break

	var/session_seconds = max( 0, round(( world.realtime-session_start_time )/DECISECONDS_IN_SECOND ))
	var/afk_seconds = max( 0, round( total_afk_time/DECISECONDS_IN_SECOND ))

	total_playtime = max( total_playtime, total_playtime+session_seconds )
	total_playtime = total_playtime-min( afk_seconds, session_seconds )

	return total_playtime

/client/proc/total_playtime_hours()
	var/playtime = round( total_playtime_seconds()/SECONDS_IN_HOUR )
	return playtime

/client/proc/client_exists_in_db()
	if ( IsGuestKey(src.key) )
		return 0

	establish_db_connection()
	if(!dbcon.IsConnected())
		return 0

	var/sql_ckey = ckey(src.ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	while(query.NextRow())
		player_age = text2num(query.item[2])

		return player_age

	return 0

#undef TOPIC_SPAM_DELAY
#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

//send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_resources()

	getFiles(
		'html/search.js',
		'html/panels.css',
		'html/images/loading.gif',
		'html/images/talisman.png',
		'icons/pda_icons/pda_atmos.png',
		'icons/pda_icons/pda_back.png',
		'icons/pda_icons/pda_bell.png',
		'icons/pda_icons/pda_blank.png',
		'icons/pda_icons/pda_boom.png',
		'icons/pda_icons/pda_bucket.png',
		'icons/pda_icons/pda_crate.png',
		'icons/pda_icons/pda_cuffs.png',
		'icons/pda_icons/pda_eject.png',
		'icons/pda_icons/pda_exit.png',
		'icons/pda_icons/pda_flashlight.png',
		'icons/pda_icons/pda_honk.png',
		'icons/pda_icons/pda_mail.png',
		'icons/pda_icons/pda_medical.png',
		'icons/pda_icons/pda_menu.png',
		'icons/pda_icons/pda_mule.png',
		'icons/pda_icons/pda_notes.png',
		'icons/pda_icons/pda_power.png',
		'icons/pda_icons/pda_rdoor.png',
		'icons/pda_icons/pda_reagent.png',
		'icons/pda_icons/pda_refresh.png',
		'icons/pda_icons/pda_scanner.png',
		'icons/pda_icons/pda_signaler.png',
		'icons/pda_icons/pda_status.png',
		'icons/spideros_icons/sos_1.png',
		'icons/spideros_icons/sos_2.png',
		'icons/spideros_icons/sos_3.png',
		'icons/spideros_icons/sos_4.png',
		'icons/spideros_icons/sos_5.png',
		'icons/spideros_icons/sos_6.png',
		'icons/spideros_icons/sos_7.png',
		'icons/spideros_icons/sos_8.png',
		'icons/spideros_icons/sos_9.png',
		'icons/spideros_icons/sos_10.png',
		'icons/spideros_icons/sos_11.png',
		'icons/spideros_icons/sos_12.png',
		'icons/spideros_icons/sos_13.png',
		'icons/spideros_icons/sos_14.png',
		'html/images/logo-nt.png',
		'html/images/logo-anti.png',
		'html/images/logo-apollo.png',
		'html/images/talisman.png',
		'html/images/barcode0.png',
		'html/images/barcode1.png',
		'html/images/barcode2.png',
		'html/images/barcode3.png',
		'html/images/apollo_map.png',
		)


mob/proc/MayRespawn()
	return 0

client/proc/MayRespawn()
	if(mob)
		return mob.MayRespawn()

	// Something went wrong, client is usually kicked or transfered to a new mob at this point
	return 0

client/proc/loadAccountItems()
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	if( !prefs )
		return
	if( !prefs.account_items )
		return

	prefs.account_items.Cut()

	var/sql_ckey = ckey(ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT item FROM acc_items WHERE ckey = '[sql_ckey]'")
	query.Execute()

	while(query.NextRow())
		var/item = query.item[1]

		if( gear_datums[item] )
			prefs.account_items += "[item]"
