/obj/item/device/uplink/proc/contract_menu(var/mob/user)
	if(!istype(user) || !user.client)	return

	var/tgroup = "contracts"

	var/datum/antagonist/antag = user.mind.antagonist

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

		.red{
			color: #9f2828;
		}
		</style>"}
	. += "</head><body><center>"

	. += "<b>Contracts</b>"
	. += " - <b><a href='byond://?src=\ref[src];tgroup=switch_menu;task=buy_menu'>Equipment</a></b>"
	. += " - <b><a href='byond://?src=\ref[src];tgroup=switch_menu;task=info_menu'>Information</a></b>"
	. += " - <b><a href='byond://?src=\ref[src];tgroup=close'>Close</a></b>"
	. += "<hr></center>"

	if(antag)
		// Our Contracts
		if(antag.active_contracts.len > 0)
			. += "<h2><span class='white'>Active Contracts</span></h2>"
			. += "<table>"
			for(var/datum/contract/C in antag.active_contracts)
				. += "<tr><table class='outline'><center>"
				. += "<th width=20%>[C.title]</th>"
				. += "<td width=60%><i>[C.desc]</i></td>"
				if(C.time_limit)
					. += "<td width=20%>Expires: [worldtime2text(C.contract_start + C.time_limit)]</td>"
				else
					. += "<td width=20%>No expiry</td>"
				. += "</center></table></tr>"
			. += "</table>"

		// Our completed contracts
		if(antag.completed_contracts.len > 0)
			. += "<h2><span class='white'>Completed Contracts</span></h2>"
			. += "<table>"
			for(var/datum/contract/C in antag.completed_contracts)
				. += "<tr><table class='outline'><center>"
				. += "<th width=20%>[C.title]</th>"
				. += "<td width=80%><i>[C.desc]</i></td>"
				. += "</center></table></tr>"
			. += "</table>"

		if(antag.active_contracts.len > 0 || antag.completed_contracts.len > 0)
			. += "<hr>"

		// Faction Contracts
		var/list/datum/contract/available_contracts = (antag.faction.contracts - antag.active_contracts)
		if(available_contracts.len > 0 && !antag.uplink_blocked)
			. += "<h2><span class='white'>Available Contracts</span></h2>"
			. += "<table><center>"
			for(var/datum/contract/C in available_contracts)
				. += "<tr><table class='outline'>"
				. += "<th width=20%>[C.title]</th>"
				. += "<td width=40%><i>[C.desc]</i></td>"
				. += "<td width=20%>Expires: [worldtime2text(C.contract_start + C.time_limit)]</td>"
				. += "<th width=20%>"
				if(C.can_accept(user))
					. += "<a href='byond://?src=\ref[src];tgroup=[tgroup];task=accept_contract\ref[C]'>Accept Contract</a>"
				else
					. += "<i class='red'>Cannot Accept</i>"
				. += "</th>"
				. += "</table></tr>"
			. += "</center></table>"
		else
			. += "<center><h2><span class='white'>No Available Contracts</span></h2></center>"
			. += "<center><span class='white'>No contracts are currently available from your employer.</span></center>"

	. += "</body></html>"

	menu.set_user(user)
	menu.set_content(.)
	menu.open()

/obj/item/device/uplink/proc/contract_topic(href, href_list, var/mob/user)
	// only task you can perform here is accepting contracts
	var/start = findtext(href_list["task"], "\[")
	var/end = findtext(href_list["task"], "\]")
	var/reference = copytext(href_list["task"], start, end+1)

	for(var/datum/contract/C in user.mind.antagonist.faction.contracts)
		if("\ref[C]" == reference)
			C.start(user)

	contract_menu(user)