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

		. += "<tr><td><table>"

		// COMMANDS
		if(antagonist)
			. += "<tr>"
			. += "<td>Antagonist type: <a href='byond://?src=\ref[src];command='antag_type'><b>[antagonist.name]</b></a></td>"
			. += "<td>Persistent: <b>[istype(antagonist, /datum/antagonist/traitor/persistant) ? "Yes" : "No"]</b></td>"
			. += "</tr>"
			. += "<tr>"
			. += "<td>Faction: <a href='byond://?src=\ref[src];command='antag_faction'><b>[antagonist.faction.name]</b></a></td>"
			. += "<td>Notoriety: <a href='byond://?src=\ref[src];command='edit_notoriety'>[character.antag_data["notoriety"]]</a></td>"
			. += "</tr>"

			. += "</table></td></tr>"

			. += "<tr><td><hr></td></tr>"

			. += "<tr><td><table>"
			
			. += "<tr><td>General</td></tr>"
			. += "<tr><td><a href='byond://?src=\ref[src];command='disable_uplink'>Disable Uplink</a> | <a href='byond://?src=\ref[src];command='random_contract'>Random contract</a> | <a href='byond://?src=\ref[src];command='custom_contract'>Custom contract</a></td></tr>"

			. += "<tr><td>Fun</td></tr>"
			. += "<tr><td><a href='byond://?src=\ref[src];command='give_money'>Grant funds</a> | <a href='byond://?src=\ref[src];command='buy_random'>Buy random</a> | <a href='byond://?src=\ref[src];command='buy_random_faction'>Buy random (faction)</a> | <a href='byond://?src=\ref[src];command='randomize_char'>Randomize character</a> | <a href='byond://?src=\ref[src];command='save_char'>Save character</a> | <a href='byond://?src=\ref[src];command='give_token'>Give token</a></td></tr>"

			if(check_rights(R_DEBUG))
				. += "<tr><td>Debug</td></tr>"
				. += "<tr><td><a href='byond://?src=\ref[src];command_debug='equip'>Equip</a> | <a href='byond://?src=\ref[src];command_debug='setup'>Force setup</a> | <a href='byond://?src=\ref[src];command_debug='greet'>Greet</a> | <a href='byond://?src=\ref[src];command_debug='commend'>Commend</a></td></tr>"

			. += "</table></td></tr>"
		else
			. += "<tr>"
			. += "<td>Antagonist type: <a href='byond://?src=\ref[src];command='antag_type'><b>Not antagonist</b></a></td>"
			. += "</tr>"

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
					. += "<td><a href='byond://?src=\ref[src];contract_command='fail';contract=\ref[contract]>Fail</a></td>"
					. += "<td><a href='byond://?src=\ref[src];contract_command='complete';contract=\ref[contract]>Complete</a></td>"
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
			. += "<td>Implanted | <a href='byond://?src=\ref[src];old_command='remove_implant'>Not implanted</a></td>"
		else
			. += "<td><a href='byond://?src=\ref[src];old_command='give_implant'>Implanted</a> | Not implanted</td>"

		. += "</tr></table>"
		. += "</td></tr>"

		. += "<tr><td><hr></td></tr>"

		. += "<tr><td><table>"
		. += "<tr><td>Antagonists</td></tr>"

		. += "<tr>"
		. += "<td>Revolutionary:</td>"

		// REVOLUTIONARY
		if(src in ticker.mode.head_revolutionaries)
			. += "<td><a href='byond://?src=\ref[src];old_antag='rev_employee'>Employee</a> | <a href='byond://?src=\ref[src];old_command='rev_rev'>Rev</a> | Head Rev</td>"
		else if(src in ticker.mode.revolutionaries)
			. += "<td><a href='byond://?src=\ref[src];old_antag='rev_employee'>Employee</a> | Rev | <a href='byond://?src=\ref[src];old_command='rev_head'>Head Rev</a></td>"
		else
			. += "<td>Employee | <a href='byond://?src=\ref[src];old_command='rev_rev'>Rev</a> | <a href='byond://?src=\ref[src];old_command='rev_head'>Head Rev</a></td>"

		. += "</tr>"
		. += "<tr>"
		. += "<td>Cultist:</td>"

		// CULTIST
		if(src in ticker.mode.cult)
			. += "<td><a href='byond://?src=\ref[src];old_command='cult_employee'>Employee</a> | Cultist</td>"
		else
			. += "<td>Employee | <a href='byond://?src=\ref[src];old_command='cult_cultist'>Cultist</a></td>"

		. += "</tr>"
		. += "<tr>"
		. += "<td>Changeling:</td>"

		// CHANGELING
		if(src in ticker.mode.changelings)
			. += "<td><a href='byond://?src=\ref[src];old_command='ling_employee'>Employee</a> | Changeling</td>"
		else
			. += "<td>Employee | <a href='byond://?src=\ref[src];old_command='ling_changeling'>Changeling</a></td>"

		. += "</tr></table>"
		. += "</td></tr>"

		. += "</table></td></tr>"
		// END OLD ANTAGONIST SYSTEM PANEL //

		// START OBJECTIVES PANEL //
		. += "<tr><td><table class='outline'>"
		. += "<tr><th align='left' style='padding-left: 6px'><b>Objectives</b></th></tr>"

		. += "<tr><td><table>"
		. += "<tr><td>Commands</td></tr>"
		. += "<tr><td><a href='byond://?src=\ref[src];obj_command='add'>Add objective</a> | <a href='byond://?src=\ref[src];obj_command='announce'>Announce objectives</a></td></tr>"
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
				. += "<td> <a href='byond://?src=\ref[src];obj_command='edit';objective='\ref[objective]'>Edit</a> | <ahref='byond://?src=\ref[src];obj_command='delete';objective=\ref[objective]>Delete</a> | <ahref='byond://?src=\ref[src];obj_command='toggle_completion';objective=\ref[objective]><font color=[objective.completed ? "blue" : "yellow"]>Toggle completion</font></a></td>"
				. += "</tr></table>"
		else
			. += "<table><tr><td>No objectives</td></tr></table>"

		. += "</td></tr></table>"
		. += "</td></tr></table>"

		. += "</td></tr>"
		. += "</table>"
		// END OBJECTIVES PANEL //
			
		memory_browser.set_user( usr )
		memory_browser.set_content( . )
		memory_browser.open()


	Topic(href, href_list)
		if(!check_rights(R_ADMIN))	return

		if (href_list["role_edit"])
			var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
			if (!new_role) return
			assigned_role = new_role

		else if (href_list["memory_edit"])
			var/new_memo = sanitize(input("Write new memory", "Memory", memory) as null|message)
			if (isnull(new_memo)) return
			memory = new_memo

		else if (href_list["obj_edit"] || href_list["obj_add"])
			var/datum/objective/objective
			var/objective_pos
			var/def_value

			if (href_list["obj_edit"])
				objective = locate(href_list["obj_edit"])
				if (!objective) return
				objective_pos = objectives.Find(objective)

				//Text strings are easy to manipulate. Revised for simplicity.
				var/temp_obj_type = "[objective.type]"//Convert path into a text string.
				def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
				if(!def_value)//If it's a custom objective, it will be an empty string.
					def_value = "custom"

			var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "mercenary", "capture", "absorb", "custom")
			if (!new_obj_type) return

			var/datum/objective/new_objective = null

			switch (new_obj_type)
				if ("assassinate","protect","debrain", "harm", "brig")
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

				if ("prevent")
					new_objective = new /datum/objective/block
					new_objective.owner = src

				if ("hijack")
					new_objective = new /datum/objective/hijack
					new_objective.owner = src

				if ("escape")
					new_objective = new /datum/objective/escape
					new_objective.owner = src

				if ("survive")
					new_objective = new /datum/objective/survive
					new_objective.owner = src

				if ("mercenary")
					new_objective = new /datum/objective/nuclear
					new_objective.owner = src

				if ("steal")
					if (!istype(objective, /datum/objective/steal))
						new_objective = new /datum/objective/steal
						new_objective.owner = src
					else
						new_objective = objective
					var/datum/objective/steal/steal = new_objective
					if (!steal.select_target())
						return

				if("download","capture","absorb")
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

				if ("custom")
					var/expl = sanitize(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null)
					if (!expl) return
					new_objective = new /datum/objective
					new_objective.owner = src
					new_objective.explanation_text = expl

			if (!new_objective) return

			if (objective)
				objectives -= objective
				objectives.Insert(objective_pos, new_objective)
			else
				objectives += new_objective

		else if (href_list["obj_delete"])
			var/datum/objective/objective = locate(href_list["obj_delete"])
			if(!istype(objective))	return
			objectives -= objective

		else if(href_list["obj_completed"])
			var/datum/objective/objective = locate(href_list["obj_completed"])
			if(!istype(objective))	return
			objective.completed = !objective.completed

		else if(href_list["implant"])
			var/mob/living/carbon/human/H = current

			H.hud_updateflag |= (1 << IMPLOYAL_HUD)   // updates that players HUD images so secHUD's pick up they are implanted or not.

			switch(href_list["implant"])
				if("remove")
					for(var/obj/item/weapon/implant/loyalty/I in H.contents)
						for(var/datum/organ/external/organs in H.organs)
							if(I in organs.implants)
								qdel(I)
								break
					H << "<span class='notice'><Font size =3><B>Your loyalty implant has been deactivated.</B></FONT></span>"

				if("add")
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
				else


		else if (href_list["revolution"])
			current.hud_updateflag |= (1 << SPECIALROLE_HUD)

			switch(href_list["revolution"])
				if("clear")
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

				if("rev")
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

				if("headrev")
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

				if("autoobjectives")
					ticker.mode.forge_revolutionary_objectives(src)
					ticker.mode.greet_revolutionary(src,0)
					usr << "<span class='notice'>The objectives for revolution have been generated and shown to [key]</span>"

				if("flash")
					if (!ticker.mode.equip_revolutionary(current))
						usr << "<span class='alert'>Spawning flash failed!</span>"

				if("takeflash")
					var/list/L = current.get_contents()
					var/obj/item/device/flash/flash = locate() in L
					if (!flash)
						usr << "<span class='alert'>Deleting flash failed!</span>"
					qdel(flash)

				if("repairflash")
					var/list/L = current.get_contents()
					var/obj/item/device/flash/flash = locate() in L
					if (!flash)
						usr << "<span class='alert'>Repairing flash failed!</span>"
					else
						flash.broken = 0

				//if("reequip")
				//	var/list/L = current.get_contents()
				//	var/obj/item/device/flash/flash = locate() in L
				//	qdel(flash)
				//	take_uplink()
				//	var/fail = 0
				//	fail |= !ticker.mode.equip_traitor(current, 1)
				//	fail |= !ticker.mode.equip_revolutionary(current)
				//	if (fail)
				//		usr << "<span class='alert'>Reequipping revolutionary goes wrong!</span>"

		else if (href_list["cult"])
			current.hud_updateflag |= (1 << SPECIALROLE_HUD)
			switch(href_list["cult"])
				if("clear")
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
				if("cultist")
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
				if("tome")
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
							usr << "<span class='alert'>Spawning tome failed!</span>"
						else

				if("amulet")
					if (!ticker.mode.equip_cultist(current))
						usr << "<span class='alert'>Spawning amulet failed!</span>"


		else if (href_list["changeling"])
			current.hud_updateflag |= (1 << SPECIALROLE_HUD)
			switch(href_list["changeling"])
				if("clear")
					if(src in ticker.mode.changelings)
						ticker.mode.changelings -= src
						special_role = null
						current.remove_changeling_powers()
						current.verbs -= /datum/changeling/proc/EvolutionMenu
						if(changeling)	qdel(changeling)
						current << "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>"
						log_admin("[key_name_admin(usr)] has de-changeling'ed [current].")
				if("changeling")
					if(!(src in ticker.mode.changelings))
						ticker.mode.changelings += src
						ticker.mode.grant_changeling_powers(current)
						special_role = "Changeling"
						current << "<B><font color='red'>Your powers are awoken. A flash of memory returns to us...we are a changeling!</font></B>"
						current << "<h3><B>Make sure to read the rules about ganking and be sure to make the round interesting for everyone!</B></h3>"
						show_objectives(src)
						log_admin("[key_name_admin(usr)] has changeling'ed [current].")
				if("autoobjectives")
					if(!config.objectives_disabled)
						ticker.mode.forge_changeling_objectives(src)
					usr << "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and anounce manually.</span>"

				if("initialdna")
					if( !changeling || !changeling.absorbed_dna.len )
						usr << "<span class='alert'>Resetting DNA failed!</span>"
					else
						current.dna = changeling.absorbed_dna[1]
						current.real_name = current.dna.real_name
						current.UpdateAppearance()
						domutcheck(current, null)

		else if (href_list["mercenary"])
			var/mob/living/carbon/human/H = current

			current.hud_updateflag |= (1 << SPECIALROLE_HUD)

			switch(href_list["mercenary"])
				if("clear")
					if(src in ticker.mode.syndicates)
						ticker.mode.syndicates -= src
						ticker.mode.update_synd_icons_removed(src)
						antagonist = null
						for (var/datum/objective/nuclear/O in objectives)
							objectives-=O
						current << "<span class='alert'><FONT size = 3><B>You have been brainwashed! You are no longer an operative!</B></FONT></span>"
						log_admin("[key_name_admin(usr)] has de-merc'd [current].")
				if("mercenary")
					if(!(src in ticker.mode.syndicates))
						ticker.mode.syndicates += src
						ticker.mode.update_synd_icons_added(src)
						if (ticker.mode.syndicates.len==1)
							ticker.mode.prepare_syndicate_leader(src)
						else
							current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
						antagonist = new /datum/antagonist/mercenary(src)
						current << "<span class='notice'>You are a Gorlex operative!</span>"
						current << "<h3><B>Make sure to read the rules about ganking and be sure to make the round interesting for everyone!</B></h3>"
						if(istype(ticker.mode, /datum/game_mode/mercenary))
							ticker.mode.merc_contract.start(current)
						antagonist.setup()
						log_admin("[key_name_admin(usr)] has merc'd [current].")
				if("lair")
					current.loc = pick(synd_spawn)
				if("dressup")
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

					if (!ticker.mode.equip_syndicate(current))
						usr << "<span class='alert'>Equipping an operative failed!</span>"
				if("tellcode")
					var/code
					for (var/obj/machinery/nuclearbomb/bombue in machines)
						if (length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
							code = bombue.r_code
							break
					if (code)
						store_memory("<B>Nuclear Bomb Code</B>: [code]", 0, 0)
						current << "The nuclear authorization code is: <B>[code]</B>"
					else
						usr << "<span class='alert'>No valid nuke found!</span>"

		else if (href_list["traitor"])
			current.hud_updateflag |= (1 << SPECIALROLE_HUD)
			switch(href_list["traitor"])
				if("clear")
					if(src in ticker.mode.traitors)
						ticker.mode.traitors -= src
						antagonist = null
						current << "<span class='alert'><FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT></span>"
						log_admin("[key_name_admin(usr)] has de-traitor'ed [current].")
						if(isAI(current))
							var/mob/living/silicon/ai/A = current
							A.set_zeroth_law("")
							A.show_laws()


				if("traitor")
					if(!(src in ticker.mode.traitors))
						ticker.mode.traitors += src
						antagonist = new /datum/antagonist/traitor(src)
						antagonist.setup()
						current << "<h3><B>Make sure to read the rules about ganking and be sure to make the round interesting for everyone!</B></h3>"
						log_admin("[key_name_admin(usr)] has traitor'ed [current].")

						if(istype(current, /mob/living/silicon))
							var/mob/living/silicon/ai/A = current
							A.show_laws()

				if("autoobjectives")
					if (!config.objectives_disabled && ticker.contracts_made)
						var/datum/antagonist/traitor/antag = antagonist
						if( istype( antag))
							antag.pick_contracts()
						usr << "<span class='notice'>The contracts for traitor [key] have been picked.</span>"

		else if (href_list["silicon"])
			current.hud_updateflag |= (1 << SPECIALROLE_HUD)
			switch(href_list["silicon"])
				/*if("unmalf")
					if(src in ticker.mode.malf_ai)
						ticker.mode.malf_ai -= src
						antagonist = null

						current.verbs.Remove(/mob/living/silicon/ai/proc/choose_modules,
							/datum/game_mode/malfunction/proc/takeover,
							/datum/game_mode/malfunction/proc/ai_win,
							/client/proc/fireproof_core,
							/client/proc/upgrade_turrets,
							/client/proc/disable_rcd,
							/client/proc/overload_machine,
							/client/proc/blackout,
							/client/proc/interhack,
							/client/proc/reactivate_camera)

						current:laws = new /datum/ai_laws/nanotrasen
						qdel(current:malf_picker)
						current:show_laws()
						current.icon_state = "ai"

						current << "<span class='alert'><FONT size = 3><B>You have been patched! You are no longer malfunctioning!</B></FONT></span>"
						log_admin("[key_name_admin(usr)] has de-malf'ed [current].")

				if("malf")
					make_AI_Malf()
					log_admin("[key_name_admin(usr)] has malf'ed [current].")*/

				if("unemag")
					var/mob/living/silicon/robot/R = current
					if (istype(R))
						R.emagged = 0
						if (R.activated(R.module.emag))
							R.module_active = null
						if(R.module_state_1 == R.module.emag)
							R.module_state_1 = null
							R.contents -= R.module.emag
						else if(R.module_state_2 == R.module.emag)
							R.module_state_2 = null
							R.contents -= R.module.emag
						else if(R.module_state_3 == R.module.emag)
							R.module_state_3 = null
							R.contents -= R.module.emag
						log_admin("[key_name_admin(usr)] has unemag'ed [R].")

				if("unemagcyborgs")
					if (istype(current, /mob/living/silicon/ai))
						var/mob/living/silicon/ai/ai = current
						for (var/mob/living/silicon/robot/R in ai.connected_robots)
							R.emagged = 0
							if (R.module)
								if (R.activated(R.module.emag))
									R.module_active = null
								if(R.module_state_1 == R.module.emag)
									R.module_state_1 = null
									R.contents -= R.module.emag
								else if(R.module_state_2 == R.module.emag)
									R.module_state_2 = null
									R.contents -= R.module.emag
								else if(R.module_state_3 == R.module.emag)
									R.module_state_3 = null
									R.contents -= R.module.emag
						log_admin("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")

		else if (href_list["common"])
			switch(href_list["common"])
				if("undress")
					for(var/obj/item/W in current)
						current.drop_from_inventory(W)
				if("takeuplink")
					take_uplink()
					memory = null//Remove any memory they may have had.
				if("crystals")
					if (usr.client.holder.rights & R_FUN)
						var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
						var/crystals
						if (suplink)
							crystals = suplink.uses
						crystals = input("Amount of telecrystals for [key]","Operative uplink", crystals) as null|num
						if (!isnull(crystals))
							if (suplink)
								suplink.uses = crystals
				if("uplink")
					if (!src.antagonist.equip())
						usr << "<span class='alert'>Equipping an operative failed!</span>"

		else if (href_list["obj_announce"])
			var/obj_count = 1
			current << "<span class='notice'>Your current objectives:</span>"
			for(var/datum/objective/objective in objectives)
				current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

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
