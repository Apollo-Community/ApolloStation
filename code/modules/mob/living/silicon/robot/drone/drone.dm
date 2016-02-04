/mob/living/silicon/robot/drone
	name = "drone"
	real_name = "drone"
	icon = 'icons/mob/robots.dmi'
	icon_state = "repairbot"
	maxHealth = 35
	health = 35
	universal_speak = 0
	universal_understand = 1
	gender = NEUTER
	pass_flags = PASSTABLE
	braintype = "Robot"
	lawupdate = 0
	density = 1
	req_access = list(access_engine, access_robotics)
	integrated_light_power = 2
	local_transmit = 1

	static_overlays
	var/static_choice = "static"
	var/list/static_choices = list("static", "letter", "blank")

	// We need to keep track of a few module items so we don't need to do list operations
	// every time we need them. These get set in New() after the module is chosen.
	var/obj/item/stack/sheet/metal/cyborg/stack_metal = null
	var/obj/item/stack/sheet/wood/cyborg/stack_wood = null
	var/obj/item/stack/sheet/glass/cyborg/stack_glass = null
	var/obj/item/stack/sheet/mineral/plastic/cyborg/stack_plastic = null
	var/obj/item/weapon/matter_decompiler/decompiler = null

	//Used for self-mailing.
	var/mail_destination = ""

	var/obj/machinery/drone_fabricator/master_fabricator

	holder_type = /obj/item/weapon/holder/drone

/mob/living/silicon/robot/drone/New()
	..()

	verbs += /mob/living/proc/hide
	remove_language("Robot Talk")
	add_language("Robot Talk", 0)
	add_language("Drone Talk", 1)

	if(camera && "Robots" in camera.network)
		camera.network.Add("Engineering")

	//They are unable to be upgraded, so let's give them a bit of a better battery.
	cell.maxcharge = 10000
	cell.charge = 10000

	// NO BRAIN.
	mmi = null

	//We need to screw with their HP a bit. They have around one fifth as much HP as a full borg.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.max_damage = 10

	verbs -= /mob/living/silicon/robot/verb/Namepick
	module = new /obj/item/weapon/robot_module/drone(src)

	id_card = new /obj/item/weapon/card/id/captains_spare(src) // AI gets to do whatever they like

	//Grab stacks.
	stack_metal = locate(/obj/item/stack/sheet/metal/cyborg) in src.module
	stack_wood = locate(/obj/item/stack/sheet/wood/cyborg) in src.module
	stack_glass = locate(/obj/item/stack/sheet/glass/cyborg) in src.module
	stack_plastic = locate(/obj/item/stack/sheet/mineral/plastic/cyborg) in src.module

	//Grab decompiler.
	decompiler = locate(/obj/item/weapon/matter_decompiler) in src.module

	//Some tidying-up.
	flavor_text = "It's a tiny little repair drone. The casing is stamped with an NT logo and the subscript: 'NanoTrasen Recursive Repair Systems: Fixing Tomorrow's Problem, Today!'"
	updateicon()

/mob/living/silicon/robot/drone/Login()
	..()

	if(can_see_static())
		add_static_overlays()


/mob/living/silicon/robot/drone/Destroy()
	destroyCard()

	..()

	remove_static_overlays()

/mob/living/silicon/robot/drone/proc/destroyCard()
	qdel( id_card )
	id_card = null

/mob/living/silicon/robot/drone/generate_static_overlay()
	if(!istype(static_overlays,/list))
		static_overlays = list()
	return

/mob/living/silicon/robot/drone/init()
	laws = new /datum/ai_laws/drone()
	connected_ai = null

	aiCamera = new/obj/item/device/camera/siliconcam/drone_camera(src)
	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)

//Redefining some robot procs...
/mob/living/silicon/robot/drone/updatename()
	real_name = "maintenance drone ([rand(100,999)])"
	name = real_name

/mob/living/silicon/robot/drone/updateicon()

	overlays.Cut()
	if(stat == 0)
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

/mob/living/silicon/robot/drone/choose_icon()
	return

/mob/living/silicon/robot/drone/pick_module()
	return

