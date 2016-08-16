/obj/item/device/uplink/proc/contract_menu(var/mob/user)
	if(!istype(user) || !user.client)	return

	var/tgroup = "contracts"

	var/datum/antagonist/antag = user.mind.antagonist

	. += "<html><head>"
	// shit
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
			. += "<table><center>"
			for(var/datum/contract/C in antag.active_contracts)
				. += "<tr><table class='outline'>"
				. += "<tr><th colspan='3'>[C.title]</th></tr>"
				. += "<tr><td colspan='3'>[C.desc]</td></tr>"
				. += "<tr><td colspan='3'><hr></td></tr>"
				. += "<tr>"
				if(C.time_limit)
					. += "<td>Expires: [worldtime2text(C.contract_start + C.time_limit)]</td>"
				else
					. += "<td>No expiry</td>"
				. += "<td>Reward: $[C.reward]</td>"
				. += "<td>Hirees: [C.workers.len]</td>"
				. += "</tr>"
				. += "<tr><td colspan='3'><hr></td></tr>"
				. += "<tr><td colspan='3'><b>ACCEPTED</b></td></tr>"
				. += "</table></tr>"

				. += "<br>"
			. += "</center></table>"

		if(antag.active_contracts.len > 0)
			. += "<hr>"

		// Our completed contracts
		if(antag.completed_contracts.len > 0)
			. += "<h2><span class='white'>Completed Contracts</span></h2>"
			. += "<table><center>"
			for(var/datum/contract/C in antag.completed_contracts)
				. += "<tr><table class='outline'>"
				. += "<tr><th colspan='3'>[C.title]</th></tr>"
				. += "<tr><td colspan='3'>[C.desc]</td></tr>"
				. += "<tr><td colspan='3'><hr></td></tr>"
				. += "<tr>"
				if(C.time_limit)
					. += "<td>Expires: COMPLETED</td>"
				else
					. += "<td>No expiry</td>"
				. += "<td>Reward: $[C.reward]</td>"
				. += "<td>Hirees: 0</td>"
				. += "</tr>"
				. += "</table></tr>"

				. += "<br>"
			. += "</center></table>"

		if(antag.active_contracts.len > 0 || antag.completed_contracts.len > 0)
			. += "<hr>"

		// Faction Contracts
		var/list/datum/contract/available_contracts = (antag.faction.contracts - antag.active_contracts)
		if(available_contracts.len > 0 && !antag.uplink_blocked)
			. += "<h2><span class='white'>Available Contracts</span></h2>"
			. += "<table><center>"
			for(var/datum/contract/C in available_contracts)
				if(C.can_accept(user))
					. += "<tr><table class='outline'>"
					. += "<tr><th colspan='3'>[C.title]</th></tr>"
					. += "<tr><td colspan='3'>[C.desc]</td></tr>"
					. += "<tr><td colspan='3'><hr></td></tr>"
					. += "<tr>"
					if(C.time_limit)
						. += "<td>Expires: [worldtime2text(C.contract_start + C.time_limit)]</td>"
					else
						. += "<td>No expiry</td>"
					. += "<td>Reward: $[C.reward]</td>"
					. += "<td>Hirees: [C.workers.len]</td>"
					. += "</tr>"
					. += "<tr><td colspan='3'><hr></td></tr>"
					. += "<tr><td colspan='3'><center><a style='padding: 0% 10% 0% 10%' href='byond://?src=\ref[src];tgroup=[tgroup];task=accept_contract\ref[C]'>Accept Contract</a></center></td></tr>"
					. += "</table></tr>"

					. += "<br>"
			. += "</center></table>"
		else
			. += "<center><h2><span class='white'>No Available Contracts</span></h2></center>"
			. += "<center><span class='white'>No contracts are currently available from your employer.</span></center>"
	else
		. += "<center><h2><span class='white'>No Available Contracts</span></h2></center>"
		. += "<center><span class='white'>No contracts are currently available from your employer.</span></center>"

	. += "</body></html>"

	menu.set_user( user )
	menu.set_content( replacetext( ., "\improper", "" ))
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
