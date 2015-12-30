#define UI_SPACEPOD_DASH "1:0,13:0" // One lower than the rest, beacuse its double high
#define UI_SPACEPOD_FUEL "1:0,14:0"
#define UI_SPACEPOD_CHARGE "2:0,14:0"
#define UI_SPACEPOD_HEALTH "3:0,14:0"
#define UI_SPACEPOD_EXIT "4:0,14:0"
#define UI_SPACEPOD_DOOR "5:0,14:0"
#define UI_SPACEPOD_LIGHT "6:0,14:0"
#define UI_SPACEPOD_BLUESPACE "7:0,14:0"
#define UI_SPACEPOD_LOCATE "4:0,13:0"
#define UI_SPACEPOD_CARGO "5:0,13:0"
#define UI_SPACEPOD_FIRE "6:0,13:0"

/obj/screen/spacepod
	icon = 'icons/mob/screen1_pod.dmi'

/obj/screen/spacepod/dashboard
	icon = 'icons/mob/screen1_pod_dash.dmi'
	icon_state = "dash"
	name = "Dashboard"
	screen_loc = UI_SPACEPOD_DASH

/obj/screen/spacepod/health
	icon_state = "stat_off"
	name = "Spacepod Health"
	screen_loc = UI_SPACEPOD_HEALTH

/obj/screen/spacepod/fuel
	icon_state = "stat_off"
	name = "Spacepod Fuel"
	screen_loc = UI_SPACEPOD_FUEL

/obj/screen/spacepod/charge
	icon_state = "stat_off"
	name = "Spacepod Charge"
	screen_loc = UI_SPACEPOD_CHARGE

/obj/screen/spacepod/exit
	icon_state = "exit"
	name = "Exit Spacepod"
	screen_loc = UI_SPACEPOD_EXIT

/obj/screen/spacepod/locate
	icon_state = "locate"
	name = "Locate Sector"
	screen_loc = UI_SPACEPOD_LOCATE

/obj/screen/spacepod/cargo
	icon_state = "cargo"
	name = "Access Cargo"
	screen_loc = UI_SPACEPOD_CARGO

/obj/screen/spacepod/fire
	icon_state = "fire"
	name = "Fire Spacepod"
	screen_loc = UI_SPACEPOD_FIRE

/obj/screen/spacepod/door
	icon_state = "door"
	name = "Toggle Nearby Pod Doors"
	screen_loc = UI_SPACEPOD_DOOR

/obj/screen/spacepod/light
	icon_state = "light"
	name = "Toggle Spacepod Lights"
	screen_loc = UI_SPACEPOD_LIGHT

/obj/screen/spacepod/bluespace
	icon_state = "bluespace"
	name = "Use Bluespace Gate"
	screen_loc = UI_SPACEPOD_BLUESPACE

/datum/hud/proc/spacepod_hud()
	mymob.spacepod_dash = new /obj/screen/spacepod/dashboard()
	mymob.spacepod_health = new /obj/screen/spacepod/health()
	mymob.spacepod_fuel = new /obj/screen/spacepod/fuel()
	mymob.spacepod_charge = new /obj/screen/spacepod/charge()
	mymob.spacepod_exit =  new /obj/screen/spacepod/exit()
	mymob.spacepod_locate = new /obj/screen/spacepod/locate()
	mymob.spacepod_cargo = new /obj/screen/spacepod/cargo()
	mymob.spacepod_fire = new /obj/screen/spacepod/fire()
	mymob.spacepod_door = new /obj/screen/spacepod/door()
	mymob.spacepod_light = new /obj/screen/spacepod/light()
	mymob.spacepod_bluespace = new /obj/screen/spacepod/bluespace()

	mymob.client.screen += list( mymob.spacepod_dash,
								 mymob.spacepod_health,
								 mymob.spacepod_fuel,
								 mymob.spacepod_charge,
								 mymob.spacepod_exit,
								 mymob.spacepod_locate,
								 mymob.spacepod_cargo,
								 mymob.spacepod_fire,
								 mymob.spacepod_door,
								 mymob.spacepod_light,
								 mymob.spacepod_bluespace,
								 mymob.fade )

/datum/hud/proc/remove_spacepod_hud()
	mymob.client.screen -= list( mymob.spacepod_dash,
								 mymob.spacepod_health,
								 mymob.spacepod_fuel,
								 mymob.spacepod_charge,
								 mymob.spacepod_exit,
								 mymob.spacepod_locate,
								 mymob.spacepod_cargo,
								 mymob.spacepod_fire,
								 mymob.spacepod_door,
								 mymob.spacepod_light,
								 mymob.spacepod_bluespace,
								 mymob.fade )

#undef UI_SPACEPOD_DASH
#undef UI_SPACEPOD_HEALTH
#undef UI_SPACEPOD_FUEL
#undef UI_SPACEPOD_CHARGE
#undef UI_SPACEPOD_EXIT
#undef UI_SPACEPOD_LOCATE
#undef UI_SPACEPOD_CARGO
#undef UI_SPACEPOD_FIRE