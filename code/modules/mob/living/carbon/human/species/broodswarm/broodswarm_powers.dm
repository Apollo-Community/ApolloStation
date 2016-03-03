/mob/living/carbon/human/proc/expunge_tumor()
	set name = "Expunge Tumor"
	set desc = "Drops the hive tumor from your body, creating a new hive."
	set category = "Abilities"

	var/datum/organ/internal/broodswarm/hive_tumor/I = internal_organs_by_name["hive tumor"]

	if( !I && istype(I) )
		src << "You have no hive tumors left to drop!"
		return

	src.visible_message("<span class='warning'>\The [src] digs into its flesh before ripping out a disgusting ball of meat.</span>", \
					    "<span class='warning'>You tear into your flesh and rip out your hive tumor.</span>")
	var/obj/item/organ/O

	O = I.remove(usr)
	if(O && istype(O))
		O.removed(usr,usr)
