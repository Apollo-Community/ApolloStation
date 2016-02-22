/datum/virtual_paperwork
	var/datum/character/recipient // The recipient of this new record
	var/obj/item/weapon/paper/paper // The paper to be put in their records
	var/record_title // The title of the record, if any
	var/record_type = "general" // general, security, or medical, what this paper goes into

/datum/virtual_paperwork/New( var/datum/character/C, var/obj/item/weapon/paper/P, var/type, var/title  )
	if( !istype( C ))
		qdel( src )
		return

	if( !istype( P ))
		qdel( src )
		return

	if( !type )
		qdel( src )
		return

	recipient = C
	paper = P
	record_type = type

	if( !title )
		record_title = "[paper.name]"
	else
		record_title = title

// This is the proc used to fill out the paperwork
/datum/virtual_paperwork/proc/fillPaperwork( var/user )
	paper.WriteWindow( user )

// This is the proc used to file the record
/datum/virtual_paperwork/proc/filePaperwork( var/user )
	return recipient.addRecordNote( "[record_type]", paper.info, "[record_title]" )
