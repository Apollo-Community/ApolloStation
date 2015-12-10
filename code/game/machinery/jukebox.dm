//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

datum/track
	var/title
	var/sound

datum/track/New(var/title_name, var/audio)
	title = title_name
	sound = audio

/obj/machinery/media/jukebox/
	name = "space jukebox"
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2-nopower"
	var/state_base = "jukebox2"
	anchored = 1
	density = 1
	power_channel = EQUIP

	var/playing = 2

	var/stop_ticks = 0

	var/jukebox_id = 49			//Defines the sound channel to play on

	var/datum/track/current_track
	var/list/datum/track/tracks = list(
		new/datum/track("Clouds of Fire", 'sound/music/clouds.s3m'),
		new/datum/track("D`Fort", 'sound/music/mining_song.ogg'),
		new/datum/track("D`Fort Part 2", 'sound/music/mining_song1.ogg'),
		new/datum/track("Spelunker", 'sound/music/mining_song2.ogg'),
		new/datum/track("Encounter", 'sound/music/mining_song3.ogg'),
		new/datum/track("Floating", 'sound/music/main.ogg'),
		new/datum/track("Endless Space", 'sound/music/space.ogg'),
		new/datum/track("Trai`Tor", 'sound/music/traitor.ogg'),
		new/datum/track("Jukebox Hero", 'sound/music/jukeboxhero.ogg'),
		new/datum/track("Unknown Title", 'sound/music/sandstorm.ogg'),
		new/datum/track("Narwhals", 'sound/music/narwhal.ogg'),
		new/datum/track("Rasputin", 'sound/music/rasputin.ogg'),
		new/datum/track("Secret Agent", 'sound/music/midis/secretasian.mid'),
		new/datum/track("Waiting", 'sound/music/lobby.ogg'),
		new/datum/track("Exterminate", 'sound/music/courtneygears.ogg'),
		new/datum/track("Rising Sun", 'sound/music/midis/houseoftherisingsun.mid'),
		new/datum/track("Beyond the Sea", 'sound/music/midis/beyondthesea.mid'),
		new/datum/track("Bleach", 'sound/music/midis/Bleach_Asterisk.mid'),
		new/datum/track("Brown", 'sound/music/midis/cb-greatpumpkin.mid'),
		new/datum/track("Jack", 'sound/music/midis/whatsthis.mid'),
		new/datum/track("Keys", 'sound/music/midis/KH-Hikari.mid'),
		new/datum/track("Athletic", 'sound/music/midis/athletic.mid'),
		new/datum/track("Plumber", 'sound/music/midis/supermarioworld.mid'),
		new/datum/track("Plumber Part 2", 'sound/music/midis/overworld.mid'),
		new/datum/track("Cake", 'sound/music/midis/still_alive.mid'),
		new/datum/track("Bill E. Jewel", 'sound/music/midis/pianoman.mid'),
		new/datum/track("Rocket", 'sound/music/midis/rocketman.mid'),
		new/datum/track("Eileen", 'sound/music/midis/comeoneileen.mid'),
		new/datum/track("Falling Out", 'sound/music/midis/idontwant.mid'),
		new/datum/track("Velvet", 'sound/music/midis/bluevelvet.mid'),
		new/datum/track("NanoTrasen", 'sound/music/jazzy_jazz.ogg'),
		new/datum/track("Smartest People", 'sound/music/bakerstreet.ogg'),
		new/datum/track("Careless", 'sound/music/carelesswhisper.ogg'),
		new/datum/track("Long Ago", 'sound/music/midis/cantina.mid'),
	)

/obj/machinery/media/jukebox/New()
	..()
	for(var/obj/machinery/media/jukebox in machines)
		jukebox_id++

	MachineProcessing -= src				//Removes jukebox from processing machinery

//	tracks = sortList(tracks) // sorting for the sake of stuicey's sanity

/obj/machinery/media/jukebox/Destroy()
	StopPlaying()
	..()

/obj/machinery/media/jukebox/power_change()
	if(!powered(power_channel) || !anchored)
		stat |= NOPOWER
	else
		stat &= ~NOPOWER

	if(stat & (NOPOWER|BROKEN) && playing)
		StopPlaying()
	update_icon()

/obj/machinery/media/jukebox/update_icon()
	overlays.Cut()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		if(stat & BROKEN)
			icon_state = "[state_base]-broken"
		else
			icon_state = "[state_base]-nopower"
		return
	icon_state = state_base
	if(playing)
		if(emagged)
			overlays += "[state_base]-emagged"
		else
			overlays += "[state_base]-running"

