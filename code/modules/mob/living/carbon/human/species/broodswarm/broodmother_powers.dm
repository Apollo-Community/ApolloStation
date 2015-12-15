/mob/living/carbon/human/proc/expunge_tumor()
	set name = "Expunge Tumor"
	set desc = "Drops the hive tumor from your body, "
	set category = "Abilities"

	var/datum/organ/internal/xenos/phoronvessel/I = internal_organs_by_name["hive tumor"]

	if( !I )
		src << "You have no hive tumors left to drop!"

