/obj/item/weapon/grenade/spawnergrenade
	desc = "It is set to detonate in 5 seconds. It will unleash unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"
	var/banglet = 0
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver
	det_time = 100

	prime()	// Prime now just handles the two loops that query for people in lockers and people who can see it.
		if(spawner_type && deliveryamt)
			// Make a quick flash
			var/turf/T = get_turf(src)
			playsound(T, 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/carbon/human/M in viewers(T, null))
				if(M:eyecheck() <= 0)
					flick("e_flash", M.flash)

			for(var/i=1, i<=deliveryamt, i++)
				var/atom/movable/x = new spawner_type
				x.loc = T
				if(prob(50))
					for(var/j = 1, j <= rand(1, 3), j++)
						step(x, pick(NORTH,SOUTH,EAST,WEST))

				// Spawn some hostile syndicate critters

		del(src)
		return

/obj/item/weapon/grenade/spawnergrenade/manhacks
	name = "manhack delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/spawnergrenade/bhole
	name = "black hole grenade"
	desc = "A highly-illegal and dangerous grenade which creates a small black hole which will suck up anything that isn't bolted down."
	spawner_type = /obj/machinery/singularity/mostly_harmless
	deliveryamt = 1
	origin_tech = "materials=3;magnets=7;syndicate=6"

	activate(mob/user as mob)
		..()
		for (var/mob/V in hearers(usr))
			V.show_message("\icon[icon]<b>[src]</b> states, \"Primed. Please clear the area.\"", 2)

	prime()	// Prime now just handles the two loops that query for people in lockers and people who can see it.
		// Make a quick flash
		for (var/mob/V in hearers(usr))
			V.show_message("\icon[icon]<b>[src]</b> states, \"Deployed.\"", 2)

		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/carbon/human/M in viewers(T, null))
			flick("e_flash", M.flash)
			M.Stun(rand(10, 50))

		var/obj/machinery/singularity/mostly_harmless/bh = new /obj/machinery/singularity/mostly_harmless
		bh.loc = T

		del(src)
		return