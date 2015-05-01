//DIONA ORGANS.
/datum/organ/internal/diona
	removed_type = /obj/item/organ/diona

/datum/organ/internal/diona/process()
	return

/datum/organ/internal/diona/strata
	name = "neural strata"
	parent_organ = "chest"

/datum/organ/internal/diona/bladder
	name = "gas bladder"
	parent_organ = "head"

/datum/organ/internal/diona/polyp
	name = "polyp segment"
	parent_organ = "groin"

/datum/organ/internal/diona/ligament
	name = "anchoring ligament"
	parent_organ = "groin"

/datum/organ/internal/diona/node
	name = "receptor node"
	parent_organ = "head"
	removed_type = /obj/item/organ/diona/node

/datum/organ/internal/diona/nutrients
	name = "nutrient vessel"
	parent_organ = "chest"
	removed_type = /obj/item/organ/diona/nutrients

/obj/item/organ/diona
	name = "diona nymph"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "special" // Turns into a nymph instantly, no transplanting possible.

/obj/item/organ/diona/removed(var/mob/living/target,var/mob/living/user)

	..()
	var/mob/living/carbon/human/H = target
	if(!istype(target))
		del(src)

	if(!H.internal_organs.len)
		H.death()

	//This is a terrible hack and I should be ashamed.
	var/datum/seed/diona = seed_types["diona"]
	if(!diona)
		del(src)

	spawn(1) // So it has time to be thrown about by the gib() proc.
		var/mob/living/carbon/alien/diona/D = new(get_turf(src))
		diona.request_player(D)
		del(src)

// These are different to the standard diona organs as they have a purpose in other
// species (absorbing radiation and light respectively)
/obj/item/organ/diona/nutrients
	name = "nutrient vessel"
	organ_tag = "nutrient vessel"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/diona/nutrients/removed()
	return

/obj/item/organ/diona/node
	name = "receptor node"
	organ_tag = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/organ/diona/node/removed()
	return

//WRYN ORGAN

/datum/organ/internal/wryn/hivenode
	name = "antennae"
	parent_organ = "head"
	removed_type = /obj/item/organ/wryn/hivenode

/obj/item/organ/wryn/hivenode
	name = "antennae"
	organ_tag = "antennae"
	icon = 'icons/mob/human_races/r_wryn.dmi'
	icon_state = "antennae"

//CORTICAL BORER ORGANS.
/datum/organ/internal/borer
	name = "cortical borer"
	parent_organ = "head"
	removed_type = /obj/item/organ/borer
	vital = 1

/datum/organ/internal/borer/process()

	// Borer husks regenerate health, feel no pain, and are resistant to stuns and brainloss.
	for(var/chem in list("tricordrazine","tramadol","hyperzine","alkysine"))
		if(owner.reagents.get_reagent_amount(chem) < 3)
			owner.reagents.add_reagent(chem, 5)

	// They're also super gross and ooze ichor.
	if(prob(5))
		var/mob/living/carbon/human/H = owner
		if(!istype(H))
			return

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in H.vessel.reagent_list
		blood_splatter(H,B,1)
		var/obj/effect/decal/cleanable/blood/splatter/goo = locate() in get_turf(owner)
		if(goo)
			goo.name = "husk ichor"
			goo.desc = "It's thick and stinks of decay."
			goo.basecolor = "#412464"
			goo.update_icon()

/obj/item/organ/borer
	name = "cortical borer"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borer"
	organ_tag = "brain"
	desc = "A disgusting space slug."

/obj/item/organ/borer/removed(var/mob/living/target,var/mob/living/user)

	..()

	var/mob/living/simple_animal/borer/B = target.has_brain_worms()
	if(B)
		B.leave_host()
		B.ckey = target.ckey

	spawn(0)
		del(src)

//XENOMORPH ORGANS
/datum/organ/internal/xenos/eggsac
	name = "egg sac"
	parent_organ = "groin"
	removed_type = /obj/item/organ/xenos/eggsac

/datum/organ/internal/xenos/phoronvessel
	name = "phoron vessel"
	parent_organ = "chest"
	removed_type = /obj/item/organ/xenos/phoronvessel
	var/stored_phoron = 0
	var/max_phoron = 500

