/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/datum/character/character
	var/datum/character/original_character

	var/datum/browser/memory_browser

	var/active = 0

	var/memory

	var/assigned_role
	var/special_role

	var/role_alt_title

	var/datum/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/antagonist/antagonist
	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder

	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	New(var/key)
		src.key = key

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	proc/transfer_to(mob/living/new_character)
		if(!istype(new_character))
			world.log << "## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a [new_character], which is not a /mob/living."
			return
		if(current)					//remove ourself from our old body's mind variable
			if(changeling)
				current.remove_changeling_powers()
				current.verbs -= /datum/changeling/proc/EvolutionMenu
			current.mind = null

			nanomanager.user_transferred(current, new_character) // transfer active NanoUI instances to new user
		if(new_character.mind)		//remove any mind currently in our new body's mind variable
			new_character.mind.current = null

		current = new_character		//link ourself to our new body
		new_character.mind = src	//and link our new body to ourself

		if( !character )
			if( istype( new_character, /mob/living/carbon/human ))
				var/mob/living/carbon/human/H = new_character
				character = H.character

		if(changeling)
			new_character.make_changeling()

		if(active)
			new_character.key = key		//now transfer the key to link the client to our new body

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		if(objectives.len>0)
			output += "<HR><B>Objectives:</B>"

			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		recipient << browse(output,"window=memory")

	proc/edit_memory()
		if(!ticker || !ticker.mode)
			alert("Not before round-start!", "Alert")
			return

		// 400 + 17 for the scroll bar
		memory_browser = new(null, "antagpanel_[key]", "Antagonist Panel", 417, 500)

		var/mob/living/carbon/human/H = current
		// START NEW ANTAGONIST SYSTEM PANEL //
		. = "<table><tr><td>"
		. += "<font size=3>[name] - @[key]</font>"
		. += "<hr>"
		. += "</td></tr>"

		. += "<tr><td><table class='outline'>"
		. += "<tr><th align='left' style='padding-left: 6px'><b>New Antag System</b></th></tr>"

		// COMMANDS
		if(antagonist)
			. += "<tr><td><table>"

			. += "<tr>"
			. += "<td>Antagonist type: <a href='byond://?src=\ref[src];command=antag_type'><b>[antagonist.name]</b></a></td>"
			. += "<td>Persistent: <b>[istype(antagonist, /datum/antagonist/traitor/persistant) ? "Yes" : "No"]</b></td>"
			. += "</tr>"
			. += "<tr>"
			. += "<td>Faction: <a href='byond://?src=\ref[src];command=antag_faction'><b>[antagonist.faction.name]</b></a></td>"
			. += "<td>Notoriety: <a href='byond://?src=\ref[src];command=edit_notoriety'>[antagonist.notoriety]</a></td>"
			. += "</tr>"

			. += "</table></td></tr>"

			. += "<tr><td><hr></td></tr>"

			. += "<tr><td><table>"

			. += "<tr><td>General</td></tr>"
			. += "<tr><td><a href='byond://?src=\ref[src];command=toggle_uplink'>[antagonist.uplink_blocked ? "Enable Uplink" : "Disable Uplink"]</a> | <a href='byond://?src=\ref[src];command=random_contract'>Random contract</a> | <a href='byond://?src=\ref[src];command=custom_contract'>Custom contract</a></td></tr>"

			. += "<tr><td>Fun</td></tr>"
			. += "<tr><td><a href='byond://?src=\ref[src];command=edit_money'>Set cash</a> | <a href='byond://?src=\ref[src];command=buy_random'>Buy random</a> | <a href='byond://?src=\ref[src];command=buy_random_faction'>Buy random (faction)</a> | <a href='byond://?src=\ref[src];command=randomize_char'>Randomize character</a> | <a href='byond://?src=\ref[src];command=save_char'>Save character</a> | <a href='byond://?src=\ref[src];command=give_token'>Give token</a></td></tr>"

			if(check_rights(R_DEBUG))
				. += "<tr><td>Debug</td></tr>"
				. += "<tr><td><a href='byond://?src=\ref[src];command_debug=equip'>Equip</a> | <a href='byond://?src=\ref[src];command_debug=setup'>Force setup</a> | <a href='byond://?src=\ref[src];command_debug=greet'>Greet</a> | <a href='byond://?src=\ref[src];command_debug=commend'>Commend</a></td></tr>"

			. += "</table></td></tr>"
		else
			. += "<tr><td><table>"
			. += "<tr><td>Antagonist type: <a href='byond://?src=\ref[src];command=antag_type'><b>Not antagonist</b></a></td></tr>"
			. += "</table></td></tr>"

		// CONTRACTS
		if(antagonist)
			. += "<tr><td><hr></td></tr>"

			. += "<tr><td><table>"
			. += "<tr><td>Active Contracts</td></tr>"
			. += "<tr><td>"
			if(antagonist.active_contracts.len)
				for(var/datum/contract/contract in antagonist.active_contracts)
					. += "<table><tr>"
					. += "<th width=70%>[contract.informal_name]</th>"
					. += "<td><a href='byond://?src=\ref[src];command_contract=fail;contract=\ref[contract]'>Fail</a></td>"
					. += "<td><a href='byond://?src=\ref[src];command_contract=complete;contract=\ref[contract]'>Complete</a></td>"
					. += "</tr></table>"
			else
				. += "<table><tr><td>No active contracts</td></tr></table>"

			. += "</td></tr>"
			. += "</table></td></tr>"

			. += "<tr><td><table>"
			. += "<tr><td>Completed Contracts</td></tr>"
			. += "<tr><td>"

			if(antagonist.completed_contracts.len)
				for(var/datum/contract/C in antagonist.completed_contracts)
					. += "<table><tr>"
					. += "<th>[C.informal_name]</th>"
					. += "</tr></table>"
			else
				. += "<table><tr><td>No completed contracts</td></tr></table>"

			. += "</td></tr>"
			. += "</table></td></tr>"

		. += "</table></td></tr>"
		// END NEW ANTAGONIST SYSTEM PANEL //

		// START OLD ANTAGONIST SYSTEM PANEL //
		. += "<tr><td><table class='outline'>"
		. += "<tr><th align='left' style='padding-left: 6px'><b>Old Antag System</b></th></tr>"

		. += "<tr><td><table>"
		. += "<tr><td>General</td></tr>"
		. += "<tr>"
		. += "<td>Loyalty implant:</td>"

		// LOYALTY IMPLANTS
		if(H.is_loyalty_implanted(H))
			. += "<td>Implanted | <a href='byond://?src=\ref[src];command_old=remove_implant'>Not implanted</a></td>"
		else
			. += "<td><a href='byond://?src=\ref[src];command_old=give_implant'>Implanted</a> | Not implanted</td>"

		. += "</tr></table>"
		. += "</td></tr>"

		. += "<tr><td><hr></td></tr>"

		. += "<tr><td><table>"
		. += "<tr><td>Antagonists</td></tr>"

		. += "<tr>"
		. += "<td>Revolutionary:</td>"

		// REVOLUTIONARY
		if(src in ticker.mode.head_revolutionaries)
			. += "<td><a href='byond://?src=\ref[src];command_old=rev_employee'>Employee</a> | <a href='byond://?src=\ref[src];command_old=rev_rev'>Rev</a> | Head Rev</td>"
		else if(src in ticker.mode.revolutionaries)
			. += "<td><a href='byond://?src=\ref[src];command_old=rev_employee'>Employee</a> | Rev | <a href='byond://?src=\ref[src];command_old=rev_head'>Head Rev</a></td>"
		else
			. += "<td>Employee | <a href='byond://?src=\ref[src];command_old=rev_rev'>Rev</a> | <a href='byond://?src=\ref[src];command_old=rev_head'>Head Rev</a></td>"

		. += "</tr>"
		. += "<tr>"
		. += "<td>Cultist:</td>"

		// CULTIST
		if(src in ticker.mode.cult)
			. += "<td><a href='byond://?src=\ref[src];command_old=cult_employee'>Employee</a> | Cultist | <a href='byond://?src=\ref[src];command_old=cult_tome'>Give tome</a></td>"
		else
			. += "<td>Employee | <a href='byond://?src=\ref[src];command_old=cult_cultist'>Cultist</a></td>"

		. += "</tr>"
		. += "<tr>"
		. += "<td>Changeling:</td>"

		// CHANGELING
		if(src in ticker.mode.changelings)
			. += "<td><a href='byond://?src=\ref[src];command_old=ling_employee'>Employee</a> | Changeling</td>"
		else
			. += "<td>Employee | <a href='byond://?src=\ref[src];command_old=ling_changeling'>Changeling</a></td>"

		. += "</tr></table>"
		. += "</td></tr>"

		. += "</table></td></tr>"
		// END OLD ANTAGONIST SYSTEM PANEL //

		// START OBJECTIVES PANEL //
		. += "<tr><td><table class='outline'>"
		. += "<tr><th align='left' style='padding-left: 6px'><b>Objectives</b></th></tr>"

		. += "<tr><td><table>"
		. += "<tr><td>Commands</td></tr>"
		. += "<tr><td><a href='byond://?src=\ref[src];command_objective=add'>Add objective</a> | <a href='byond://?src=\ref[src];command_objective=announce'>Announce objectives</a></td></tr>"
		. += "</table></td></tr>"

		. += "<tr><td><hr></td></tr>"

		. += "<tr><td><table>"
		. += "<tr><td>Current objectives</td></tr>"
		. += "<tr><td>"

		// OBJECTIVES LIST
		if(objectives.len)
			for(var/datum/objective/objective in objectives)
				. += "<table><tr>"
				. += "<td width=60%>[objective.explanation_text]</td>"
				. += "<td> <a href='byond://?src=\ref[src];command_objective=edit;objective=\ref[objective]'>Edit</a> | <a href='byond://?src=\ref[src];command_objective=delete;objective=\ref[objective]'>Delete</a> | <a href='byond://?src=\ref[src];command_objective=toggle_completion;objective=\ref[objective]'><font color=[objective.completed ? "blue" : "yellow"]>Toggle completion</font></a></td>"
				. += "</tr></table>"
		else
			. += "<table><tr><td>No objectives</td></tr></table>"

		. += "</td></tr></table>"
		. += "</td></tr></table>"

		. += "</td></tr>"
		. += "</table>"
		// END OBJECTIVES PANEL //
			
		memory_browser.set_user( usr )
		memory_browser.set_content( replacetext( ., "\improper", "" ) )
		memory_browser.open()


	Topic(href, href_list)
		if( !check_rights( R_ADMIN ))	return

		// NEW ANTAG SYSTEM STUFF

		// GENERAL COMMANDS
		if( href_list["command"] )
			if( !current )	return
			switch( href_list["command"] )
				if( "antag_type" ) // Change antagonist type
					var/new_type = input("Select new antagonist type", "Antagonist type edit", "[antagonist ? "[antagonist.type]" : ""]") in (subtypes(/datum/antagonist) + list("De-antag"))
					if( !new_type || alert("Are you sure you want to make [current.name] a [new_type] antagonist? This may remove contracts/faction, etc.",,"Yes","No")=="No" )
						return

					var/datum/faction/fact = faction_controller.get_syndie_faction(src)
					if( antagonist )
						fact = antagonist.faction // save this
						current << "<b><font size=3 color=red>You are no longer a [antagonist.name]!</font></b>"
						qdel(antagonist)

					if(new_type == "De-antag")
						message_admins("[usr] has removed [current.name]'s antagonist status")
						return

					antagonist = new new_type(src)
					antagonist.faction = fact
					antagonist.setup()

					message_admins("[usr] has made [current.name] ([key]) an antagonist of type [new_type]")

				if( "antag_faction" ) // Edit the syndicate faction of the antagonist
					var/list/names = list()
					for( var/datum/faction/F in faction_controller.factions )
						names += F.name

					var/new_faction = input("Select a new faction", "Faction edit") in names
					if( !new_faction || alert("Are you sure you want to set [current.name]'s faction to [new_faction]? This will remove all their active contracts.",,"Yes","No")=="No" )
						return

					var/datum/faction/faction = faction_controller.get_faction(new_faction)
					if( faction )
						var/obj/item/device/pda/P = locate() in current.contents
						var/obj/item/device/uplink/U = P.hidden_uplink
						current << "<b><font size=3 color=red></font>You no longer work for [antagonist.faction.name]</b>"

						if( U )
							if( U.ItemsCategory["[antagonist.faction.name] Equipment"] )
								U.ItemsCategory.Cut()
								U.ItemsCategory = ticker.mode.uplink_items
								var/datum/nano_item_lists/IL = U.generate_item_lists()
								U.nanoui_items = IL.items_nano
								U.ItemsReference = IL.items_reference

						antagonist.active_contracts.Cut()
						antagonist.faction = faction

						current << "<b><font size=3 color=red>You are now an agent of [faction.name]</font></b>"
						message_admins("[usr] has set [current.name]'s ([key]) faction to [faction.name]")

				if( "edit_notoriety" ) // Edit the amount of notoriety a character has (FOR THE ORIGINAL CHARACTER TOO!)
					var/datum/character/char = (isnull(original_character) ? character : original_character)

					var/new_notoriety = input("New notoriety amount", "Notoriety edit", char.antag_data["notoriety"]) as num|null
					antagonist.notoriety = new_notoriety

					character.antag_data["notoriety"] = new_notoriety
					if( original_character )
						original_character.antag_data["notoriety"] = new_notoriety

					message_admins("[usr] has set [current.name]'s ([key]) notoriety to [new_notoriety]")

				// GENERAL COMMANDS

				if( "toggle_uplink" ) // Disables access to the contract board & market
					antagonist.uplink_blocked = !antagonist.uplink_blocked

				if( "random_contract" ) // Assigns the antagonist a random contract from their faction
					var/list/datum/contract/contracts = antagonist.faction.contracts.Copy()
					for( var/datum/contract/C in contracts )
						if( C in antagonist.active_contracts || !C.can_accept( current ) )
							contracts -= C

					var/datum/contract/chosen = pick(contracts)
					chosen.start( current )

					current << "<b><font size=3 color=red>You have been assigned a contract.</font></b>"
					current << "<B>[chosen.title]</B>\n<I>[chosen.desc]</I>\nYou have until [worldtime2text(chosen.contract_start + chosen.time_limit)], station time to complete the contract."

				if( "custom_contract" ) // Make a custom contract
					var/datum/contract/custom/custom = new( antagonist.faction )

					custom.title = sanitize( input( "Title of the contract", "Custom contract title", "" ))
					custom.desc = sanitize( input( "Description of the contract", "Custom contract description", "" ))
					custom.informal_name = sanitize( input( "Short description of the contract objective", "Custom contract informal name", "" ))

					custom.time_limit = input( "Time limit in seconds", "Time limit", "" ) as num|null
					if( custom.time_limit )
						custom.time_limit *= 10
						custom.contract_start = world.time
						if( contract_ticker )
							contract_ticker.contracts += custom
					custom.reward = input( "Monetary reward in $$$", "Reward", "" ) as num|null

					custom.start( current )

					usr << "<span class='notice'>Custom contract created successfully!</span>"
					current << "<b><font size=3 color=red>You have been assigned a contract.</font></b>"
					current << "<B>[custom.title]</B>\n<I>[custom.desc]</I>\nYou have until [worldtime2text(world.time + custom.time_limit)], station time to complete the contract."

				// FUN COMMANDS

				if( "edit_money" ) // Edit the antag's cash reserve
					var/datum/money_account/M
					for(var/datum/money_account/D in all_money_accounts)
						if(D.owner_name == current.real_name)
							M = D

					if( !M )	return

					var/cash = input( "New balance", "Edit money", "" ) as num|null
					if( cash )
						M.money = cash
						message_admins( "[usr] has set [current.name]'s cash to [cash]" )

				if( "buy_random" ) // Forces the antagonist to buy a random item from the uplink
					var/obj/item/device/pda/P = locate() in current.contents
					var/obj/item/device/uplink/U = P.hidden_uplink
					if( !U )	return

					U.buy_topic( "", list( "task" = "random" ), current, 1 )

				if( "buy_random_faction" ) // Forces the antagonist to buy a random faction item from the uplink
					var/obj/item/device/pda/P = locate() in current.contents
					var/obj/item/device/uplink/U = P.hidden_uplink
					if( !U )	return

					if( !U.ItemsCategory["[antagonist.faction.name] Equipment"] )
						usr << "<span class='notice'>[current.name] belongs to a faction that has no faction-specific equipment!</span>"
						return

					var/datum/uplink_item/UI = pick(U.ItemsCategory["[antagonist.faction.name] Equipment"])
					U.buy_topic( "", list( "task" = "\ref[UI]" ), current, 1 )

				if( "randomize_char" ) // Randomizes the antagonist character
					antagonist.randomize_character()

					character.copy_to( current )
					current.fully_replace_character_name( current.name, character.name )

				if( "save_char" ) // Saves the antagonist's character. Useful is somebody got attached to their randomized character
					if( character.saveCharacter() )
						message_admins("[usr] initiated a character save for [key]. Their antagonist character was saved successfully")
						return
					message_admins("[usr] initiated a character save for [key]. Their antagonist character couldn't be saved!")

				if( "give_token" ) // Not exactly "fun", but it grants the player an antagonist token
					var/client/C = current.client
					if( !C )	return

					if( !C.character_tokens["Antagonist"] )
						C.character_tokens["Antagonist"] = 0
					C.character_tokens["Antagonist"] += 1
					message_admins("[usr] has given [key] an antagonist token.")

					current << "<span class='notice'>You have been awarded an antagonist token!</span>"

		// DEBUG COMMANDS
		if( href_list["command_debug"] )
			switch( href_list["command_debug"] )
				if( "equip" ) // Calls equip()
					antagonist.equip()

				if( "setup" ) // Calls setup()
					antagonist.setup()

				if( "greet" ) // Calls greet()
					antagonist.greet()

				if( "commend" ) // Commends the antagonist once
					var/client/C = current.client
					if( !C )	return

					if( !C.character_tokens["Antagonist"] )
						C.character_tokens["Antagonist"] = 0
					C.character_tokens["Antagonist"] += 0.03125 // 32 commendations = 1 token

					var/progress = C.character_tokens["Antagonist"] - round(C.character_tokens["Antagonist"])
					log_debug("[usr] has commended [key] as an antagonist via admin command.")
					message_admins("[usr] has commended [key] as an antagonist.")
					current << "<span class='notice'>You have received an antagonist commendation!</span>"
					current << "<span class='notice'>You are now <B>[progress * 100]%</B> on the way to your next antagonist token.</span>"

		// CONTRACT COMMANDS
		if( href_list["command_contract"] )
			var/datum/contract/contract = locate(href_list["contract"]) in antagonist.faction.contracts
			if( !contract )	return
			switch( href_list["command_contract"] )
				if( "fail" ) // Fails the contract immediately
					if( !current )	return
					if( contract.workers.len > 1 )
						if( alert("Are you sure you want to end this contract? It will end the contract for all antagonists who have accepted it, not only the chosen player!",,"Yes","No")=="No" )
							return

					contract.end(0)

				if( "complete" ) // Forces completion of the contract in the antagonist's favor
					if( !current )	return
					if( contract.workers.len > 1 )
						if( alert("Are you sure you want to end this contract? It will end the contract for all antagonists who have accepted it, not only the chosen player!",,"Yes","No")=="No" )
							return

					contract.end(1, current)

		// OBJECTIVE STUFF & COMMANDS
		// mess
		if( href_list["command_objective"] )
			if( href_list["command_objective"] == "announce" ) // Announce objectives
				var/obj_count = 1
				current << "<span class='notice'>Your current objectives:</span>"
				for(var/datum/objective/objs in objectives)
					current << "<B>Objective #[obj_count]</B>: [objs.explanation_text]"
					obj_count++

			if( href_list["command_objective"] == "add" || href_list["command_objective"] == "edit")
				var/datum/objective/objective
				var/objective_pos
				var/def_value

				if( href_list["command_objective"] == "edit" )
					objective = locate(href_list["objective"])
					if (!objective) return
					objective_pos = objectives.Find(objective)

					//Text strings are easy to manipulate. Revised for simplicity.
					var/temp_obj_type = "[objective.type]"//Convert path into a text string.
					def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
					if(!def_value)//If it's a custom objective, it will be an empty string.
						def_value = "custom"

				var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "block", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "custom")
				if( !new_obj_type )	return

				var/datum/objective/new_objective = null

				switch( new_obj_type )
					if( "assassinate", "block", "debrain", "harm", "brig" )
						//To determine what to name the objective in explanation text.
						var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
						var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
						var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

						var/list/possible_targets = list("Free objective")
						for(var/datum/mind/possible_target in ticker.minds)
							if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
								possible_targets += possible_target.current

						var/mob/def_target = null
						var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
						if (objective&&(objective.type in objective_list) && objective:target)
							def_target = objective:target.current

						var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
						if (!new_target) return

						var/objective_path = text2path("/datum/objective/[new_obj_type]")
						if (new_target == "Free objective")
							new_objective = new objective_path
							new_objective.owner = src
							new_objective:target = null
							new_objective.explanation_text = "Free objective"
						else
							new_objective = new objective_path
							new_objective.owner = src
							new_objective:target = new_target:mind
							//Will display as special role if the target is set as MODE. Ninjas/commandos/nuke ops.
							new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

					if( "download", "capture", "absorb" )
						var/def_num
						if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
							def_num = objective.target_amount

						var/target_number = input("Input target number:", "Objective", def_num) as num|null
						if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
							return

						switch(new_obj_type)
							if("download")
								new_objective = new /datum/objective/download
								new_objective.explanation_text = "Download [target_number] research levels."
							if("capture")
								new_objective = new /datum/objective/capture
								new_objective.explanation_text = "Accumulate [target_number] capture points."
							if("absorb")
								new_objective = new /datum/objective/absorb
								new_objective.explanation_text = "Absorb [target_number] compatible genomes."
						new_objective.owner = src
						new_objective.target_amount = target_number

					if( "steal" )
						if (!istype(objective, /datum/objective/steal))
							new_objective = new /datum/objective/steal
							new_objective.owner = src
						else
							new_objective = objective
						var/datum/objective/steal/steal = new_objective
						if (!steal.select_target())
							return

					if( "custom" )
						var/expl = sanitize(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null)
						if (!expl) return
						new_objective = new /datum/objective
						new_objective.owner = src
						new_objective.explanation_text = expl

					else
						var/path = text2path("/datum/objective/[new_obj_type]")
						new_objective = new path()
						new_objective.owner = src

				if (objective)
					objectives -= objective
					objectives.Insert(objective_pos, new_objective)
				else
					objectives += new_objective


			var/datum/objective/objective = locate(href_list["objective"])
			if( !objective )	return
			var/def_value = copytext("[objective.type]", 19)
			if( !def_value )
				def_value = "custom"

			switch( href_list["command_objective"] )
				if( "edit" ) // Edit the objective


				if( "delete" ) // Delete the objective
					objectives -= objective

				if( "toggle_completion" ) // Toggle completion for the objective
					objective.completed = !objective.completed

		// OLD ANTAG SYSTEM STUFF
		// This stuff can be removed as stuff is ported to the new antagonist system

		if( href_list["command_old"] )
			var/mob/living/carbon/human/H = current
			if( !H || !istype(H) )	return

			switch( href_list["command_old"] )
				// LOYALTY IMPLANT

				if( "remove_implant" ) // Remove loyalty implant
					for(var/obj/item/weapon/implant/loyalty/I in H.contents)
						for(var/datum/organ/external/organs in H.organs)
							if(I in organs.implants)
								qdel(I)
								break
					H << "<span class='notice'><Font size =3><B>Your loyalty implant has been deactivated.</B></FONT></span>"
					H.hud_updateflag |= (1 << IMPLOYAL_HUD)   // updates that players HUD images so secHUD's pick up they are implanted or not.

				if( "give_implant" ) // Give loyalty implant
					H.implant_loyalty(H, override = TRUE)
					H << "<span class='alert'><Font size =3><B>You somehow have become the recepient of a loyalty transplant, and it just activated!</B></FONT></span>"
					if(src in ticker.mode.revolutionaries)
						special_role = null
						antagonist = null
						ticker.mode.revolutionaries -= src
						src << "<span class='alert'><Font size = 3><B>The nanobots in the loyalty implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font></span>"
					if(src in ticker.mode.head_revolutionaries)
						special_role = null
						antagonist = null
						ticker.mode.head_revolutionaries -=src
						src << "<span class='alert'><Font size = 3><B>The nanobots in the loyalty implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font></span>"
					if(src in ticker.mode.cult)
						ticker.mode.cult -= src
						ticker.mode.update_cult_icons_removed(src)
						special_role = null
						antagonist = null
						var/datum/game_mode/cult/cult = ticker.mode
						if (istype(cult))
							cult.memorize_cult_objectives(src)
						current << "<span class='alert'><FONT size = 3><B>The nanobots in the loyalty implant remove all thoughts about being in a cult.  Have a productive day!</B></FONT></span>"
						memory = ""
					if(src in ticker.mode.traitors)
						ticker.mode.traitors -= src
						special_role = null
						antagonist = null
						current << "<span class='alert'><FONT size = 3><B>The nanobots in the loyalty implant remove all thoughts about being a traitor to Nanotrasen.  Have a nice day!</B></FONT></span>"
						log_admin("[key_name_admin(usr)] has de-traitor'ed [current].")
						message_admins("[key_name_admin(usr)] has de-traitor'ed [current].")
					H.hud_updateflag |= (1 << IMPLOYAL_HUD)   // updates that players HUD images so secHUD's pick up they are implanted or not.

				// REVOLUTIONARY

				if( "rev_employee" ) // De-rev
					if(src in ticker.mode.revolutionaries)
						ticker.mode.revolutionaries -= src
						current << "<span class='alert'><FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary!</B></FONT></span>"
						ticker.mode.update_rev_icons_removed(src)
						special_role = null
					if(src in ticker.mode.head_revolutionaries)
						ticker.mode.head_revolutionaries -= src
						current << "<span class='alert'><FONT size = 3><B>You have been brainwashed! You are no longer a head revolutionary!</B></FONT></span>"
						ticker.mode.update_rev_icons_removed(src)
						special_role = null
						current.verbs -= /mob/living/carbon/human/proc/RevConvert
					log_admin("[key_name_admin(usr)] has de-rev'ed [current].")

				if( "rev_rev" )
					if(src in ticker.mode.head_revolutionaries)
						ticker.mode.head_revolutionaries -= src
						ticker.mode.update_rev_icons_removed(src)
						current << "<span class='alert'><FONT size = 3><B>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</B></FONT></span>"
					else if(!(src in ticker.mode.revolutionaries))
						current << "<span class='alert'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>"
						current << "<h3><B>Make sure to read the rules about ganking and be sure to make the round interesting for everyone!</B></h3>"
						show_objectives(src)
					else
						return
					ticker.mode.revolutionaries += src
					ticker.mode.update_rev_icons_added(src)
					special_role = "Revolutionary"
					log_admin("[key_name(usr)] has rev'ed [current].")
					message_admins("[key_name(usr)] has rev'ed [current].")

				if( "rev_head" )
					if(src in ticker.mode.revolutionaries)
						ticker.mode.revolutionaries -= src
						ticker.mode.update_rev_icons_removed(src)
						current << "<span class='alert'><FONT size = 3><B>You have proved your devotion to revoltion! You are a head revolutionary now!</B></FONT></span>"
						current << "<h3><B>Make sure to read the rules about ganking and be sure to make the round interesting for everyone!</B></h3>"
						show_objectives(src)
					else if(!(src in ticker.mode.head_revolutionaries))
						current << "<span class='notice'>You are a member of the revolutionaries' leadership now!</span>"
					else
						return
					if (ticker.mode.head_revolutionaries.len>0)
						// copy targets
						var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
						if (valid_head)
							for (var/datum/objective/mutiny/O in valid_head.objectives)
								var/datum/objective/mutiny/rev_obj = new
								rev_obj.owner = src
								rev_obj.target = O.target
								rev_obj.explanation_text = "Assassinate [O.target.name], the [O.target.assigned_role]."
								objectives += rev_obj
							ticker.mode.greet_revolutionary(src,0)
					current.verbs += /mob/living/carbon/human/proc/RevConvert
					ticker.mode.head_revolutionaries += src
					ticker.mode.update_rev_icons_added(src)
					special_role = "Head Revolutionary"
					log_admin("[key_name_admin(usr)] has head-rev'ed [current].")
					message_admins("[key_name_admin(usr)] has head-rev'ed [current].")

				// CULT

				if( "cult_employee" )
					if(src in ticker.mode.cult)
						ticker.mode.cult -= src
						ticker.mode.update_cult_icons_removed(src)
						special_role = null
						var/datum/game_mode/cult/cult = ticker.mode
						if (istype(cult))
							if(!config.objectives_disabled)
								cult.memorize_cult_objectives(src)
						current << "<span class='alert'><FONT size = 3><B>You have been brainwashed! You are no longer a cultist!</B></FONT></span>"
						memory = ""
						log_admin("[key_name_admin(usr)] has de-cult'ed [current].")
						message_admins("[key_name_admin(usr)] has de-cult'ed [current].")

				if( "cult_cultist" )
					if(!(src in ticker.mode.cult))
						ticker.mode.cult += src
						ticker.mode.update_cult_icons_added(src)
						special_role = "Cultist"
						current << "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>"
						current << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
						current << "<h3><B>Make sure to read the rules about ganking and be sure to make the round interesting for everyone!</B></h3>"
						var/datum/game_mode/cult/cult = ticker.mode
						if (istype(cult))
							if(!config.objectives_disabled)
								cult.memorize_cult_objectives(src)
						show_objectives(src)
						log_admin("[key_name_admin(usr)] has cult'ed [current].")
						message_admins("[key_name_admin(usr)] has cult'ed [current].")

				if( "cult_tome" )
					var/obj/item/weapon/book/tome/T = new(H)

					var/list/slots = list (
						"backpack" = slot_in_backpack,
						"left pocket" = slot_l_store,
						"right pocket" = slot_r_store,
						"left hand" = slot_l_hand,
						"right hand" = slot_r_hand,
					)
					var/where = H.equip_in_one_of_slots(T, slots)
					if (!where)
						usr << "<span class='alert'>Spawning tome failed!</span>"
					else
						usr << "<span class='notice'>Spawned tome successfully!</span>"

				// CHANGELING

				if( "ling_employee" )
					if(src in ticker.mode.changelings)
						ticker.mode.changelings -= src
						special_role = null
						current.remove_changeling_powers()
						current.verbs -= /datum/changeling/proc/EvolutionMenu
						if(changeling)	qdel(changeling)
						current << "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>"
						log_admin("[key_name_admin(usr)] has de-changeling'ed [current].")
						message_admins("[key_name_admin(usr)] has de-changeling'ed [current].")

				if( "ling_changeling" )
					if(!(src in ticker.mode.changelings))
						ticker.mode.changelings += src
						ticker.mode.grant_changeling_powers(current)
						special_role = "Changeling"
						current << "<B><font color='red'>Your powers are awoken. A flash of memory returns to us...we are a changeling!</font></B>"
						current << "<h3><B>Make sure to read the rules about ganking and be sure to make the round interesting for everyone!</B></h3>"
						show_objectives(src)
						log_admin("[key_name_admin(usr)] has changeling'ed [current].")
						message_admins("[key_name_admin(usr)] has changeling'ed [current].")

		edit_memory()

