#define UI_SPACEPOD_HEALTH "1:0,2:0"
#define UI_SPACEPOD_FUEL "1:0,3:0"
#define UI_SPACEPOD_CHARGE "1:0,4:0"

/datum/hud/proc/spacepod_hud()

	mymob.spacepod_health = new /obj/screen()
	mymob.spacepod_health.icon = 'icons/mob/screen1_pod.dmi'
	mymob.spacepod_health.icon_state = "health0"
	mymob.spacepod_health.name = "Health"
	mymob.spacepod_health.screen_loc = UI_SPACEPOD_HEALTH

	mymob.spacepod_fuel = new /obj/screen()
	mymob.spacepod_fuel.icon = 'icons/mob/screen1_pod.dmi'
	mymob.spacepod_fuel.icon_state = "fuel0"
	mymob.spacepod_fuel.name = "Fuel"
	mymob.spacepod_fuel.screen_loc = UI_SPACEPOD_FUEL

	mymob.spacepod_charge = new /obj/screen()
	mymob.spacepod_charge.icon = 'icons/mob/screen1_pod.dmi'
	mymob.spacepod_charge.icon_state = "charge-empty"
	mymob.spacepod_charge.name = "Charge"
	mymob.spacepod_charge.screen_loc = UI_SPACEPOD_CHARGE

	mymob.client.screen = list(
								mymob.spacepod_health,
								mymob.spacepod_fuel,
								mymob.spacepod_charge,
								mymob.fade
							)



/datum/hud/proc/remove_spacepod_hud()
	mymob.client.screen -= list(
							mymob.spacepod_health,
							mymob.spacepod_fuel,
							mymob.spacepod_charge
							)

#undef UI_SPACEPOD_HEALTH
#undef UI_SPACEPOD_FUEL
#undef UI_SPACEPOD_CHARGE
