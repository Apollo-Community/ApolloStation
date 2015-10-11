/obj/item/forge/heated_metal
	name = "Forge superheated object holder"
	desc = "If you can see this description the code for the forge fucked up."
	icon = 'icons/obj/weapons_lab.dmi'
	icon_state = "holder_bar"
	origin_tech = "combat=2;materials=2"

	var/temperature = T20C

	process()
		if(temperature > 0)
			temperature -= 2+rand(4)
			force = temperature / 50
		else
			//sends a message to people in view range
			for(var/mob/M in viewers(src, null))
				M.show_message("\red The [src.name] has cooled down and reverts to its original form.")

			set_light(0)
			color = null
			temperature = 0
			processing_objects -= src

	pickup(mob/living/user)
		if(temperature > T20C+20)
			//only an idiot would pick up a superheated chunk of metal -sigh-
			user << "\red <B>You pick-up the [src.name]!</B>"
			user.adjustFireLoss(temperature / 50)
			user << "\red <B>Your hands burn!</B>"
			if(temperature > T20C+40)		//Just for you kwaky..
				user.drop_item()
				user.emote("scream")

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if( istype( W, /obj/item/weapon/tongs ))
			var/obj/item/weapon/tongs/T = W
			T.pick_up( src )
			T.icon_state = "tongs_heated"
			return

		..()

/obj/item/forge/heated_metal/ingot
	name = "Metal ingot"
	desc = "A bar of superheated metal"
	icon_state = "metal_ingot"
	origin_tech = "materials=3"
	matter = list("metal" = 450)

/obj/item/forge/scrap_metal
	name = "Scrap metal"
	desc = "A bent and crumpled piece of metal forged by a crappy blacksmith"
	icon = 'icons/obj/weapons_lab.dmi'
	icon_state = "scrap_metal"

//HOLDER WEAPONS		-- 		these will have their base stats modified in order to create "unique" weapons.
/obj/item/weapon/gun/forge
	name = "placeholder_gun"
	desc = "Placeholder gun for power-hammer. You really shouldn't be seeing this."
	icon = 'icons/obj/weapons_lab.dmi'
	icon_state = "holder_gun"

/obj/item/weapon/gun/forge/large
	name = "placeholder_gun_large"
	desc = "Placeholder large gun for power-hammer. You really shouldn't be seeing this."
	icon_state = "holder_gun_l"

/obj/item/weapon/forge
	name = "placeholder_blade"
	desc = "Placeholder blade for power-hammer. You really shouldn't be seeing this."
	icon = 'icons/obj/weapons_lab.dmi'
	icon_state = "holder_blade"

/obj/item/weapon/forge/throw
	name = "placeholder_throw"
	desc = "Placeholder throw for power-hammer. You really shouldn't be seeing this."
	icon_state = "holder_throw"

//UNIQUE WEAPONS		--		will be implemented when sprites are in existance. These will have their own special procs and inherit base stats from above.

