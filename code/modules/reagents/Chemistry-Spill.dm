/obj/effect/decal/chemspill
	name = "chemical spill" // Specific reagents should be able to rename the spill. Such as uranium becoming "radioactive waste", or paint becoming "wet paint"
	desc = "someone should probably clean that up." // Should also be able to be set by reagents.
	icon = 'icons/effects/effects.dmi'
	icon_state = "spill_half" // There are spill effects for liquids and solids. Prefixed by "liq" and "sol" respectively. "liq half" should be used for 120u or higher. "liq full" for 240u.
	unacidable = 1 // We should really redo acid in general so we don't have to do this all the time.
	layer = 2.35 // Above floors, below as much as possible.
	var/processing = 0 // Whether this spill has any chemicals in it that need to process occasionally.
	reagents = new/datum/reagents(240)
	var/statenumber = 1 // A randomized number between 1 and 7 used for the spill icon. Prevents tiny changes to volume from resulting in icon changing.

/obj/effect/decal/chemspill/New()
	reagents.my_atom = src
	statenumber = rand(1,5)


/obj/effect/decal/chemspill/update_icon()
	if(!reagents.total_volume)
		qdel(src)
		return

	if(reagents.total_volume < 40)
		icon_state = "spill_[statenumber]s"
	else if(reagents.total_volume < 80)
		icon_state = "spill_[statenumber]"
	else if(reagents.total_volume >= 120)
		icon_state = "spill_x"
	else
		icon_state = "spill_[statenumber]l"


	//var/image/temp = image('icons/effects/effects.dmi', src, "[icon_state]")
	//temp.icon += rgb(255,255,255)
	color = mix_color_from_reagents(reagents.reagent_list)
	alpha = min(mix_alpha_from_reagents(reagents.reagent_list), 255)
	//overlays = list() // Overlays.Cut() isn't working for some reason? :c
	//overlays += temp

