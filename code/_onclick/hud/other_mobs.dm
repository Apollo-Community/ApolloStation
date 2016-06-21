
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	return

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = ""
	mymob.blind.screen_loc = "1,1"
	mymob.blind.plane = -100
	mymob.blind.layer = 18

/datum/hud/proc/ai_hud()
	return

/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.layer = 20

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobhealthdisplay.layer = 20

	mymob.client.screen = null

	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)

/datum/hud/proc/ventcrawl_hud(var/remove = 0)
	if(remove)
		for(var/obj/screen/O in mymob.client.screen)
			if(O.tag == "position indicator")
				mymob.client.screen -= O
				qdel(O)
			if(O.tag == "pipe darkness")
				mymob.client.screen -= O
				qdel(O)
		return

	pipe_blind = new /obj/screen()
	pipe_blind.icon = 'icons/mob/screen1_full.dmi'
	pipe_blind.icon_state = "pipedark"
	pipe_blind.name = ""
	pipe_blind.tag = "pipe darkness"
	pipe_blind.screen_loc = "1,1"
	pipe_blind.plane = 0
	pipe_blind.layer = 18

	position_indicator = new /obj/screen()
	position_indicator.name = ""
	position_indicator.tag = "position indicator"
	position_indicator.icon = 'icons/effects/Targeted.dmi'
	position_indicator.icon_state = "locked"
	position_indicator.screen_loc = "CENTER"
	position_indicator.layer = 20

	mymob.client.screen += list(pipe_blind, position_indicator)