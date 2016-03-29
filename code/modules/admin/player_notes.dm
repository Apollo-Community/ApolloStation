//This stuff was originally intended to be integrated into the ban-system I was working on
//but it's safe to say that'll never be finished. So I've merged it into the current player panel.
//enjoy				~Carn
/*
#define NOTESFILE "data/player_notes.sav"	//where the player notes are saved

datum/admins/proc/notes_show(var/ckey)
	usr << browse("<head><title>Player Notes</title></head><body>[notes_gethtml(ckey)]</body>","window=player_notes;size=700x400")


datum/admins/proc/notes_gethtml(var/ckey)
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return "<font color='red'>Error: Cannot access [NOTESFILE]</font>"
	if(ckey)
		. = "<b>Notes for <a href='?src=\ref[src];notes=show'>[ckey]</a>:</b> <a href='?src=\ref[src];notes=add;ckey=[ckey]'>\[+\]</a> <a href='?src=\ref[src];notes=remove;ckey=[ckey]'>\[-\]</a><br>"
		notesfile.cd = "/[ckey]"
		var/index = 1
		while( !notesfile.eof )
			var/note
			notesfile >> note
			. += "[note] <a href='?src=\ref[src];notes=remove;ckey=[ckey];from=[index]'>\[-\]</a><br>"
			index++
	else
		. = "<b>All Notes:</b> <a href='?src=\ref[src];notes=add'>\[+\]</a> <a href='?src=\ref[src];notes=remove'>\[-\]</a><br>"
		notesfile.cd = "/"
		for(var/dir in notesfile.dir)
			. += "<a href='?src=\ref[src];notes=show;ckey=[dir]'>[dir]</a><br>"
	return


//handles adding notes to the end of a ckey's buffer
//originally had seperate entries such as var/by to record who left the note and when
//but the current bansystem is a heap of dung.
/proc/notes_add(var/ckey, var/note)
	if(!ckey)
		ckey = ckey(input(usr,"Who would you like to add notes for?","Enter a ckey",null) as text|null)
		if(!ckey)	return

	if(!note)
		note = html_encode(input(usr,"Enter your note:","Enter some text",null) as message|null)
		if(!note)	return

	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return
	notesfile.cd = "/[ckey]"
	notesfile.eof = 1		//move to the end of the buffer
	notesfile << "[time2text(world.realtime,"DD-MMM-YYYY")] | [note][(usr && usr.ckey)?" ~[usr.ckey]":""]"
	return

//handles removing entries from the buffer, or removing the entire directory if no start_index is given
/proc/notes_remove(var/ckey, var/start_index, var/end_index)
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return

	if(!ckey)
		notesfile.cd = "/"
		ckey = ckey(input(usr,"Who would you like to remove notes for?","Enter a ckey",null) as null|anything in notesfile.dir)
		if(!ckey)	return

	if(start_index)
		notesfile.cd = "/[ckey]"
		var/list/noteslist = list()
		if(!end_index)	end_index = start_index
		var/index = 0
		while( !notesfile.eof )
			index++
			var/temp
			notesfile >> temp
			if( (start_index <= index) && (index <= end_index) )
				continue
			noteslist += temp

		notesfile.eof = -2		//Move to the start of the buffer and then erase.

		for( var/note in noteslist )
			notesfile << note
	else
		notesfile.cd = "/"
		if(alert(usr,"Are you sure you want to remove all their notes?","Confirmation","No","Yes - Remove all notes") == "Yes - Remove all notes")
			notesfile.dir.Remove(ckey)
	return

#undef NOTESFILE
*/

//Hijacking this file for BS12 playernotes functions. I like this ^ one systemm alright, but converting sounds too bothersome~ Chinsky.

/proc/note_add( var/mob/user, var/note, var/rkey, var/rip, var/rcid )
	if( !rkey || !note || !user || !user.client || !user.client.holder )
		return

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return

	var/sql_rkey = "'[sql_sanitize_text( rkey )]'"
	var/sql_rip = "null"
	var/sql_rcid = "null"
	var/sql_akey = "'[ckey( usr.key )]'"
	var/sql_aip = "'[sql_sanitize_text( user.client.address )]'"
	var/sql_acid = "'[sql_sanitize_text( user.client.computer_id )]'"
	var/sql_arank = "'[sql_sanitize_text( usr.client.holder.rank )]'"
	var/sql_info = "'[sql_sanitize_text( note )]'"

	if( rip )
		sql_rip = "'[sql_sanitize_text( rkey )]'"

	if( rcid )
		sql_rcid = "'[sql_sanitize_text( rkey )]'"

	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO player_notes (`id`,`player_ckey`, `player_ip`, `player_cid`, `author_ckey` , `author_ip`, `author_cid`, `author_rank`, `date_time`, `info`) VALUES (null, [sql_rkey], [sql_rip], [sql_rcid], [sql_akey], [sql_aip], [sql_acid], [sql_arank], Now(), [sql_info])")
	if( query_insert.Execute() )
		message_admins("<span class='notice'>[key_name_admin(usr)] has edited [rkey]'s notes.</span>")
		log_admin("[key_name(usr)] has edited [rkey]'s notes.")

/proc/note_del( var/key as text, var/index as num )
	if( !key )
		return

	if( !index )
		return

	var/sql_index = sanitize_integer( index, 1, 2^32, 0)

	if( !sql_index )
		return

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return

	var/DBQuery/db_query = dbcon.NewQuery("DELETE FROM player_notes WHERE id = '[sql_index]'")

	if( db_query.Execute() )
		message_admins("<span class='notice'>[key_name_admin(usr)] deleted one of [key]'s notes.</span>")
		log_admin("[key_name(usr)] deleted one of [key]'s notes.")

/proc/show_player_info_irc(var/key as text)
	var/dat = "          Info on [key]%0D%0A"
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat = "No information found on the given key."
	else
		for(var/datum/player_info/I in infos)
			dat += "[I.content]%0D%0Aby [I.author] ([I.rank]) on [I.timestamp]%0D%0A%0D%0A"

	return dat