/obj/effect/decal/chemspill/Crossed(var/atom/A)
	if(reagents.total_volume < 1)
		qdel(src)
		return
	if(!istype(A, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/perp = A
	var/datum/organ/external/l_foot = perp.get_organ("l_foot")
	var/datum/organ/external/r_foot = perp.get_organ("r_foot")
	var/hasfeet = 1
	if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
		hasfeet = 0
	if(perp.shoes && !perp.buckled)//Adding blood to shoes
		var/obj/item/clothing/shoes/S = perp.shoes
		reagents.trans_to_holder(S.track_spill, round(min(reagents.total_volume/10, 12)-S.track_spill.total_volume))
		S.generate_blood_overlay()
	else if (hasfeet)//Or feet
		reagents.trans_to_holder(perp.track_spill, round(min(reagents.total_volume/10, 12)-perp.track_spill.total_volume)) // Transfer 10% of the spill, or 12 units. Whichever is smaller. 12 units will last 12 steps.
	else if (perp.buckled && istype(perp.buckled, /obj/structure/stool/bed/chair/wheelchair))
		var/obj/structure/stool/bed/chair/wheelchair/W = perp.buckled
		W.bloodiness = 4

	perp.update_inv_shoes(1)

/obj/effect/decal/chemspill/process()
	if(processing)
		var/found = 0
		for (var/datum/reagent/R in reagents.reagent_list)
			if(R.processing)
				R.process()
				found = 1
		if(!found)
			processing = 0 // Avoid processing stuff that doesnt need to be processed anymore.
		else
			update_icon() // Assume that the process affected the chemicals, or the volume.
	if(reagents.total_volume > 240)
		spillover()

/obj/effect/decal/chemspill/proc/spillover() // Placeholder for flooding mechanics.
	return

/obj/effect/decal/chemspill/proc/AddTracks(var/atom/A, var/turf/T) // Replaces bloody footprints.

	if(T == get_turf(src))
		return
	var/footprint_dir = get_step(src,T)
	world << "[footprint_dir]"

	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/tracker = A
		var/datum/organ/external/l_foot = tracker.get_organ("l_foot")
		var/datum/organ/external/r_foot = tracker.get_organ("r_foot")
		var/hasfeet = 0
		if((l_foot || !(l_foot.status & ORGAN_DESTROYED)) && (r_foot || !(r_foot.status & ORGAN_DESTROYED)))
			hasfeet = 1
		if(tracker.shoes && hasfeet)
			var/obj/item/clothing/shoes/S = tracker.shoes
			if(S.track_spill.total_volume)
				var/image/footprint = image('icons/effects/effects.dmi', src, "footprint_shoe")
				footprint.color = mix_color_from_reagents(S.track_spill.reagent_list)
				footprint.alpha = min(mix_alpha_from_reagents(S.track_spill.reagent_list), 255)
				S.track_spill.trans_to_holder(reagents, min(1, S.track_spill.total_volume))
				footprint.dir = footprint_dir
				for(var/obj/effect/decal/chemspill/C in T)
					C.overlays += footprint
				footprint.dir = turn(footprint_dir, 180)
				overlays += footprint

		else
			if(tracker.track_spill.total_volume && hasfeet)
				var/image/footprint = image('icons/effects/effects.dmi', src, "footprint_[tracker.species.footprint_type]")
				footprint.color = mix_color_from_reagents(tracker.track_spill.reagent_list)
				footprint.alpha = min(mix_alpha_from_reagents(tracker.track_spill.reagent_list), 255)
				tracker.track_spill.trans_to_holder(reagents, min(1, tracker.track_spill.total_volume))
				footprint.dir = footprint_dir
				for(var/obj/effect/decal/chemspill/C in T)
					C.overlays += footprint
				footprint.dir = turn(footprint_dir, 180)
				overlays += footprint
	else if(istype(A, /mob/living/silicon))
		var/mob/living/silicon/tracker = A
		var/image/footprint = image('icons/effects/effects.dmi', src, "footprint_tracks")
		footprint.color = mix_color_from_reagents(tracker.track_spill.reagent_list)
		footprint.alpha = min(mix_alpha_from_reagents(tracker.track_spill.reagent_list), 255)
		tracker.track_spill.trans_to_holder(reagents, min(1, tracker.track_spill.total_volume))
		footprint.dir = footprint_dir
		for(var/obj/effect/decal/chemspill/C in T)
			C.overlays += footprint
		footprint.dir = turn(footprint_dir, 180)
		overlays += footprint
	//reagents.react()


// A is the atom passing through, leaving the tracks. Tracks are left depending on the type and size. Mobs leave footprints, claws, pawprints. Objects or mobs dragged leave smears, etc.
// T is the turf the atom is coming from. This determines the tracks direction on both.
// Going determines if the tracks come from, or go to, this turf. This affects a bit of direction stuff, and saves on a few calculations for previous turf tracking.
// Generally, we want to leave 1 unit for every 2 turfs crossed. Except for large smears, which should leave 3 units per turf crossed (for a total of 3 units per turf.)
// So: Dragging a bloody corpse leaves thrice as much blood as walking through with wet feet.
	return
/*
				var/obj/item/clothing/shoes/S = H.shoes
				if(S.track_spill.total_volume)
					var/obj/effect/decal/chemspill/spill
					for(var/obj/effect/decal/chemspill/C in src)
						if(C)
							spill = C
							break
					if(spill)
						S.track_spill.trans_to_holder(spill.reagents, min(1, S.track_spill.total_reagents))
					else
						spill = new/obj/effect/decal/chemspill()
						if(spill.reagents.total_volume + 1 > spill.reagents.maximum_volume)
							spill.reagents.maximum_volume = spill.reagents.total_volume + 1
						H.track_spill.trans_to_holder(spill.reagents, min(1, H.track_spill.total_reagents))
						spill.update_icon()
				*/

/*

TODO:

> Port Blood Over
> Port Tracks Over
> Implement Spillover Proc
> Add Chemical Process Controller

*/