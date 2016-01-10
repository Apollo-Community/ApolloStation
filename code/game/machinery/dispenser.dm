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
	dispense_items = list( 	 /obj/item/weapon/gun/projectile/shotgun/pump/combat,
							 /obj/item/weapon/gun/projectile/shotgun/pump,
							 /obj/item/weapon/gun/projectile/shotgun/doublebarrel,
							 /obj/item/weapon/gun/projectile/shotgun,
							 /obj/item/weapon/gun/projectile/mateba,
							 /obj/item/weapon/gun/projectile/russian,
							 /obj/item/weapon/gun/projectile/pistol,
							 /obj/item/weapon/gun/projectile/deagle,
							 /obj/item/weapon/gun/projectile/deagle/gold,
							 /obj/item/weapon/gun/projectile/silenced,
							 /obj/item/weapon/gun/projectile/automatic/l6_saw,
							 /obj/item/weapon/gun/projectile/automatic/c20r,
							 /obj/item/weapon/gun/projectile/automatic/mini_uzi,
							 /obj/item/weapon/gun/projectile/automatic,
							 /obj/item/weapon/gun/projectile/detective,
							 /obj/item/weapon/gun/projectile/detective/semiauto,
							 /obj/item/weapon/gun/projectile/detective/fluff/callum_leamas,
							 /obj/item/weapon/gun/energy/sniperrifle,
							 /obj/item/weapon/gun/energy/temperature,
							 /obj/item/weapon/gun/energy/toxgun,
							 /obj/item/weapon/gun/energy/mindflayer,
							 /obj/item/weapon/gun/energy/floragun,
							 /obj/item/weapon/gun/energy/decloner,
							 /obj/item/weapon/gun/energy/ionrifle,
							 /obj/item/weapon/gun/energy/pulse_rifle,
							 /obj/item/weapon/gun/energy/pulse_rifle/M1911,
							 /obj/item/weapon/gun/energy/pulse_rifle/destroyer,
							 /obj/item/weapon/gun/energy/xray,
							 /obj/item/weapon/gun/energy/laser,
							 /obj/item/weapon/gun/energy/laser/retro,
							 /obj/item/weapon/gun/energy/taser,
							 /obj/item/weapon/gun/energy/gun,
							 /obj/item/weapon/gun/energy/gun/nuclear,
							 /obj/item/weapon/gun/energy/lasercannon)