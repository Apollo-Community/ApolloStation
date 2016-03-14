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
	. += "<hr>"

	// Our Contracts
	if(antag.active_contracts.len > 0)
		. += "<h2><span class='white'>Active Contracts</span></h2>"
		. += "<table>"
		for(var/datum/contract/C in antag.active_contracts)
			. += "<tr><table class='outline'>"
			. += "<th width=20%>[C.title]</th>"
			. += "<td width=60%><i>[C.desc]</i></td>"
			. += "<td width=20%>Expires in: [C.formatted_time((C.contract_start + C.time_limit) - world.time)]</td>"
			. += "</table></tr>"
		. += "</table>"

	// Uplink Contracts
	. += "<h2><span class='white'>Available Contracts</span></h2>"
	. += "<table>"
	for(var/datum/contract/C in uplink.contracts - antag.active_contracts)
		. += "<tr><table class='outline'>"
		. += "<th width=20%>[C.title]</th>"
		. += "<td width=40%><i>[C.desc]</i></td>"
		. += "<td width=20%>Expires in: [C.formatted_time((C.contract_start + C.time_limit) - world.time)]</td>"
		. += "<th width=20%>"
		if(C.can_accept(user))
			. += "<a href='byond://?src=\ref[src];tgroup=[tgroup];task=accept_contract\ref[C]'>Accept Contract</a>"
		else
			. += "<i class='red'>Cannot Accept</i>"
		. += "</th>"
		. += "</table></tr>"
	. += "</table>"

	. += "</body></html>"

	menu.set_user(user)
	menu.set_content(.)
	menu.open()

/obj/item/device/uplink/proc/contract_topic(href, href_list, var/mob/user)
	// only task you can perform here is accepting contracts
	var/start = findtext(href_list["task"], "\[")
	var/end = findtext(href_list["task"], "\]")
	var/reference = copytext(href_list["task"], start, end+1)

	for(var/datum/contract/C in uplink.contracts)
		if("\ref[C]" == reference)
			C.start(user)

	contract_menu(user)