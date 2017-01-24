////////////////////////////// Mysticflame98 - Fluffles the bunny /////////////////////////////////////////////////

/mob/living/simple_animal/bunny/fluff/fluffles
	name = "Fluffles"
	desc = "That's Fluffles the bunny! He looks like he wants a carrot."
	gender = MALE
	icon = 'icons/mob/animal.dmi'
	icon_state = "bunny_fuffles"
	icon_living = "bunny_fluffles"
	icon_dead = "bunny_fluffles_dead"
	holder_type = /obj/item/weapon/holder/bunny

	New()
		..()
		icon_state = "bunny_fuffles"
		icon_living = "bunny_fluffles"
		icon_dead = "bunny_fluffles_dead"

/mob/living/simple_animal/bunny/fluff/fluffles/custom_item

/mob/living/simple_animal/bunny/fluff/fluffles/custom_item/New()
	if (!contents.len)
		new/mob/living/simple_animal/bunny/fluff/fluffles (src)

/obj/item/weapon/holder/bunny/fluffles/New()
	..()
	new /mob/living/simple_animal/bunny/fluff/fluffles(src)

/obj/item/weapon/flame/lighter/zippo/fluff/nathan_yates //rawrtaicho: Riley Rohtin
	name = "Yates' black zippo"
	desc = "A black zippo lighter, which holds some form of sentimental value."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "blackzippo"
	icon_on = "blackzippoon"
	icon_off = "blackzippo"

////////////////////////////////////////////// Keywee + Lucien93 /////////////////////////////////////////////////

/obj/item/clothing/head/helmet/ert/fluff
	name = "emergency response team helmet"
	desc = "An in-atmosphere helmet worn by members of the NanoTrasen Emergency Response Team. This one doesn't look very protective."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "erthelmet_cmd"
	item_state = "syndicate-helm-green"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/ert/fluff/keywee
	name = "old emergency response team medical helmet"
	desc = "A white in-atmosphere helmet once worn by a medical officer for emergencies. More of a keepsake than protective headgear by now, it looks like its been through a lot."
	icon_state = "keywee"
	item_state = "keywee"

/obj/item/clothing/head/helmet/ert/fluff/lucien93
	name = "old emergency response team commander helmet"
	desc = "A blue in-atmosphere helmet once worn by a commander for emergencies. More of a keepsake than protective headgear by now, it looks like its been through a lot."
	icon_state = "lucien93"
	item_state = "lucien93"

////////////////////////////////// Greatmoon /////////////////////////////////////////////////

// Need to add in this stupid holder because Delta will spawn in the bag...
// Besides this holder getting created on round start, Delta can't be picked up normally
/obj/item/weapon/holder/delta
	name = "Delta"
	desc = "This is Delta the dog."
	icon = 'icons/obj/objects.dmi'
	icon_state = "german_shep"
	origin_tech = null

/obj/item/weapon/holder/delta/New()
	..()
	var/mob/doggy = new /mob/living/simple_animal/dog/german_shep/fluff/delta()
	doggy.loc = src

/mob/living/simple_animal/dog/german_shep/fluff/delta
	name = "Delta"
	desc = "This big puppy has thick, black and yellow fur."
	gender = MALE
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	health = 50
	maxHealth = 50
	var/max_distance = 4
	var/mob/living/carbon/human/bff
	var/turf/bff_last_loc
	var/turf/target_loc

/mob/living/simple_animal/dog/german_shep/fluff/delta/New()
	..()
	for( var/mob/living/carbon/human/M in living_mob_list )
		if (M.mind)
			if (M.mind.key == "Koenigsegg")
				bff = M
				break

/mob/living/simple_animal/dog/german_shep/fluff/delta/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	audible_emote("[pick("whimpers", "snarls", "yaps")] at [user]!")

