/obj/machinery/computer/complaints
	name = "\improper complaints console"
	desc = "Terminal for submitting complaints."
	icon = 'icons/obj/computer_complaints.dmi'
	icon_state = "complaintbox"
	density = 0

	circuit = "/obj/item/weapon/circuitboard/complaints"
	var/obj/item/weapon/card/id/scan = null

	var/database_hash = "complaints_computer" // DO NOT CHANGE THIS UNLESS YOU WANT TO UNLINK ALL DATABASE DATA
	var/global/category = "Complaints"
	var/max_pad_length = 10
	var/min_complaint_length = MAX_NAME_LEN
	var/max_title_length = MAX_NAME_LEN

	light_color = COMPUTER_BLUE

/obj/machinery/computer/complaints/New()
	..()

	database_hash = md5( database_hash )

/obj/machinery/computer/complaints/attackby( obj/O, mob/user )
	if( istype( O, /obj/item/weapon/paper ))
		var/obj/item/weapon/paper/P = O
		var/recipient_md5 = database_hash

		var/title = "Support Ticket No. [getTicketNumber()]"
		var/second_title = input("Please input a title for your complaint:", "", null, null)  as text
		if( second_title )
			title += ": [second_title]"

		if( length( title ) >= MAX_NAME_LEN )
			buzz("\The [src] buzzes, \"Title is too long!\"")
			flick( "complaintbox_deny", src )
			return

		if( length( title ) < min_complaint_length )
			buzz("\The [src] buzzes, \"Little to no content!\"")
			flick( "complaintbox_deny", src )
			return

		if( !addToPaperworkRecord( user, recipient_md5, P.info, title, "Unclassified", category ))
			buzz("\The [src] buzzes, \"Could not add your complaint!\"")
			flick( "complaintbox_deny", src )
			return

		ping("\The [src] pings, \"[title] successfully submitted!\"")
		flick( "complaintbox_insert", src )
		qdel( P )

		return
	..()

/obj/machinery/computer/complaints/proc/getTicketNumber()
	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM paperwork_records WHERE category = '[category]'")
	if( !query.Execute() )
		return "0000000000"

	var/text = "[query.RowCount()]"
	var/pad_length = max_pad_length-length(text)

	return "[add_zero(text, pad_length)]"

/proc/addToPaperworkRecord( mob/living/carbon/human/user, var/recipient_md5, var/info, var/title, var/clearence = "Unclassified", var/category = "Uncategorized" )
	if( !istype( user ) || !user.client || !user.character )
		return 0

	var/sql_author_ckey = "'[ckey( user.client.ckey )]'"
	var/sql_author_name = "'[sql_sanitize_text( user.character.name )]'"
	var/sql_author_ip = "'[sql_sanitize_text( user.client.address )]'"
	var/sql_author_md5 = "'[sql_sanitize_text( user.character.unique_identifier )]'"
	var/sql_recipient_md5 = "'[sql_sanitize_text( recipient_md5 )]'"
	var/sql_this_md5 = "'[sql_sanitize_text( md5( title ))]'"

	var/sql_clearence = "'[sql_sanitize_text( clearence )]'"
	var/sql_category = "'[sql_sanitize_text( category )]'"

	var/sql_datetime = "'[sql_sanitize_text( universe.getDateTime() )]'"

	var/sql_title
	if( title )
		sql_title = "'[sql_sanitize_text( title )]'"
	else
		sql_title = "null"

	var/sql_info = "'[sql_sanitize_text( info )]'"

	establish_db_connection()
	if( !dbcon.IsConnected() )
		testing( "PAPERWORK: Didn't save [title] because the database wasn't connected" )
		return 0

	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO paperwork_records \
	(id, author_ckey, author_name, author_ip, author_md5, recipient_md5, this_md5, clearence, category, date_time, title, info) \
	VALUES (null, [sql_author_ckey], [sql_author_name], [sql_author_ip], [sql_author_md5], [sql_recipient_md5], [sql_this_md5], [sql_clearence], [sql_category], [sql_datetime], [sql_title], [sql_info])")
	if( !query_insert.Execute() )
		return 0

	return 1


