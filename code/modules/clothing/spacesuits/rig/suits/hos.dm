/obj/item/clothing/head/helmet/space/rig/hos
	light_overlay = "helmet_light_dual_green"

/obj/item/weapon/rig/combat
	name = "combat hardsuit control module"
	desc = "A black hardsuit designed for a Head of Security to wear during emergencies."
	icon_state = "security_rig"
	suit_type = "combat hardsuit"
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 15, bomb = 50, bio = 60, rad = 15)
	slowdown = 5
	offline_slowdown = 8
	offline_vision_restriction = 1

	helm_type = /obj/item/clothing/head/helmet/space/rig/combat
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/mounted/egun
		)
