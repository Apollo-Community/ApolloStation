///////This file is just for account items, not donator items. Event rewards and such can be added here.


/////ID
/obj/item/weapon/card/id/fluff/lifetime
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of NanoTrasen."
	icon_state = "centcom_old"

/datum/gear/account/lifetime_id
	display_name = "Lifetime ID Card"
	path = /obj/item/weapon/card/id/fluff/lifetime
	sort_category = "ID_card"
/////End ID
/////Gold Zippo (sprite credit to Linker)
/obj/item/weapon/flame/lighter/zippo/fluff/golden
	name = "golden zippo lighter"
	desc = "A golden zippo lighter gifted to some crew members by Central Command operatives"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zippo_gold_linker"
	icon_on = "zippoon_gold_linker"
	icon_off = "zippo_gold_linker"
	
/datum/gear/account/goldzippo
	display_name = "Gold Zippo Lighter"
	path = /obj/item/weapon/flame/lighter/zippo/fluff/golden
	sort_category = "misc"
/////End gold zippo
/////Gold Medal (Only needs Datum)
/datum/gear/account/goldmedalreward
	display_name = "Gold Honour Medal"
	path = /obj/item/clothing/tie/medal/gold/heroism
	sort_category = "misc"
/////End Medal
