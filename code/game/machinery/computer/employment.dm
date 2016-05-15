//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/employment
	name = "employment records console"
	desc = "Used to view, edit and maintain employment records."
	icon_state = "medlaptop"
	req_one_access = list(access_heads, access_lawyer)
	circuit = "/obj/item/weapon/circuitboard/records"
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null

	var/screen_type = 0 // Station records or CentComm records?
	var/screen = null // What screen are we on?

	var/datum/data/record/active1 = null
	var/a_id = null

	var/return_limit = 10
	var/query = null

	// What are we searching by?
	var/query_type = "name"
	// What types of query types allow full and partial searches?
	var/list/query_types = list( "name" = 1, "birth_date" = 0, "fingerprints" = 1, "blood_type" = 0, "DNA" = 1)
	// It is a complete or partial search?
	var/is_complete = 1

	var/temp = null
	var/tempname = null

	var/printing = null
	var/can_change_id = 0
	var/list/Perp

	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending
	light_color = COMPUTER_GREEN

	var/datum/browser/menu = new( null, "employee_rec", "Employment Records", 710, 725 )

/obj/machinery/computer/employment/attackby(obj/item/O as obj, user as mob)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_item()
		O.loc = src
		scan = O
		user << "You insert [O]."
		screen = 1
		authenticate( user )
	..()

/obj/machinery/computer/employment/attack_ai(mob/user as mob)
	return attack_hand(user)

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/employment/attack_hand(mob/user as mob)
	if(..())
		return
	ui_interact( user )

/obj/machinery/computer/employment/ui_interact( mob/user as mob )
	if( src.z in overmap.admin_levels )
		user << "<span class='alert'><b>Unable to establish a connection</b>: </span><span class='black'>You're too far away from the station!</span>"
		return

	. = header( user )

	switch( screen_type )
		if( 0 )
			. += station_records( user )
		if( 1 )
			. += centcomm_records( user )

	menu.set_user( user )
	menu.set_content( . )
	menu.open()
	onclose(user, "employee_rec")
	return

/obj/machinery/computer/employment/proc/header( mob/user as mob )
	. = ""

	if (authenticated)
		. += "<center>"
		switch( screen_type )
			if( 0 )
				. += "Station Database - "
				. += "<a href='?src=\ref[src];choice=Switch Menu;type=1'>CentComm Database</a>"
			if( 1 )
				. += "<a href='?src=\ref[src];choice=Switch Menu;type=0'>Station Database</a> - "
				. += "CentComm Database"
		. += "</center>"

		. += "<br><br>"
	. += "Confirm Identity: <A href='?src=\ref[src];choice=Confirm Identity'>[(scan ? scan.name : "----------")]</A><HR>"

	return .

