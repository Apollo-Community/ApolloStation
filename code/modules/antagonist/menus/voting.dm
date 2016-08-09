/datum/controller/gameticker/proc/open_antag_vote(var/mob/user, var/datum/browser/menu, var/list/datum/mind/antags)
	if( !antags )
		testing( "No antags list" )
		return

	// this may seem backwards, but this is done so that antagonist factions that aren't part of the syndicate can show up
	var/list/datum/faction/factions = list()
	for( var/datum/mind/M in antags )
		if( M == user.mind ) // no voting for yourself
			antags -= M
			continue
		if( !(M.antagonist.faction in factions) )
			factions += M.antagonist.faction

	if( !antags.len )
		user << "You are unable to vote for antagonist performances since you were the only antagonist this round."
		return

	. += "<html><head>"
	. += {"<style>
		body{
			background-color: #8f1414;
			background-image: url('uiBackground-Syndicate.png');
			background-position: 50% 0;
			background-repeat: repeat-x;
		}

		.white{
			color: #ffffff;
		}
		</style>"}
	. += "</head><body>"

	. += "<h1><span class='white'>Antagonist Commendation</span></h1>"
	. += "<span class='white'>Commend an antagonist you think played their role well this round. Commending antagonists makes them more likely to be picked for antagonist roles. It may also allow them to become a persistant antagonist that can appear every round and take on more demanding contracts. If you don't want to commend anyone, you may close the window.</span>"
	. += "<hr>"

	for( var/datum/faction/F in factions )
		. += "<h2><span class='white'>[F.name] Agents</span></h2>"
		for( var/datum/mind/M in F.members )
			if( M in antags )
				var/role = M.assigned_role == "MODE" ? "\improper[M.special_role]" : "\improper[M.assigned_role]"
				. += "<span class='white'><B>[M.name]</B> (<B>[role]</B>)</span> | "
				. += "<b><a href='byond://?src=\ref[ticker];task=[M.key]'>Commend</a></b>"
				. += "<br>"

	. += "</body></html>"

	menu.set_user( user )
	menu.set_content( replacetext( ., "\improper", "" ))
	menu.open()
	testing( "Opened antag vote for [user.client]" )

/datum/controller/gameticker/Topic(href, href_list)
	//if( ticker.restart_called )	return // too late

	var/datum/mind/antag = null
	for( var/datum/mind/M in minds )
		if( M.key == href_list["task"] )
			antag = M
			break

	var/client/C = antag.current.client
	if( !C )	return

	if( !C.character_tokens["Antagonist"] )
		C.character_tokens["Antagonist"] = 0
	C.character_tokens["Antagonist"] += 0.03125 // 32 commendations = 1 token

	var/progress = C.character_tokens["Antagonist"] - round(C.character_tokens["Antagonist"])
	log_debug("[C.key] has received an antagonist commendation from [usr].")
	antag.current << "<span class='notice'>You have received an antagonist commendation!</span>"
	antag.current << "<span class='notice'>You are now <B>[progress * 100]%</B> on the way to your next antagonist token.</span>"

	usr << browse(null, "window=antag_vote") // close the window