//Drones cannot be upgraded with borg modules so we need to catch some items before they get used in ..().
/mob/living/silicon/robot/drone/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/borg/upgrade/))
		user << "<span class='alert'>The maintenance drone chassis not compatible with \the [W].</span>"
		return

	else if (istype(W, /obj/item/weapon/crowbar))
		user << "The machine is hermetically sealed. You can't open the case."
		return

	else if (istype(W, /obj/item/weapon/card/emag))

		if(!client || stat == 2)
			user << "<span class='alert'>There's not much point subverting this heap of junk.</span>"
			return

		if(emagged)
			src << "<span class='alert'>[user] attempts to load subversive software into you, but your hacked subroutined ignore the attempt.</span>"
			user << "<span class='alert'>You attempt to subvert [src], but the sequencer has no effect.</span>"
			return

		user << "<span class='alert'>You swipe the sequencer across [src]'s interface and watch its eyes flicker.</span>"
		src << "<span class='alert'>You feel a sudden burst of malware loaded into your execute-as-root buffer. Your tiny brain methodically parses, loads and executes the script.</span>"

		var/obj/item/weapon/card/emag/emag = W
		emag.uses--

		message_admins("[key_name_admin(user)] emagged drone [key_name_admin(src)].  Laws overridden.")
		log_game("[key_name(user)] emagged drone [key_name(src)].  Laws overridden.")
		var/time = time2text(world.realtime,"hh:mm:ss")
		lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")

		emagged = 1
		lawupdate = 0
		connected_ai = null
		remove_static_overlays()
		clear_supplied_laws()
		clear_inherent_laws()
		laws = new /datum/ai_laws/syndicate_override
		set_zeroth_law("Only [user.real_name] and people he designates as being such are operatives.")

		src << "<b>Obey these laws:</b>"
		laws.show_laws(src)
		src << "<span class='alert'>\b ALERT: [user.real_name] is your new master. Obey your new laws and his commands.</span>"
		return

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))

		if(stat == 2)

			if(!config.allow_drone_spawn || emagged || health < -35) //It's dead, Dave.
				user << "<span class='alert'>The interface is fried, and a distressing burned smell wafts from the robot's interior. You're not rebooting this one.</span>"
				return

			if(!allowed(usr))
				user << "<span class='alert'>Access denied.</span>"
				return

			user.visible_message("<span class='alert'>\the [user] swipes \his ID card through \the [src], attempting to reboot it.</span>", "<span class='alert'>You swipe your ID card through \the [src], attempting to reboot it.</span>")
			var/drones = 0
			for(var/mob/living/silicon/robot/drone/D in world)
				if(D.key && D.client)
					drones++
			if(drones < config.max_maint_drones)
				request_player()
			return

		else
			user.visible_message("<span class='alert'>\the [user] swipes \his ID card through \the [src], attempting to shut it down.</span>", "<span class='alert'>You swipe your ID card through \the [src], attempting to shut it down.</span>")

			if(emagged)
				return

			if(allowed(usr))
				shut_down()
			else
				user << "<span class='alert'>Access denied.</span>"

		return

	..()

//DRONE LIFE/DEATH

//For some goddamn reason robots have this hardcoded. Redefining it for our fragile friends here.
/mob/living/silicon/robot/drone/updatehealth()
	if(status_flags & GODMODE)
		health = 35
		stat = CONSCIOUS
		return
	health = 35 - (getBruteLoss() + getFireLoss())
	return

//Easiest to check this here, then check again in the robot proc.
//Standard robots use config for crit, which is somewhat excessive for these guys.
//Drones killed by damage will gib.
/mob/living/silicon/robot/drone/handle_regular_status_updates()
	if( health <= -35 || src.stat == DEAD )
		src << "<span class='warning'>You self-destructed due to critical damage.</span>"
		self_destruct()

	if( !in_operational_zone() )
		src << "<span class='warning'>You self-destructed because you left your operational zone.</span>"
		self_destruct()

	if( !master_fabricator )
		src << "<span class='warning'>You self-destructed because the drone server was destroyed.</span>"
		self_destruct()

	if( !client )
		src << "<span class='warning'>ERROR 405: Sentience not found.</span>"
		self_destruct()

	..()

/mob/living/silicon/robot/drone/handle_regular_hud_updates()
	if(!can_see_static()) //what lets us avoid the overlay
		if(static_overlays && static_overlays.len)
			remove_static_overlays()

/mob/living/silicon/robot/drone/proc/in_operational_zone()
	var/turf/T = get_turf(src)

	if( !T )
		return 0

	if( !isAlertZLevel( T.z ) && !istype( src.loc, /obj/spacepod ))
		return 0

	return 1

/mob/living/silicon/robot/drone/self_destruct()
	destroyCard()

	timeofdeath = world.time
	death() //Possibly redundant, having trouble making death() cooperate.
	gib()
	return

//DRONE MOVEMENT.
/mob/living/silicon/robot/drone/Process_Spaceslipping(var/prob_slip)
	//TODO: Consider making a magboot item for drones to equip. ~Z
	return 0