/mob/living/simple_animal/dog/german_shep/fluff/delta/Life()
	..()
	if(client || stat)
		return

	if(!resting && !buckled)
		handle_movement_target()

	if (target_loc)
		return

	if (get_dist(src, bff) <= 1)
		if (prob(2))
			visible_emote(pick("sniffs [bff].", "nudges [bff]."))
			return

	if (get_dist(src, bff) <= max_distance)
		if (bff.stat >= DEAD || bff.health <= config.health_threshold_softcrit)
			if (prob((bff.stat < DEAD)? 50 : 15))
				audible_emote(pick("let out a [pick("lonely", "sad", "long", "agonizing")] howl.",
								   "howls.",
								   "whimpers.",
								   "whines."))
				return
		else if (bff.health <= 50)
			if (prob(10))
				audible_emote(pick("let out a [pick("low", "long", "short")] growl.", "growls.", "barks."))
				return
		else if (prob(1))
			audible_emote("barks at [bff].")
			return

	if (prob(2))
		visible_emote(pick("sniffs the air.", "wags his tail."))
	else if (prob(2))
		audible_emote(pick("pants.",
						   "sighs.",
						   "yawns."))
	else
		for(var/mob/living/simple_animal/ani in oview(src,5))
			if(ani.stat < DEAD && prob(5))
				audible_emote("[pick("barks", "whines")] at [ani].")
			break

/mob/living/simple_animal/dog/german_shep/fluff/delta/proc/handle_movement_target()
	var/can_see_bff = 0
	if (bff)
		if (bff in oview(src))
			can_see_bff = 1
			bff_last_loc = bff.loc

	var/follow_dist = max_distance
	if (bff.stat >= DEAD || bff.health <= config.health_threshold_softcrit || !(can_see_bff))
		follow_dist = 1
	else if (bff.stat || bff.health <= 50) //danger or just sleeping
		follow_dist = 2

	if (target_loc != bff.loc && (get_dist(src, bff) > follow_dist || !(can_see_bff)))
		if (can_see_bff)
			target_loc = bff.loc
		else if (bff_last_loc)
			target_loc = bff_last_loc
			bff_last_loc = null
		if (target_loc)
			walk_to(src,0) // stop existing movement
			stop_automated_movement = 1
			walk_to(src,target_loc,1,3)	// begin to walk now

	if (target_loc && get_dist(src, target_loc) <= 1)
		walk_to(src,0)
		target_loc = null
		stop_automated_movement = 0


/obj/item/clothing/suit/armor/vest/ert/command/replica
	name = "replica emergency response team commander armor"
	desc = "A replica set of armor worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights. This one seems to provide no real protection."
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/weapon/rig/unathi/fancy/ominousbrainworm
	name = "old breacher chassis control module"
	desc = "An old Unathi breacher chassis. Huge and bulky, it must be like wearing a rusty tank. It appears to provide no protection."
	suit_type = "breacher chassis"
	icon_state = "breacher_rig"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	initial_modules = list()
	vision_restriction = 0
	slowdown = 4

/obj/item/weapon/flame/lighter/zippo/fluff/ominousbrainworm
	name = "scratched zippo lighter"
	desc = "A very old zippo with what seems to be very deep claw marks on the sides."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sidier_zippo"
	icon_on = "sidier_zippoon"
	icon_off = "sidier_zippo"

////////// Kodos' Custom Stuff

/obj/item/device/assembly/signaler/fluff/kodosmacarthur
	name = "MI Remote Signalling Device"
	desc = "A high quality remote signalling device. It has a 'Macarthur Innovations' label on the back."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "kodos_signaler"
	item_state = "kodos_signaler"

/obj/item/clothing/suit/storage/toggle/labcoat/ominousbrainworm
	name = "Eriziki Sidier's labcoat"
	desc = "A labcoat that has a nametag noting that it belongs to Eriziki Sidier."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "labcoat_sidier_open"
	item_state = "labcoat_sidier"
	icon_open = "labcoat_sidier_open"
	icon_closed = "labcoat_sidier"

//////////////////// King_nexus

