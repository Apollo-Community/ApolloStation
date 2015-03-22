/obj/machinery/dispenser
	name = "Dispenser"
	desc = "Dispenses items. Duh."
	icon = 'icons/obj/vending.dmi'
	icon_state = "dispenser"

	var/dispense_item = null

/obj/machinery/dispenser/New()
	desc = "If you press the button, it will dispense a [dispense_item]!"

/obj/machinery/dispenser/attack_hand(mob/user as mob)
	var/obj/dispensed = new dispense_item
	user.put_in_hands(dispensed)
	user << "You press a button on the [src] and a [dispensed] pops out!"
	dispensed = null

	..()

/obj/machinery/dispenser/thunderdome
	name = "BK5 Injector Dispenser"
	dispense_item = /obj/item/weapon/reagent_containers/hypospray/autoinjector/adminorazine

/obj/machinery/dispenser/
	name = "Shotgun Dispenser"
	dispense_item = /obj/item/weapon/gun/projectile/shotgun/pump/combat