//CONSOLE PROCS
/mob/living/silicon/robot/drone/proc/law_resync()
	if(stat != 2)
		if(emagged)
			src << "<span class='warning'>You feel something attempting to modify your programming, but your hacked subroutines are unaffected.</span>"
		else
			src << "<span class='warning'>A reset-to-factory directive packet filters through your data connection, and you obediently modify your programming to suit it.</span>"
			full_law_reset()
			show_laws()

/mob/living/silicon/robot/drone/proc/shut_down()
	if(stat != 2)
		if(emagged)
			src << "<span class='warning'>You feel a system kill order percolate through your tiny brain, but it doesn't seem like a good idea to you.</span>"
		else
			src << "<span class='warning'>You feel a system kill order percolate through your tiny brain, and you obediently destroy yourself.</span>"
			self_destruct()

/mob/living/silicon/robot/drone/proc/full_law_reset()
	clear_supplied_laws()
	clear_inherent_laws()
	clear_ion_laws()
	laws = new /datum/ai_laws/drone

//Reboot procs.

/mob/living/silicon/robot/drone/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, "Cyborg"))
			continue
		if(O.client)
			if(O.client.prefs.beSpecial() & BE_PAI)
				question(O.client)

/mob/living/silicon/robot/drone/proc/question(var/client/C)
	spawn(0)
		if(!C || jobban_isbanned(C,"Cyborg"))	return
		var/response = alert(C, "Someone is attempting to reboot a maintenance drone. Would you like to play as one?", "Maintenance drone reboot", "Yes", "No", "Never for this round.")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)
		else if (response == "Never for this round")
			C.prefs.selected_character.job_antag ^= BE_PAI

/mob/living/silicon/robot/drone/proc/transfer_personality(var/client/player)

	if(!player) return

	src.ckey = player.ckey

	if(player.mob && player.mob.mind)
		player.mob.mind.transfer_to(src)

	lawupdate = 0
	src << "<b>Systems rebooted</b>. Loading base pattern maintenance protocol... <b>loaded</b>."
	full_law_reset()
	src << "<br><b>You are a maintenance drone, a tiny repair robot with no individual will, no personality, and no drives or urges other than your laws."
	src << "Use <b>;</b> to talk to other drones and <b>say</b> to speak silently to your nearby fellows."
	src << "Remember, you are <b>lawed against interference with the crew</b>. Also remember, <b>you DO NOT take orders from the AI.</b>"
	src << "<big><b>If a crewmember has noticed you, <i>you are probably breaking your third law</i></b></big>."


/mob/living/silicon/robot/drone/Bump(atom/movable/AM as mob|obj, yes)
	if (!yes || ( \
	 !istype(AM,/obj/machinery/door) && \
	 !istype(AM,/obj/machinery/recharge_station) && \
	 !istype(AM,/obj/machinery/disposal/deliveryChute) && \
	 !istype(AM,/obj/machinery/teleport/hub) && \
	 !istype(AM,/obj/effect/portal) && \
	 !istype(AM,/obj/multiz/stairs)
	)) return
	..()
	return

/mob/living/silicon/robot/drone/Bumped(AM as mob|obj)
	return

/mob/living/silicon/robot/drone/start_pulling(var/atom/movable/AM)

	if(istype(AM,/obj/item/pipe) || istype(AM,/obj/structure/disposalconstruct))
		..()
	else if(istype(AM,/obj/item))
		var/obj/item/O = AM
		if(O.w_class > 2)
			src << "<span class='warning'>You are too small to pull that.</span>"
			return
		else
			..()
	else
		src << "<span class='warning'>You are too small to pull that.</span>"
		return

/mob/living/silicon/robot/drone/proc/can_see_static()
	return !emagged && !syndicate

/mob/living/silicon/robot/drone/proc/add_static_overlays()
	remove_static_overlays()
	for(var/mob/living/living in mob_list)
		if(istype(living, /mob/living/silicon))
			continue
		var/image/chosen
		if(static_choice in living.static_overlays)
			chosen = living.static_overlays[static_choice]
		else
			chosen = living.static_overlays[1]
		static_overlays.Add(chosen)
		client.images.Add(chosen)

/mob/living/silicon/robot/drone/proc/remove_static_overlays()
	if(client)
		for(var/image/I in static_overlays)
			client.images.Remove(I)
	static_overlays.len = 0

/mob/living/silicon/robot/drone/examinate(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	if(ismob(A) && src.can_see_static()) //can't examine what you can't catch!
		usr << "Your vision module can't determine any of [A]'s features."
		return

	..()

/mob/living/silicon/robot/drone/add_robot_verbs()

/mob/living/silicon/robot/drone/remove_robot_verbs()
