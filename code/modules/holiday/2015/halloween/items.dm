/obj/item/weapon/coin/pumpkin
	name = "pumkin coin"
	desc = "This orange coin has the letter \"H\" engraved on it. Perhaps it can be used in a vending machine?"
	icon = 'icons/obj/event_items.dmi'
	icon_state = "coin_pumpkin"

/datum/gear/account/pumpkin_zippo
	display_name = "Pumpkin coin"
	path = /obj/item/weapon/coin/pumpkin
	sort_category = "misc"

/obj/item/weapon/flame/lighter/zippo/pumpkin //mangled: Li Matsuda
	name = "pumpkin zippo lighter"
	desc = "A black zippo lighter with a pumpkin painted on the side."
	icon = 'icons/obj/event_items.dmi'
	icon_state = "pumpkinzippo"
	icon_on = "pumpkinzippoon"
	icon_off = "pumpkinzippo"

/datum/gear/account/pumpkin_zippo
	display_name = "Pumpkin zippo"
	path = /obj/item/weapon/flame/lighter/zippo/pumpkin
	sort_category = "misc"

/obj/item/clothing/mask/broodlace
	name = "bone necklace"
	desc = "A necklace made from the bones of a great foe."
	icon_state = "broodlace"
	item_state = "broodlace"
	w_class = 1
	gas_transfer_coefficient = 0

/datum/gear/account/broodlace
	display_name = "Bone necklace"
	path = /obj/item/clothing/mask/broodlace
	sort_category = slot_wear_mask

/obj/item/clothing/head/broodmask
	name = "Broodmother mask"
	desc = "The terrifying mask of a true horror."
	icon_state = "broodmask"
	item_state = "broodmask"
	w_class = 1
	gas_transfer_coefficient = 0

/datum/gear/account/broodmask
	display_name = "Broodmother mask"
	path = /obj/item/clothing/head/broodmask
	sort_category = slot_head