/obj/item/clothing/suit/dionalight/kingnexus
	name = "Bio-luminescent organ"
	desc = "Some sort of a bio-luminescent organ."
	icon_state = "dionalight_kingnexus"
	item_state = "dionalight_kingnexus"
	var/ison = 0 // Prevents adding more light each time equipped() is called (when picked up, put on slot etc).
	var/brightness_on = 5
	canremove = 0 // Yep, once you glue it on to your back you're stuck with it for the the rest of your life.
	slot_flags = SLOT_BACK


/obj/item/clothing/suit/dionalight/kingnexus/equipped(mob/user)
	spawn(1)
		if(loc == user && ison == 0)
			user.set_light(user.light_range + brightness_on, 5, "#00FFFF")
			ison = 1

/obj/item/clothing/suit/dionalight/kingnexus/dropped(mob/user)
	spawn(1)
		if(loc != user && ison == 1)
			user.set_light(user.light_range - brightness_on)
			ison = 0

//////  Nijishadow - Aya's Formal uniform
/obj/item/clothing/under/hosformalfem/fluff/nijishadow
	name = "Aya's Formal Uniform"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "aya_formal"
	item_state = "aya_formal"

//////  Nijishadow - Luna Vor labcoat
/obj/item/clothing/suit/storage/toggle/labcoat/cmo/fluff/luna_vor //NijiShadow: Luna Vor
	name = "Luna's labcoat"
	desc = "Darker than the standard model and with a dash of rainbow on the back."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "luna_labcoat_cmo"
	icon_open = "luna_labcoat_cmo_open"
	icon_closed = "luna_labcoat_cmo"
	item_state = "luna_labcoat_cmo"

/////// Draco16 mesons
/obj/item/clothing/glasses/meson/fluff/draco16
	name = "gar mesons"
	desc = "These mesons are the mesons that will see through the Heavens!"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "garm"
	item_state = "garm"


//////Haldreithen pipe
/obj/item/clothing/mask/cigarette/pipe/fluff/haldreithen
	name = "premium smoking pipe"
	desc = "A custom premium smoking pipe."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_off = "pipeoff"
	icon_on = "pipeon"

//////Pymal HoS Suit
/obj/item/clothing/suit/armor/hos/fluff/pygmal
	name = "padded head of personel uniform"
	desc = "Old Head of Security suits. Given as a gift by Central operatives to Lisa Willing"
	icon = 'icons/mob/suit.dmi'
	icon_state = "pygmal_suit"
	item_state = "pygmal_suit"

//////Faustico Plague Mask
 /obj/item/clothing/mask/gas/fluff/plaguefaustico
 	name = "premium smoking pipe"
 	desc = "A custom premium smoking pipe."
 	icon = 'icons/obj/clothing/masks.dmi'
 	icon_state = "plaguedoctor"
 	item_state = "plaguedoctor"

//////Rylana Steelclaw Advanced PDA
/obj/item/device/pda/fluff/rylanasteelclaw
	icon_state = "fluff-pda"
	desc = "A custom PDA with two screens. It seems rather advanced and has a golden plaque on the top, displaying the owner's first and last name."

/obj/item/device/pda/fluff/rylanasteelclaw/update_icon()
	..()

	overlays.Cut()
	if(new_message || new_news)
		overlays += image('icons/obj/pda.dmi', "fluff-pda-r")

/obj/item/device/pda/fluff/rylanasteelclaw/generateName()
	name = "Advanced PDA-[owner] ([ownjob])"

/////Haldreithen Formal Uniform
/obj/item/clothing/under/captainformal/fluff/haldreihen
	name = "Qilxuq's formal uniform"
	desc = "A formal uniform given to Qilxuq Xuqm for her good service. There is a short message thanking her for her good service embroided in one of the sleeves"
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "captain_formal"
	item_state = "captain_formal"


/////Silvia Shark tail
/obj/item/clothing/head/fluff/silviatail
	name = "fake shark tail"
	desc = "A very pristine tail clothing which makes the user look like they are a cute shark"
	icon_state = "shark_tail"
	item_state = "shark_tail" //Both of the icons (icon_state - item_state) are in the hats sprites files (icons/mob/heads.dmi and icons/items/clothings/hats) because the item is coded as a hat