/obj/machinery/media/jukebox/Topic(href, href_list)
	if(..() || !(Adjacent(usr) || istype(usr, /mob/living/silicon)))
		return

	if(!anchored)
		usr << "<span class='warning'>You must secure \the [src] first.</span>"
		return

	if(stat & (NOPOWER|BROKEN))
		usr << "\The [src] doesn't appear to function."
		return

	if(href_list["change_track"])
		for(var/datum/track/T in tracks)
			if(T.title == href_list["title"])
				current_track = T
				StartPlaying()
				break
	else if(href_list["stop"])
		StopPlaying()
	else if(href_list["play"])
		if(emagged)
			playsound(src.loc, 'sound/music/nyancat.ogg', 100, 1)
			for(var/mob/living/carbon/M in ohearers(6, src))
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
						continue
				M.sleeping = 0
				M.stuttering += 20
				M.ear_deaf += 30
				M.Weaken(3)
				if(prob(30))
					M.Stun(10)
					M.Paralyse(4)
				else
					M.make_jittery(500)
			spawn(278)
				explode()
		else if(current_track == null)
			usr << "No track selected."
		else
			StartPlaying()

	return 1

/obj/machinery/media/jukebox/interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		usr << "\The [src] doesn't appear to function."
		return

	ui_interact(user)

/obj/machinery/media/jukebox/ui_interact(mob/user, ui_key = "jukebox", var/datum/nanoui/ui = null, var/force_open = 1)
	var/title = "RetroBox - Space Style"
	var/data[0]

	if(!(stat & (NOPOWER|BROKEN)))
		data["current_track"] = current_track != null ? current_track.title : ""
		data["playing"] = playing

		var/list/nano_tracks = new
		for(var/datum/track/T in tracks)
			nano_tracks[++nano_tracks.len] = list("track" = T.title)

		data["tracks"] = nano_tracks

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "jukebox.tmpl", title, 450, 600)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/media/jukebox/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/media/jukebox/attack_hand(var/mob/user as mob)
	interact(user)

/obj/machinery/media/jukebox/proc/explode()
	walk_to(src,0)
	src.visible_message("<span class='danger'>\The [src] blows apart!</span>", 1)

	explosion(src.loc, 0, 0, 1, rand(1,2), 1)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	qdel(src)

/obj/machinery/media/jukebox/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if(istype(W, /obj/item/weapon/wrench))
		if(playing)
			StopPlaying()
		user.visible_message("<span class='warning'>[user] has [anchored ? "un" : ""]secured \the [src].</span>", "<span class='notice'>You [anchored ? "un" : ""]secure \the [src].</span>")
		anchored = !anchored
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		power_change()
		update_icon()
		return
	if(istype(W, /obj/item/weapon/card/emag))
		if(!emagged)
			emagged = 1
			StopPlaying()
			visible_message("<span class='danger'>\the [src] makes a fizzling sound.</span>")
			log_and_message_admins("emagged \the [src]")
			update_icon()
			return

	return ..()

/obj/machinery/media/jukebox/proc/StopPlaying()
	for(var/mob/living/M in living_mob_list)
		kill_sound(M)

	playing = 0
	MachineProcessing -= src			//Don't process() when not playing

	update_icon()

/obj/machinery/media/jukebox/proc/StartPlaying()
	StopPlaying()	// Stops Playing the sound, process() will begin the song.

	if(!current_track)
		return

	MachineProcessing += src			//Start process() back up
	playing = 1
	stop_ticks = 0

	update_icon()

/obj/machinery/media/jukebox/process()
	for(var/mob/living/M in living_mob_list)
		var/dist = get_dist(M,src)
		if(dist <=15 && M.z == src.z)	// Only same z-level
			if(playing)			//Plays the song to people within range while the song is active.
				if(!M.jukebox_sound)
					M.jukebox_sound = sound(current_track.sound, channel = jukebox_id, repeat = 1, volume = 35 - 3*(dist-1))
					M.jukebox_sound.status = SOUND_UPDATE
				else
					M.jukebox_sound.volume = 35 - 3*(dist-1)

				var/turf/turf_source = get_turf( src )
				M.jukebox_sound.x = (turf_source.x - M.x)*3 // Hearing from the west/east
				M.jukebox_sound.y = (turf_source.y - M.y)*3 // Hearing from north/south

				M << M.jukebox_sound
		else		// Catch all
			kill_sound(M)

/obj/machinery/media/jukebox/proc/kill_sound(var/mob/living/M in living_mob_list)
	if(M.jukebox_sound && M.jukebox_sound.channel == jukebox_id)	//Support for multiple jukeboxes
		M << sound(null, channel = jukebox_id)
		M.jukebox_sound = null

/obj/machinery/media/jukebox/mixer
	name = "record mixer"
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "mixer"
	state_base = "mixer"

/obj/machinery/media/jukebox/mixer/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if(istype(W, /obj/item/weapon/wrench))
		user << "<span class='warning'>You can't unwrench \the [src] because it's hooked up to a sound system!</span>"
		return

	return ..()
