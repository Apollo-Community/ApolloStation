/datum/hud/proc/larva_hud()

	src.adding = list()
	src.other = list()

	var/obj/screen/using

	using = new
	using.name = "mov_intent"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_acti
	using.layer = 20
	src.adding += using
	move_intent = using

	mymob.healths = new
	mymob.healths.icon = 'icons/mob/screen1_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	mymob.blind = new
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

	mymob.fade = new /obj/screen()
	mymob.fade.icon = 'icons/mob/screen1_full.dmi'
	mymob.fade.icon_state = "unfaded"
	mymob.fade.name = " "
	mymob.fade.screen_loc = "1,1"
	mymob.fade.layer = 18

	mymob.flash = new
	mymob.flash.icon = 'icons/mob/screen1_alien.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	mymob.fire = new
	mymob.fire.icon = 'icons/mob/screen1_alien.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.client.screen = null
	mymob.client.screen += list( mymob.healths, mymob.blind, mymob.flash, mymob.fire, mymob.fade) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other