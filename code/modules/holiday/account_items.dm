/proc/log_acc_item_to_db( var/ckey, var/obj_type )
	world << "Adding [obj_type] to [ckey]"

	if( !ckey )
		world << "No ckey given"
		return

	if( !obj_type )
		world << "No object type given"
		return

	if ( IsGuestKey(ckey) )
		world << "[ckey] is a guest"
		return

	if(!dbcon_old.IsConnected())
		world << "Database not connected"
		return

	var/sql_ckey = sql_sanitize_text(ckey)
	var/sql_item = sql_sanitize_text(obj_type)

	var/DBQuery/query = dbcon_old.NewQuery("SELECT id FROM acc_items WHERE ckey = '[sql_ckey]' AND item = '[sql_item]'")
	query.Execute()
	var/sql_id = 0

	while(query.NextRow())
		sql_id = query.item[1]
		break

	// If the given query exists, we dont need to add it again
	if(sql_id)
		world << "Entry for [ckey] and [obj_type] already exists"
		return

	world << "Entry not found, adding new account item"

	var/DBQuery/query_insert = dbcon_old.NewQuery("INSERT INTO acc_items (id, ckey, item, time) VALUES (null, '[sql_ckey]', '[sql_item]', null)")
	query_insert.Execute()

/client/proc/add_acc_item()
	set category = "Admin"
	set name = "Add Account Item"
	set desc = "Allow a certain account to spawn with the given item."

	var/account = sanitizeSafe(input(src, "Enter account name. Leave blank or as is to cancel.", "Enter Account", null))
	if( !account )
		return

	var/obj_type = sanitizeSafe(input(src, "Enter full object type. Leave blank or as is to cancel.", "Enter Object", null))
	if( !obj_type )
		return

	log_acc_item_to_db( account, obj_type )
	admin_log_and_message_admins("has added [obj_type] to the account of [account].")