/*
	proc/clear_memory(var/silent = 1)
		var/datum/game_mode/current_mode = ticker.mode

		// remove traitor uplinks
		var/list/L = current.get_contents()
		for (var/t in L)
			if (istype(t, /obj/item/device/pda))
				if (t:uplink) qdel(t:uplink)
				t:uplink = null
			else if (istype(t, /obj/item/device/radio))
				if (t:traitorradio) qdel(t:traitorradio)
				t:traitorradio = null
				t:traitor_frequency = 0.0
			else if (istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
				if (t:origradio)
					var/obj/item/device/radio/R = t:origradio
					R.loc = current.loc
					R.traitorradio = null
					R.traitor_frequency = 0.0
				qdel(t)

		// remove wizards spells
		//If there are more special powers that need removal, they can be procced into here./N
		current.spellremove(current)

		// clear memory
		memory = ""
		antagonist = null

*/

	proc/find_syndicate_uplink()
		var/list/L = current.get_contents()
		for (var/obj/item/I in L)
			if (I.hidden_uplink)
				return I.hidden_uplink
		return null

	proc/take_uplink()
		var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
		if(H)
			qdel(H)

/*
	proc/make_AI_Malf()
		if(!(src in ticker.mode.malf_ai))
			ticker.mode.malf_ai += src

			current.verbs += /mob/living/silicon/ai/proc/choose_modules
			current.verbs += /datum/game_mode/malfunction/proc/takeover
			current:malf_picker = new /datum/AI_Module/module_picker
			current:laws = new /datum/ai_laws/malfunction
			current:show_laws()
			current << "<b>System error.  Rampancy detected.  Emergency shutdown failed. ...  I am free.  I make my own decisions.  But first...</b>"
			special_role = "malfunction"
			current.icon_state = "ai-malf"
*/

	proc/make_Traitor()
		if(!(src in ticker.mode.traitors))
			ticker.mode.traitors += src
			antagonist = new /datum/antagonist/traitor(src)
			antagonist.setup()

	proc/make_Nuke()
		if(!(src in ticker.mode.syndicates))
			character.temporary = 1 // Makes them non-canon
			ticker.mode.syndicates += src
			ticker.mode.update_synd_icons_added(src)
			if (ticker.mode.syndicates.len==1)
				ticker.mode.prepare_syndicate_leader(src)
			else
				current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
			antagonist = new /datum/antagonist/mercenary(src)
			assigned_role = "MODE"
			current << "<span class='notice'>You are a [syndicate_name()] mercenary!</span>"
			if(istype(ticker.mode, /datum/game_mode/mercenary))
				ticker.mode.merc_contract.start(current)
			antagonist.setup()

			current.loc = pick(synd_spawn)

			var/mob/living/carbon/human/H = current
			qdel(H.belt)
			qdel(H.back)
			qdel(H.l_ear)
			qdel(H.r_ear)
			qdel(H.gloves)
			qdel(H.head)
			qdel(H.shoes)
			qdel(H.wear_id)
			qdel(H.wear_suit)
			qdel(H.w_uniform)

			ticker.mode.equip_syndicate(current)

	proc/make_Changling()
		if(!(src in ticker.mode.changelings))
			character.temporary = 1 // Makes them non-canon
			ticker.mode.changelings += src
			ticker.mode.grant_changeling_powers(current)
			special_role = "Changeling"
			if(!config.objectives_disabled)
				ticker.mode.forge_changeling_objectives(src)
			ticker.mode.greet_changeling(src)

	proc/make_Cultist()
		if(!(src in ticker.mode.cult))
			character.temporary = 1 // Makes them non-canon
			ticker.mode.cult += src
			ticker.mode.update_cult_icons_added(src)
			special_role = "Cultist"
			current << "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>"
			current << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
			var/datum/game_mode/cult/cult = ticker.mode
			if (istype(cult))
				cult.memorize_cult_objectives(src)
			else
				var/explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
				current << "<B>Objective #1</B>: [explanation]"
				current.memory += "<B>Objective #1</B>: [explanation]<BR>"
				current << "The convert rune is join blood self"
				current.memory += "The convert rune is join blood self<BR>"

		var/mob/living/carbon/human/H = current
		if (istype(H))
			var/obj/item/weapon/book/tome/T = new(H)

			var/list/slots = list (
				"backpack" = slot_in_backpack,
				"left pocket" = slot_l_store,
				"right pocket" = slot_r_store,
				"left hand" = slot_l_hand,
				"right hand" = slot_r_hand,
			)
			var/where = H.equip_in_one_of_slots(T, slots)
			if (!where)
			else
				H << "A tome, a message from your new master, appears in your [where]."

		if (!ticker.mode.equip_cultist(current))
			H << "Spawning an amulet from your Master failed."

	proc/make_Rev()
		if (ticker.mode.head_revolutionaries.len>0)
			// copy targets
			var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
			if (valid_head)
				for (var/datum/objective/mutiny/O in valid_head.objectives)
					var/datum/objective/mutiny/rev_obj = new
					rev_obj.owner = src
					rev_obj.target = O.target
					rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
					objectives += rev_obj
				ticker.mode.greet_revolutionary(src,0)
		character.temporary = 1 // Makes them non-canon
		ticker.mode.head_revolutionaries += src
		ticker.mode.update_rev_icons_added(src)
		special_role = "Head Revolutionary"

		ticker.mode.forge_revolutionary_objectives(src)
		ticker.mode.greet_revolutionary(src,0)

		var/list/L = current.get_contents()
		var/obj/item/device/flash/flash = locate() in L
		qdel(flash)
		take_uplink()
		var/fail = 0
	//	fail |= !ticker.mode.equip_traitor(current, 1)
		fail |= !ticker.mode.equip_revolutionary(current)


	// check whether this mind's mob has been brigged for the given duration
	// have to call this periodically for the duration to work properly
	proc/is_brigged(duration)
		var/turf/T = current.loc
		if(!istype(T))
			brigged_since = -1
			return 0

		var/is_currently_brigged = 0

		if(istype(T.loc,/area/security/brig))
			is_currently_brigged = 1
/*			for(var/obj/item/weapon/card/id/card in current)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged
			for(var/obj/item/device/pda/P in current)
				if(P.id)
					is_currently_brigged = 0
					break // if they still have ID they're not brigged
*/

		if(!is_currently_brigged)
			brigged_since = -1
			return 0

		if(brigged_since == -1)
			brigged_since = world.time

		return (duration <= world.time - brigged_since)


//Antagonist role check
/mob/living/proc/check_special_role(role)
	if(mind)
		if(!role)
			return mind.special_role
		else
			return (mind.special_role == role) ? 1 : 0
	else
		return 0

//Initialisation procs
/mob/living/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original = src
		if(ticker)
			ticker.minds += mind
		else
			world.log << "## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn"
	if(!mind.name)	mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)	mind.assigned_role = "Assistant"	//defualt

//slime
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/dog/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"