/obj/machinery/computer/employment/proc/centcomm_records( mob/user as mob )
	if( temp )
		. = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
		return

	. = ""

	if( !authenticated )
		return

	switch( screen )
		if( 1 )
			establish_db_connection()
			if( !dbcon.IsConnected() )
				. += {"<table class='outline'>
<tr>
<th>No connection to the external database!</th>
</tr>
</table>"}
				return .

			if( !query )
				. += {"<table class='outline'>
<tr>
<th>Please input a <a href='?src=\ref[src];choice=Search Centcomm Records'>Search</a></th>
</tr>
</table>"}
				return

			var/query_input = "= '[query]'"
			if( !is_complete )
				query_input = "LIKE '%[query]%'"

			var/DBQuery/db_query = dbcon.NewQuery("SELECT name, gender, birth_date, blood_type, fingerprints, unique_identifier FROM characters WHERE [query_type] [query_input] LIMIT [return_limit]")

			if( !db_query.Execute() )
				. += {"<table class='outline'>
<tr>
<th>Invalid database query! Please input a new <a href='?src=\ref[src];choice=Search Centcomm Records'>Search</a></th>
</tr>
</table>"}
				return .

			. += {"<table class='outline'>
<tr>
<th><a href='?src=\ref[src];choice=Search Centcomm Records'>Search:</a> [query]</a></th>
</tr>
</table>
<table class='border'>
<tr>
<th>Name</th>
<th>Gender</th>
<th>Birth Date</th>
<th>Blood Type</th>
<th>Fingerprints</th>
<th>Paperwork</th>
</tr>"}
			while( db_query.NextRow() )
				var/char_name = db_query.item[1]
				. += "<tr>"
				. += "<td>[char_name]</td>"
				. += "<td>[db_query.item[2]]</td>"
				. += "<td>[db_query.item[3]]</td>"
				. += "<td>[db_query.item[4]]</td>"
				. += "<td>[db_query.item[5]]</td>"
				. += "<td><a href='?src=\ref[src];choice=Load Paperwork;hash=[db_query.item[6]];name=[char_name]'>View</a></td>"
				. += "</tr>"

			. += "</table>"

			. += "<hr><center>Limited to [return_limit] results</center>"
		if( 2 )
			. += {"<table class='outline'>
<tr>
<th>Paperwork Records: [tempname]</th>
</tr>
</table>"}
			. += get_paperwork_records( query )

	return .

/obj/machinery/computer/employment/proc/get_paperwork_records( var/rec_md5 )
	. = ""

	establish_db_connection()
	if( !dbcon.IsConnected() )
		. += {"<table class='outline'>
<tr>
<th>No connection to the external database!</th>
</tr>
</table>"}
		. += "<A href='?src=\ref[src];choice=Return'>Back</A>"
		return .

	var/sql_rec_md5 = sql_sanitize_text( rec_md5 )

	var/DBQuery/db_query = dbcon.NewQuery("SELECT date_time, title, id FROM paperwork_records WHERE recipient_md5 = '[sql_rec_md5]'")

	if( !db_query.Execute() )
		. += {"<table class='outline'>
<tr>
<th>Invalid database query!</th>
</tr>
</table>"}
		. += "<A href='?src=\ref[src];choice=Return'>Back</A>"
		return .

	. += {"<table class='border'>
<tr>
<table class='border'>
<tr>
<th>Date</th>
<th>Title</th>
<th>View</th>
</tr>"}

	while( db_query.NextRow() )
		. += "<tr>"
		. += "<td>[db_query.item[1]]</td>"
		. += "<td>[db_query.item[2]]</td>"
		. += "<td><center><a href='?src=\ref[src];choice=View Paperwork;id=[db_query.item[3]]'>View</a></center></td>"
		. += "</tr>"

	. += "</table>"

	. += "<hr><A href='?src=\ref[src];choice=Return'>Back</A>"

/obj/machinery/computer/employment/proc/station_records( mob/user as mob )
	if (temp)
		. = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
	else
		if (authenticated)
			switch(screen)
				if(1.0)
					. += "<p style='text-align:center;'>"
					. += text("<A href='?src=\ref[];choice=Search Records'>Search Records</A><BR>", src)
					. += text("<A href='?src=\ref[];choice=New Record (General)'>New Record</A><BR>", src)
					. += {"
</p>
<table class='outline'>
<tr>
<th>Records:</th>
</tr>
</table>
<table class='border'>
<tr>
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
</tr>"}
					if(!isnull(data_core.general))
						for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
							. += "<tr><td><A href='?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>"
							. += text("<td>[]</td>", R.fields["id"])
							. += text("<td>[]</td>", R.fields["rank"])
							. += text("<td>[]</td>", R.fields["fingerprint"])
						. += "</table><hr width='75%' />"
					. += text("<A href='?src=\ref[];choice=Record Maintenance'>Record Maintenance</A><br><br>", src)
				if(2.0)
					. += "<B>Records Maintenance</B><HR>"
					. += "<BR><A href='?src=\ref[src];choice=Delete All Records'>Delete All Station Records</A><BR><BR><A href='?src=\ref[src];choice=Return'>Back</A>"
				if(3.0)
					. += "<CENTER><B>Employment Record</B></CENTER><BR>"
					if( istype( active1, /datum/data/record ) && ( active1 in data_core.general ))
						var/icon/front = active1.fields["photo_front"]
						var/icon/side = active1.fields["photo_side"]
						user << browse_rsc(front, "front.png")
						user << browse_rsc(side, "side.png")
						. += text("<table class='outline'><tr><td>	\
						Name: <A href='?src=\ref[src];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR> \
						ID: <A href='?src=\ref[src];choice=Edit Field;field=id'>[active1.fields["id"]]</A><BR>\n	\
						Sex: <A href='?src=\ref[src];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>\n	\
						Age: <A href='?src=\ref[src];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>\n	\
						Rank: <A href='?src=\ref[src];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>\n	\
						Fingerprint: <A href='?src=\ref[src];choice=Edit Field;field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>\n	\
						Physical Status: [active1.fields["p_stat"]]<BR>\n	\
						Mental Status: [active1.fields["m_stat"]]<BR>\n")

						. += text( "</td>	\
						<td align = center valign = top>Photo:<br><img src=front.png height=80 width=80>	\
						<img src=side.png height=80 width=80></td></tr></table>")

						. += "<br><table class='outline'><tr><td>General Record:</td></tr><tr><td>[decode(active1.fields["notes"])]</td></tr></table><BR>"
						. += {"<table class='outline'>
<tr>
<th>Paperwork Records: [active1.fields["name"]]</th>
</tr>
</table>"}
						var/datum/character/C = active1.fields["character"]
						if( istype( C ))
							. += get_paperwork_records( C.unique_identifier )
							. += "<A href='?src=\ref[src];choice=Add Note;rec_hash=[C.unique_identifier]'>Add Note</A><BR>"
						else
							. += "Could not find employee in external database."

					else
						. += "<B>General Record Lost!</B><BR>"
//					. += text("\n<A href='?src=\ref[];choice=Delete Station Record'>Delete Station Record</A>"
					. += "<BR><BR>\n<A href='?src=\ref[src];choice=Print Record'>Print Record</A><BR>\n<A href='?src=\ref[src];choice=Return'>Back</A><BR>"
				if(4.0)
					if(!Perp.len)
						. += "ERROR.  String could not be located.<br><br><A href='?src=\ref[src];choice=Return'>Back</A>"
					else
						. += {"
<table class='outline'>
<tr>					"}
						. += "<th>Search Results for '[tempname]':</th>"
						. += {"
</tr>
</table>
<table class='border'>
<tr>
<th>Name</th>
<th>ID</th>
<th>Rank</th>
<th>Fingerprints</th>
</tr>					"}
						for(var/i=1, i<=Perp.len, i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record/))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							. += "<tr><td><A href='?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>"
							. += text("<td>[]</td>", R.fields["id"])
							. += text("<td>[]</td>", R.fields["rank"])
							. += text("<td>[]</td>", R.fields["fingerprint"])
							. += text("<td>[]</td></tr>", crimstat)
						. += "</table><hr width='75%' />"
						. += text("<br><A href='?src=\ref[];choice=Return'>Return to index.</A>", src)
				else
		else
			. += text("<A href='?src=\ref[];choice=Log In'>Log In</A>", src)

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/employment/Topic(href, href_list)
	if(..())
		return
	if( !( active1 in data_core.general ))
		active1 = null
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		switch(href_list["choice"])
// SORTING!
			if("Sorting")
				// Reverse the order if clicked twice
				if(sortBy == href_list["sort"])
					if(order == 1)
						order = -1
					else
						order = 1
				else
				// New sorting order!
					sortBy = href_list["sort"]
					order = initial(order)
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if ("Return")
				screen = 1
				active1 = null

			if( "Switch Menu" )
				var/s_type = text2num( href_list["type"] )
				if( !isnull( s_type ))
					screen_type = s_type
				screen = 1

			if( "Load Paperwork" )
				screen = 2

				query = href_list["hash"]
				tempname = href_list["name"]
				query_type = "unique_identifier"

			if( "View Paperwork" )
				var/sql_id = text2num( href_list["id"] )
				var/DBQuery/db_query

				db_query = dbcon.NewQuery("SELECT title, info FROM paperwork_records WHERE id = [sql_id]")

				if( !db_query.Execute() )
					return

				if( !db_query.NextRow() )
					return

				var/title = db_query.item[1]
				var/info = db_query.item[2]
				usr << browse( info, "window=[title]")
				return

			if("Add Note")
				var/obj/item/weapon/paper/P = usr.get_active_hand()
				if( istype( P ))
					var/title = input("Input a title for this note:", "Input Title", null, null)  as text
					if( !title )
						title = "Note"

					var/rec_hash = href_list["rec_hash"]
					if( !addToPaperworkRecord( usr, rec_hash, P.info, "[title]", "Unclassified", "Employment Notes" ))
						buzz( "\The [src] buzzes, \"Could not add note!\"" )
					else
						ping( "\The [src] pings, \"Note successfully added!.\"" )
				else
					buzz( "\The [src] buzzes, \"This machine accepts paper for notes.\"" )

			if("Confirm Identity")
				screen = 1
				if (scan)
					if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
						usr.put_in_hands(scan)
					else
						scan.loc = get_turf(src)
					scan = null
				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/weapon/card/id))
						usr.drop_item()
						I.loc = src
						scan = I
				authenticate( usr )
			if("Log In")
				authenticate( usr )
//RECORD FUNCTIONS
			if("Search Records")
				var/t1 = input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || !in_range(src, usr)))
					return
				Perp = new/list()
				t1 = lowertext(t1)
				var/list/components = text2list(t1, " ")
				if(components.len > 5)
					return //Lets not let them search too greedily.
				for(var/datum/data/record/R in data_core.general)
					var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["fingerprint"] + " " + R.fields["rank"]
					for(var/i = 1, i<=components.len, i++)
						if(findtext(temptext,components[i]))
							var/prelist = new/list(2)
							prelist[1] = R
							Perp += prelist
				for(var/i = 1, i<=Perp.len, i+=2)
					for(var/datum/data/record/E in data_core.security)
						var/datum/data/record/R = Perp[i]
						if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
							Perp[i+1] = E
				tempname = t1
				screen = 4

			if( "Search Centcomm Records" )
				query_type = input("What do you want to search by?", "Search Records", null, null) in query_types

				var/allow_partial = query_types[query_type]

				if( allow_partial )
					if( "Complete" == alert( usr, "Complete or partial string search?", "", "Complete", "Partial" ))
						is_complete = 1
					else
						is_complete = 0
				else
					is_complete = 1

				if( !query_type )
					query_type = sql_sanitize_text( "name" )
					return

				query = input("Search String: ", "Search Records", null, null)  as text|null

				query_type = sql_sanitize_text( query_type )

				if( !query )
					return

				query = sql_sanitize_text( query )

			if("Record Maintenance")
				screen = 2
				active1 = null

			if ("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"])
				if( !istype( R ) || !( R in data_core.general ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in data_core.security)
					active1 = R
					screen = 3

			if ("Print Record")
				if (!( printing ))
					printing = 1
					sleep(50)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
					P.info = "<CENTER><B>Employment Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>\nEmployment/Skills Summary:<BR>\n[]<BR>", active1.fields["name"], active1.fields["id"], active1.fields["sex"], active1.fields["age"], active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"], decode(active1.fields["notes"]))
					else
						P.info += "<B>General Record Lost!</B><BR>"
					P.info += "</TT>"
					P.name = "Employment Record ([active1.fields["name"]])"
					printing = null
//RECORD DELETE
			if ("Delete All Records")
				temp = ""
				temp += "Are you sure you wish to delete all Employment records? This will only remove the record stored on station, CentComm has backups of all employee records.<br>"
				temp += "<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
				temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Purge All Records")
				if(PDA_Manifest.len)
					PDA_Manifest.Cut()
				for(var/datum/data/record/R in data_core.security)
					qdel(R)
				temp = "All Employment records deleted."

			if ("Delete Station Record")
				if (active1)
					temp = "<h5>Are you sure you wish to delete this Employment record? This will only remove the record stored on station, CentComm has backups of all employee records.</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"
//RECORD CREATE
			if ("New Record (General)")
				if(PDA_Manifest.len)
					PDA_Manifest.Cut()
				active1 = CreateGeneralRecord()

//FIELD FUNCTIONS
			if ("Edit Field")
				var/a1 = active1
				switch(href_list["field"])
					if("name")
						if (istype(active1, /datum/data/record))
							var/t1 = sanitizeName(input("Please input name:", "Secure. records", active1.fields["name"], null)  as text)
							if ((!( t1 ) || !length(trim(t1)) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon)))) || active1 != a1)
								return
							active1.fields["name"] = t1
					if("id")
						if (istype(active1, /datum/data/record))
							var/t1 = sanitize(input("Please input id:", "Secure. records", active1.fields["id"], null)  as text)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["id"] = t1
					if("fingerprint")
						if (istype(active1, /datum/data/record))
							var/t1 = sanitize(input("Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null)  as text)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["fingerprint"] = t1
					if("sex")
						if (istype(active1, /datum/data/record))
							if (active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if (istype(active1, /datum/data/record))
							var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["age"] = t1
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if ((istype(active1, /datum/data/record) && L.Find(rank)))
							temp = "<h5>Rank:</h5>"
							temp += "<ul>"
							for(var/rank in joblist)
								temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
					if("species")
						if (istype(active1, /datum/data/record))
							var/t1 = sanitize(input("Please enter race:", "General records", active1.fields["species"], null)  as message)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["species"] = t1

//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if ("Change Rank")
						if (active1)
							if(PDA_Manifest.len)
								PDA_Manifest.Cut()
							active1.fields["rank"] = href_list["rank"]
							if(href_list["rank"] in joblist)
								active1.fields["real_rank"] = href_list["real_rank"]

					if ("Delete Record (ALL) Execute")
						if (active1)
							if(PDA_Manifest.len)
								PDA_Manifest.Cut()
							for(var/datum/data/record/R in data_core.medical)
								if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
									qdel(R)
								else
							qdel(active1)
					else
						temp = "This function does not appear to be working at the moment. Our apologies."

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/employment/proc/authenticate( var/mob/user = usr )
	src.authenticated = null
	rank = null

	if (istype(usr, /mob/living/silicon/ai))
		src.active1 = null
		src.authenticated = user.name
		src.rank = "AI"
	else if (istype(user, /mob/living/silicon/robot))
		src.active1 = null
		src.authenticated = user.name
		var/mob/living/silicon/robot/R = user
		src.rank = R.braintype
	else if (istype(scan, /obj/item/weapon/card/id))
		active1 = null
		if(check_access(scan))
			authenticated = scan.registered_name
			rank = scan.assignment

/obj/machinery/computer/employment/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in data_core.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(first_names_male), pick(first_names_female))] [pick(last_names)]"
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Parolled", "Released")
				if(5)
					R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
					if(PDA_Manifest.len)
						PDA_Manifest.Cut()
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)
