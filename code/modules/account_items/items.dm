///////This file is just for account items, not donator items. Event rewards and such can be added here.


/////CentCom ID (Only for characters promoted to NT Officials jobs.)
/datum/gear/account/centcom_id
	display_name = "CentCom ID"
	path = /obj/item/weapon/card/id/centcom
	sort_category = "ID_card"
/////CentCom ID End
/////End ID
/obj/item/weapon/card/id/fluff/lifetime
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of NanoTrasen."
	icon_state = "centcom_old"

/datum/gear/account/lifetime_id
	display_name = "Lifetime ID Card"
	path = /obj/item/weapon/card/id/fluff/lifetime
	sort_category = "ID_card"
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
/////Survivor Zippo (sprite credit to Imborgoss)
/obj/item/weapon/flame/lighter/zippo/fluff/survivor
	name = "survivor zippo"
	desc = "A rugged custom-made zippo gifted to some crew members by Central Command operatives"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zippo_vivor"
	icon_on = "zippo_vivor_on"
	icon_off = "zippo_vivor"

/datum/gear/account/survivorzippo
	display_name = "Survivor Zippo Lighter"
	path = /obj/item/weapon/flame/lighter/zippo/fluff/survivor
	sort_category = "misc"
/////End survivor zippo
/////Gold Medal (Only needs Datum)
/datum/gear/account/goldmedalreward
	display_name = "Gold Heroism Medal"
	path = /obj/item/clothing/tie/medal/gold/heroism
	sort_category = "misc"
/////End Medal
//// Koenigsegg's account item test
/obj/item/weapon/holder/delta
	name = "Delta"
	desc = "This is Delta the dog."
	icon = 'icons/obj/objects.dmi'
	icon_state = "german_shep"
	origin_tech = null

/datum/gear/account/delta
	display_name = "Delta"
	path = /mob/living/simple_animal/dog/german_shep/fluff/delta
	sort_category = "misc"

/////Rylana Steelclaw Advanced PDA datum
/datum/gear/account/advancedpda
	display_name = "Advanced PDA"
	path = /obj/item/device/pda/fluff/rylanasteelclaw
	sort_category = slot_belt