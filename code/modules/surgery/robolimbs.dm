//Procedures in this file: Robotic limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb/
	can_infect = 0
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (!affected)
			return 0
		if (!(affected.status & ORGAN_DESTROYED))
			return 0
		if (affected.parent)
			if (affected.parent.status & ORGAN_DESTROYED)
				return 0
		return affected.name != "head"


/datum/surgery_step/limb/cut
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return !(affected.status & ORGAN_CUT_AWAY)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].", \
		"You start cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'>[user] cuts away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>",	\
		"<span class='notice'>You cut away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>")
		affected.status |= ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("<span class='alert'>[user]'s hand slips, cutting [target]'s [affected.display_name] open!</span>", \
			"<span class='alert'>Your hand slips, cutting [target]'s [affected.display_name] open!</span>")
			affected.createwound(CUT, 10)


/datum/surgery_step/limb/mend
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return affected.status & ORGAN_CUT_AWAY && affected.open < 3 && !(affected.status & ORGAN_ATTACHABLE)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to reposition flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].", \
		"You start repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'>[user] has finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].</span>",	\
		"<span class='notice'>You have finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].</span>")
		affected.open = 3

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("<span class='alert'>[user]'s hand slips, tearing flesh on [target]'s [affected.display_name]!</span>", \
			"<span class='alert'>Your hand slips, tearing flesh on [target]'s [affected.display_name]!</span>")
			target.apply_damage(10, BRUTE, affected, sharp=1)


/datum/surgery_step/limb/prepare
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/flame/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 60
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return affected.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts adjusting the area around [target]'s [affected.display_name] with \the [tool].", \
		"You start adjusting the area around [target]'s [affected.display_name] with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>",	\
		"<span class='notice'>You have finished adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>")
		affected.status |= ORGAN_ATTACHABLE
		affected.amputated = 1
		affected.setAmputatedTree()
		affected.open = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.parent)
			affected = affected.parent
			user.visible_message("<span class='alert'>[user]'s hand slips, searing [target]'s [affected.display_name]!</span>", \
			"<span class='alert'>Your hand slips, searing [target]'s [affected.display_name]!</span>")
			target.apply_damage(10, BURN, affected)


/datum/surgery_step/limb/attach


	allowed_tools = list(/obj/item/robot_parts = 100)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/robot_parts/p = tool
			if (p.part)
				if (!(target_zone in p.part))
					return 0
			var/datum/organ/external/affected = target.get_organ(target_zone)
			return affected.status & ORGAN_ATTACHABLE

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)

		if( target.species.flags & NO_ROBO_LIMBS )
			user.visible_message("[user] goes to attach \the [tool] where [target]'s [affected.display_name] used to be, but realizes that isn't possible.", \
			"You go to attach \the [tool] where [target]'s [affected.display_name] used to be, but realize that isn't possible on [target].")
			return

		user.visible_message("[user] starts attaching \the [tool] where [target]'s [affected.display_name] used to be.", \
		"You start attaching \the [tool] where [target]'s [affected.display_name] used to be.")

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/robot_parts/L = tool
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'>[user] has attached \the [tool] where [target]'s [affected.display_name] used to be.</span>",	\
		"<span class='notice'>You have attached \the [tool] where [target]'s [affected.display_name] used to be.</span>")
		affected.germ_level = 0
		affected.robotize()
		if(L.sabotaged)
			affected.sabotaged = 1
		else
			affected.sabotaged = 0
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon()
		qdel(tool)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='alert'>[user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!</span>", \
		"<span class='alert'>Your hand slips, damaging connectors on [target]'s [affected.display_name]!</span>")
		target.apply_damage(10, BRUTE, affected, sharp=1)