/datum/organ/internal/xenos/phoronvessel/queen
	name = "bloated phoron vessel"
	stored_phoron = 200
	max_phoron = 500

/datum/organ/internal/xenos/phoronvessel/sentinel
	stored_phoron = 100
	max_phoron = 300

/datum/organ/internal/xenos/phoronvessel/hunter
	name = "tiny phoron vessel"
	stored_phoron = 100
	max_phoron = 200

/datum/organ/internal/xenos/acidgland
	name = "acid gland"
	parent_organ = "head"
	removed_type = /obj/item/organ/xenos/acidgland

/datum/organ/internal/xenos/hivenode
	name = "hive node"
	parent_organ = "chest"
	removed_type = /obj/item/organ/xenos/hivenode

/datum/organ/internal/xenos/resinspinner
	name = "resin spinner"
	parent_organ = "head"
	removed_type = /obj/item/organ/xenos/resinspinner

/obj/item/organ/xenos
	name = "xeno organ"
	icon = 'icons/effects/blood.dmi'
	desc = "It smells like an accident in a chemical factory."

/obj/item/organ/xenos/eggsac
	name = "egg sac"
	icon_state = "xgibmid1"
	organ_tag = "egg sac"

/obj/item/organ/xenos/phoronvessel
	name = "phoron vessel"
	icon_state = "xgibdown1"
	organ_tag = "phoron vessel"

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	icon_state = "xgibtorso"
	organ_tag = "acid gland"

/obj/item/organ/xenos/hivenode
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "hive node"

/obj/item/organ/xenos/resinspinner
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "resin spinner"

//VOX ORGANS.
/datum/organ/internal/stack
	name = "cortical stack"
	removed_type = /obj/item/organ/stack
	parent_organ = "head"
	robotic = 2
	vital = 1
	var/backup_time = 0
	var/datum/mind/backup

/datum/organ/internal/stack/process()
	if(owner && owner.stat != 2 && !is_broken())
		backup_time = world.time
		if(owner.mind) backup = owner.mind

/datum/organ/internal/stack/vox
	removed_type = /obj/item/organ/stack/vox

/datum/organ/internal/stack/vox/stack

/obj/item/organ/stack
	name = "cortical stack"
	icon_state = "brain-prosthetic"
	organ_tag = "stack"
	robotic = 2
	prosthetic_name = null
	prosthetic_icon = null

/obj/item/organ/stack/vox
	name = "vox cortical stack"


/obj/item/organ/nucleation
	name = "nucleation organ"
	icon = 'icons/obj/surgery.dmi'
	desc = "A crystalized human organ. /red It has a strangely iridescent glow."

// Absorbs radiation and produces radium, which heals nucleations
/datum/organ/internal/nucleation/resonant_crystal
	name = "resonant crystal"
	parent_organ = "head"
	removed_type = /obj/item/organ/nucleation/resonant_crystal

/obj/item/organ/nucleation/resonant_crystal
	name = "resonant crystal"
	icon_state = "resonant-crystal"
	organ_tag = "resonant crystal"

// Let me see you with my special eyes!
/datum/organ/internal/eyes/luminescent_crystal
	name = "luminescent eyes"
	parent_organ = "head"
	removed_type = /obj/item/organ/nucleation/luminescent_crystal

/obj/item/organ/nucleation/luminescent_crystal
	name = "luminescent eyes"
	icon_state = "crystal-eyes"
	organ_tag = "luminescent eyes"
	l_color = "#1C1C00"

	New()
		SetLuminosity( 2 )

/datum/organ/internal/nucleation/strange_crystal // Does mysterious things, no one is sure what it does
	name = "strange crystal"
	parent_organ = "chest"
	removed_type = /obj/item/organ/nucleation/strange_crystal

/obj/item/organ/nucleation/strange_crystal
	name = "strange crystal"
	icon_state = "stramge-crystal"
	organ_tag = "strange crystal"

/datum/organ/internal/brain/crystal
	name = "crystalized brain"
	removed_type = /obj/item/organ/brain/crystal

/obj/item/organ/brain/crystal
	name = "crystalized brain"
	icon_state = "crystal-brain"
	organ_tag = "crystalized brain"