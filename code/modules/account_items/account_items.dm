var/global/list/account_items = list()

/datum/gear/account
	account = 1

/proc/log_acc_item_to_db( var/ckey, var/obj_type )
	if( !ckey )
		return 0

	if( !obj_type )
		return 0

	if ( IsGuestKey(ckey) )
		return 0

	if( !dbcon.IsConnected() )
		return 0

	var/sql_ckey = ckey(ckey)
	var/sql_item = sql_sanitize_text(obj_type)

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM acc_items WHERE ckey = '[sql_ckey]' AND item = '[sql_item]'")
	query.Execute()
	var/sql_id = 0

	while(query.NextRow())
		sql_id = query.item[1]
		break

	// If the given query exists, we dont need to add it again
	if(sql_id)
		return 0

	var/sql_time = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO acc_items (id, ckey, item, time, donator) VALUES (null, '[sql_ckey]', '[sql_item]', '[sql_time]', 0)")
	query_insert.Execute()

	return 1

/proc/remove_acc_item_from_db( var/ckey, var/obj_type )
	if( !ckey )
		return 0

	if( !obj_type )
		return 0

	if ( IsGuestKey(ckey) )
		return 0

	if( !dbcon.IsConnected() )
		return 0

	var/sql_ckey = ckey(ckey)
	var/sql_item = sql_sanitize_text(obj_type)

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM acc_items WHERE ckey = '[sql_ckey]' AND item = '[sql_item]'")
	query.Execute()
	var/sql_id = 0

	while(query.NextRow())
		sql_id = query.item[1]
		break

	// If we couldn't find what we needed to remove
	if(!sql_id)
		return 0

	var/DBQuery/query_insert = dbcon.NewQuery("DELETE FROM acc_items WHERE id ='[sql_id]'")
	query_insert.Execute()

	return 1

/client/proc/add_acc_item()
	set category = "Admin"
	set name = "Account Item Add"
	set desc = "Allow a certain account to spawn with the given item."

	var/account = sanitizeSafe(input(src, "Enter account name. Leave blank or as is to cancel.", "Enter Account", null))
	if( !account )
		return

	var/obj_type = sanitizeSafe(input(src, "Enter full object type. Leave blank or as is to cancel.", "Enter Object", null))
	if( !obj_type )
		return

	if( log_acc_item_to_db( account, obj_type ))
		admin_log_and_message_admins("has added [obj_type] to the account of [account].")
	else
		usr << "Could not add [obj_type] to [account]!"

/client/proc/remove_acc_item()
	set category = "Admin"
	set name = "Account Item Remove"
	set desc = "Remove an item from the given account."

	var/account = sanitizeSafe(input(src, "Enter account name. Leave blank or as is to cancel.", "Enter Account", null))
	if( !account )
		return

	var/obj_type = sanitizeSafe(input(src, "Enter full object type. Leave blank or as is to cancel.", "Enter Object", null))
	if( !obj_type )
		return

	if( remove_acc_item_from_db( account, obj_type ))
		admin_log_and_message_admins("has remove [obj_type] from the account of [account].")
	else
		usr << "Could not add [obj_type] to [account]!"