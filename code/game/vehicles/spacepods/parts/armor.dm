/obj/item/pod_parts/armor
	var/health_bonus = 100 // How much health the armor adds onto the spacepod
	var/equipment_size = 5 // How much space there is for equipment
	var/pod_icon = "pod"   // What the pod looks like with this equipped
	var/pod_fire_icon = "pod_fire" // Icon for fire
	var/pod_damage_icon = "pod_damage"

/obj/item/pod_parts/armor/command
	name = "command pod armor"
	icon = 'icons/pods/pod_parts.dmi'
	icon_state = "pod_armor_com"
	desc = "Spacepod armor. This is the command version. It looks rather flimsy."
	health_bonus = 150
	equipment_size = 5
	pod_icon = "pod_com"

/obj/item/pod_parts/armor/security
	name = "security pod armor"
	icon = 'icons/pods/pod_parts.dmi'
	icon_state = "pod_armor_sec"
	desc = "Spacepod armor. This is the security version. It looks sturdy."
	health_bonus = 300
	equipment_size = 9
	pod_icon = "pod_sec"

/obj/item/pod_parts/armor/shuttle
	name = "shuttle pod armor"
	icon = 'icons/pods/pod_parts.dmi'
	icon_state = "pod_armor_shuttle"
	desc = "Spacepod armor. This type of armor makes the pod into a transport shuttle."
	equipment_size = 12 // it is a transport shuttle, after all
	pod_icon = "pod_shuttle"
