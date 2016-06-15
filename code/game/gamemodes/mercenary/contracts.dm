// mercenary gamemode contracts

/datum/contract/mercenary
	title = "!BASE! Merc contract"
	desc = "Mercenaries' objective"
	time_limit = 0

	affilation = list( "Gorlex Mercenaries" )

/datum/contract/mercenary/end( var/success = 0, var/mob/living/worker )
	..( success, worker )
	ticker.mode.check_win()

// BEGIN WITH ACTUAL MERCENARY CONTRACTS & STUFF //

// TAKE THE BIG MEN FOR A RIDE BACK TO THE MERC BASE
/datum/contract/mercenary/kidnap
	title = "Kidnap the Big Man"
	desc = "tuff&ruff 'em"
	time_limit = 1800

	var/datum/mind/target = null

/datum/contract/mercenary/kidnap/New()
	. = ..()
	if( !. )	return

	for( var/datum/mind/M in ticker.minds )
		if( !M.antagonist && ( M.assigned_role in list("Captain", "Head of Security")))
			target = M
			break

	if( !target )
		qdel( src )
		return 0

	set_details()

/datum/contract/mercenary/kidnap/set_details()
	title = "Kidnap [target.current.real_name], the [target.assigned_role]"
	desc = "[target.current.real_name] has intel crucial to Syndicate efforts. Your objective is to kidnap them and bring them back to the base. Make sure they're brought back alive."
	informal_name = "Kidnap [target.current.real_name], the [target.assigned_role]"

/datum/contract/mercenary/kidnap/check_completion()
	if( target.current.stat & DEAD || issilicon( target.current ) || isbrain( target.current ))
		end(0)
	if( get_area( target.current ) == locate( /area/syndicate_mothership )) // simple as that
		end(1)


// STEAL SUPER SECRET DOCUMENTS
/datum/contract/mercenary/document
	title = "Retrieve Secret Documents"
	desc = "get the biggest guns you can, guys, we're stealing a piece of paper"

	var/obj/item/weapon/paper/merc/document = null

/datum/contract/mercenary/document/New()
	. = ..()
	if( !. )	return


	// for some reason locate() doesn't work
	for(var/area/A in all_areas)
		if(istype(A, /area/bridge))
			var/obj/O = locate(/obj/item/weapon/storage/secure/briefcase) in A
			document = new(O)
			break

	if( isnull(document) )
		qdel( src )
		return 0

	set_details()

/datum/contract/mercenary/document/Destroy()
	if( document )
		qdel(document)

/datum/contract/mercenary/document/set_details()
	desc = "Very reliable intel has led us to believe there's a top secret document on [station_name()] with some juicy information. Bring it back to the base."
	informal_name = "Steal the top secret documents"

/datum/contract/mercenary/document/check_completion()
	if( !document || get_area(document) == locate(/area/space) ) // destroying the document is a big no-no
		end(1)
	if( get_area(document) == locate( /area/syndicate_mothership ))
		end(1)

