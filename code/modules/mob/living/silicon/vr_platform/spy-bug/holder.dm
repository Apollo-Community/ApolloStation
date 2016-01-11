/obj/item/weapon/holder/spybug
	name = "spy bug"
	desc = "It's a small robot bug with a microscopic camera and microphone."
	icon_state = "drone"
	icon = 'icons/obj/objects.dmi'
	origin_tech = "engineering=5 illegal=2"

// holder with spybug mob pre-packaged, used in uplink kit
/obj/item/weapon/holder/spybug/package/New()
	..()

	new /mob/living/silicon/platform/spybug( src )