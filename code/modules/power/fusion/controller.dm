global var/datum/fusion_controller/fusion_controller = new()

datum/fusion_controller

datum/fusion_controller/New()
	processing_objects.Add(src)
	..()

datum/fusion_controller/proc/process()