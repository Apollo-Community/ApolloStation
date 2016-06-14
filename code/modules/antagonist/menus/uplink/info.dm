/obj/item/device/uplink/proc/info_menu(var/mob/user, var/list/info)
	if(!istype(user) || !user.client || !info)	return

	var/tgroup = "info"

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

		.green{
			font-weight: bold;
			color: #00ff00;
		}

		.orange{
			font-weight: bold;
			color: #d09000;
		}

		.infodiv{
			background: #000000;
			color: #ffffff;
			border: 1px solid #40628a;
			padding: 4px;
			margin: 3px 0;
			overflow-x: hidden;
			overflow-y: auto;
		}
		</style>"}
	. += "</head><body><center>"

	. += "<b><a href='byond://?src=\ref[src];tgroup=switch_menu;task=contract_menu'>Contracts</a></b>"
	. += " - <b><a href='byond://?src=\ref[src];tgroup=switch_menu;task=buy_menu'>Equipment</a></b>"
	. += " - <b>Information</b>"
	. += " - <b><a href='byond://?src=\ref[src];tgroup=close'>Close</a></b>"
	. += "<hr></center>"

	. += "<h2><span class='white'>Information Record[info["exists"] ? "" : "s"]</span></h2>"
	if(!info["exists"])
		. += "<span class='white'>Select a Record</span>"
	else
		. += "<a href='byond://?src=\ref[src];tgroup=[tgroup];task=return'>Return</a>"
	. += "<br><br>"

	if(info["exists"])
		. += "<div class='infodiv'>"
		. += "<span class='green'>Name:		</span> <span class='orange'>[info["name"]]</span><br>"
		. += "<span class='green'>Sex:			</span> <span class='orange'>[info["sex"]]</span><br>"
		. += "<span class='green'>Species:		</span> <span class='orange'>[info["species"]]</span><br>"
		. += "<span class='green'>Age:			</span> <span class='orange'>[info["age"]]</span><br>"
		. += "<span class='green'>Rank:		</span> <span class='orange'>[info["rank"]]</span><br>"
		. += "<span class='green'>Home System:	</span> <span class='orange'>[info["home_system"]]</span><br>"
		. += "<span class='green'>Citizenship:	</span> <span class='orange'>[info["citizenship"]]</span><br>"
		. += "<span class='green'>Faction:		</span> <span class='orange'>[info["faction"]]</span><br>"
		. += "<span class='green'>Religion:	</span> <span class='orange'>[info["religion"]]</span><br>"
		. += "<span class='green'>Fingerprint:	</span> <span class='orange'>[info["fingerprint"]]</span><br>"
		. += "<br>"

		. += "<span class='green'>Additional information:</span><br>"
		. += "<span class='orange'>[info["exploit_record"]]</span>"
		. += "</div>"
	else
		for(var/datum/data/record/L in sortRecord(data_core.locked))
			. += "<a href='byond://?src=\ref[src];tgroup=[tgroup];task=[L.fields["id"]]'>[L.fields["name"]]</a>"

	. += "</body></html>"

	menu.set_user( user )
	menu.set_content( replacetext( ., "\improper", "" ))
	menu.open()

/obj/item/device/uplink/proc/info_topic(href, href_list, var/mob/user)
	var/list/info = list()
	info["exists"] = 0

	if(href_list["return"])
		info_menu(user, info)
		return 1

	for(var/datum/data/record/L in data_core.locked)
		if(href_list["task"] == L.fields["id"])
			info["exploit_record"] = html_encode(L.fields["exploit_record"])	// Change stuff into html
			info["exploit_record"] = replacetext(info["exploit_record"], "\n", "<br>")	// change line breaks into <br>
			info["name"] =  html_encode(L.fields["name"])
			info["sex"] =  html_encode(L.fields["sex"])
			info["age"] =  html_encode(L.fields["age"])
			info["species"] =  html_encode(L.fields["species"])
			info["rank"] =  html_encode(L.fields["rank"])
			info["home_system"] =  html_encode(L.fields["home_system"])
			info["citizenship"] =  html_encode(L.fields["citizenship"])
			info["faction"] =  html_encode(L.fields["faction"])
			info["religion"] =  html_encode(L.fields["religion"])
			info["fingerprint"] =  html_encode(L.fields["fingerprint"])

			info["exists"] = 1

	info_menu(user, info)
	return 1