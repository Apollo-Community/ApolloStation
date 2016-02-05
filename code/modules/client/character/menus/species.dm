/datum/character/proc/SpeciesMenu(mob/user)
	var/menu_name = "species_menu"

	if(!species_preview || !(species_preview in all_species))
		species_preview = "Human"
	var/datum/species/current_species = all_species[species_preview]
	var/dat = "<body>"
	dat += "<center><h2>[current_species.name] \[<a href='byond://?src=\ref[user];character=[menu_name];task=change'>change</a>\]</h2></center><hr/>"
	dat += "<table padding='8px'>"
	dat += "<tr>"
	dat += "<td width = 400>[current_species.blurb]</td>"
	dat += "<td width = 200 align='center'>"
	if("preview" in icon_states(current_species.icobase))
		usr << browse_rsc(icon(current_species.icobase,"preview"), "species_preview_[current_species.name].png")
		dat += "<img src='species_preview_[current_species.name].png' width='64px' height='64px'><br/><br/>"
	dat += "<b>Language:</b> [current_species.language]<br/>"
	dat += "<small>"
	if(current_species.flags & CAN_JOIN)
		dat += "</br><b>Often present on human stations.</b>"
	if(( current_species.flags & IS_WHITELISTED ) && !( current_species.name in unwhitelisted_aliens ))
		dat += "</br><b>Whitelist restricted.</b>"
	if(current_species.flags & NO_BLOOD)
		dat += "</br><b>Does not have blood.</b>"
	if(current_species.flags & NO_BREATHE)
		dat += "</br><b>Does not breathe.</b>"
	if(current_species.flags & NO_SCAN)
		dat += "</br><b>Does not have DNA.</b>"
	if(current_species.flags & NO_PAIN)
		dat += "</br><b>Does not feel pain.</b>"
	if(current_species.flags & NO_SLIP)
		dat += "</br><b>Has excellent traction.</b>"
	if(current_species.flags & NO_POISON)
		dat += "</br><b>Immune to most poisons.</b>"
	if(current_species.flags & HAS_SKIN_TONE)
		dat += "</br><b>Has a variety of skin tones.</b>"
	if(current_species.flags & HAS_SKIN_COLOR)
		dat += "</br><b>Has a variety of skin colours.</b>"
	if(current_species.flags & HAS_EYE_COLOR)
		dat += "</br><b>Has a variety of eye colours.</b>"
	if(current_species.flags & IS_PLANT)
		dat += "</br><b>Has a plantlike physiology.</b>"
	if(current_species.flags & IS_SYNTHETIC)
		dat += "</br><b>Is machine-based.</b>"
	if(current_species.flags & NO_CRYO)
		dat += "</br><b>Cannot use cryogenics.</b>"
	if(current_species.flags & NO_ROBO_LIMBS)
		dat += "</br><b>Cannot have robotic limbs.</b>"
	dat += "</small></td>"
	dat += "</tr>"
	dat += "</table><center><hr/>"

	if(config.usealienwhitelist )
		if(!is_alien_whitelisted( user, current_species.name ))
			dat += "<font color='red'><b>You cannot play as this species.</br><small>If you wish to be whitelisted, you can make an application post on <a href='byond://?src=\ref[user];character=open_whitelist_forum'>the forums</a>.</small></b></font></br>"
		else if(!(current_species.flags & CAN_JOIN) && !check_rights(R_ADMIN, 0))
			dat += "<font color='red'><b>You cannot play as this species.</br><small>This species is not available for play as a station race..</small></b></font></br>"
		else
			dat += "\[<a href='byond://?src=\ref[user];character=[menu_name];task=input;newspecies=[species_preview]'>select</a>\]"
	dat += "</center></body>"

	user << browse(dat, "window=[menu_name];size=700x400")

/datum/character/proc/SpeciesMenuProcess( mob/user, list/href_list )

