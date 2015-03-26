/obj/machinery/dispenser
	name = "Dispenser"
	desc = "Dispenses items. Duh."
	icon = 'icons/obj/vending.dmi'
	icon_state = "dispenser"

	var/list/dispense_items = list()

/obj/machinery/dispenser/New()
	..()
	desc = "If you press the button, it will dispense an item!"

/obj/machinery/dispenser/attack_hand(mob/user as mob)
	var/obj/D = pick( dispense_items )
	var/obj/dispensed = new D
	user.put_in_hands( dispensed )
	user << "You press a button on the [src] and a [dispensed] pops out!"
	dispensed = null

	..()

/obj/machinery/dispenser/BK5
	name = "BK5 Dispenser"
	dispense_items = list( /obj/item/weapon/reagent_containers/hypospray/autoinjector/adminorazine )

/obj/machinery/dispenser/combat_shotgun
	name = "Combat Shotgun Dispenser"
	dispense_items = list( /obj/item/weapon/gun/projectile/shotgun/pump/combat )

/obj/machinery/dispenser/random_ranged
	name = "Mystery Gun Dispenser"
	dispense_items = list( /obj/random/gun )