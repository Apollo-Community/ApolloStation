/proc/note_add( var/mob/user, var/note, var/rkey, var/log = 1 )
	if( !rkey || !note || !user || !user.client || !user.client.holder )
		return

	establish_db_connection()
	if( !dbcon.IsConnected() )
		return

	var/DBQuery/db_query = dbcon.NewQuery("SELECT ip, computerid FROM player WHERE ckey = '[ckey( rkey )]'")

	var/ip
	var/cid

	if( db_query.Execute() && db_query.NextRow() )
		ip = db_query.item[1]
		cid = db_query.item[2]
	else
		if( log )
			message_admins("<span class='notice'>[key_name_admin(usr)] tried to edit [rkey]'s notes, but they haven't been on the server yet!</span>")
			log_admin("[key_name(usr)] tried to edit [rkey]'s notes, but they haven't been on the server yet!")
		return

	var/sql_rkey = "'[ckey( rkey )]'"
	var/sql_rip = "'[sql_sanitize_text( ip )]'"
	var/sql_rcid = "'[sql_sanitize_text( cid )]'"
	var/sql_akey = "'[ckey( usr.key )]'"
	var/sql_aip = "'[sql_sanitize_text( user.client.address )]'"
	var/sql_acid = "'[sql_sanitize_text( user.client.computer_id )]'"
	var/sql_arank = "'[sql_sanitize_text( user.client.holder.rank )]'"
	var/sql_info = "'[sql_sanitize_text( note )]'"

	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO player_notes (`id`,`player_ckey`, `player_ip`, `player_cid`, `author_ckey` , `author_ip`, `author_cid`, `author_rank`, `date_time`, `info`) VALUES (null, [sql_rkey], [sql_rip], [sql_rcid], [sql_akey], [sql_aip], [sql_acid], [sql_arank], Now(), [sql_info])")
	if( query_insert.Execute() && log )
		message_admins("<span class='notice'>[key_name_admin(usr)] has edited [rkey]'s notes.</span>")
		log_admin("[key_name(usr)] has edited [rkey]'s notes.")
	return

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
