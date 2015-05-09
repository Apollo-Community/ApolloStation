
/*====== MAGICAL DEV ENGINE =========*/
/obj/item/device/spacepod_equipment/engine/magic
	use_fuel = 0


/*====== Engines manufactured by the Newton Engines corporation =========*/
/obj/item/device/spacepod_equipment/engine/newton
	manufacturer = "Newton Engines"

/obj/item/device/spacepod_equipment/engine/newton/galileo
	name = "Galileo 2560 (engine)"
	desc = "A top-of-the-line engine in both efficiency and speed, but lacking in tank size."
	burn_rate = 0.018
	max_pressure = 10*ONE_ATMOSPHERE
	volume = 50.000
	ticks_per_move = 1
	charge_rate = 15

/obj/item/device/spacepod_equipment/engine/newton/fourier
	name = "Fourier J3 (engine)"
	desc = "An engine great for transport, but because of its low electrical output, it is not recommended for military ships."
	burn_rate = 0.020
	max_pressure = 10*ONE_ATMOSPHERE
	volume = 150.000
	ticks_per_move = 3
	charge_rate = 1