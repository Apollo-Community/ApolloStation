#define UI_SPACEPOD_DASH "1:0,13:0" // One lower than the rest, beacuse its double high
#define UI_SPACEPOD_FUEL "1:0,14:0"
#define UI_SPACEPOD_CHARGE "2:0,14:0"
#define UI_SPACEPOD_HEALTH "3:0,14:0"
#define UI_SPACEPOD_EXIT "4:0,14:0"
#define UI_SPACEPOD_LOCATE "5:0,14:0"
#define UI_SPACEPOD_CARGO "6:0,14:0"
#define UI_SPACEPOD_FIRE "7:0,14:0"
#define UI_SPACEPOD_DOOR "4:0,13:0"
#define UI_SPACEPOD_LIGHT "5:0,13:0"

/datum/hud/proc/spacepod_hud()
	var/obj/screen/dash = new /obj/screen()
	dash.icon = 'icons/mob/screen1_pod_dash.dmi'
	dash.icon_state = "dash"
	dash.name = "Dashboard"
	dash.screen_loc = UI_SPACEPOD_DASH
	dash.layer -= 0.01
	mymob.spacepod_dash = dash

	var/obj/screen/health = new /obj/screen()
	health.icon = 'icons/mob/screen1_pod.dmi'
	health.icon_state = "stat_off"
	health.name = "Spacepod Health"
	health.screen_loc = UI_SPACEPOD_HEALTH
	mymob.spacepod_health = health

	var/obj/screen/fuel = new /obj/screen()
	fuel.icon = 'icons/mob/screen1_pod.dmi'
	fuel.icon_state = "stat_off"
	fuel.name = "Spacepod Fuel"
	fuel.screen_loc = UI_SPACEPOD_FUEL
	mymob.spacepod_fuel = fuel

	var/obj/screen/charge = new /obj/screen()
	charge = new /obj/screen()
	charge.icon = 'icons/mob/screen1_pod.dmi'
	charge.icon_state = "stat_off"
	charge.name = "Spacepod Charge"
	charge.screen_loc = UI_SPACEPOD_CHARGE
	mymob.spacepod_charge = charge

	var/obj/screen/exit = new /obj/screen()
	exit.icon = 'icons/mob/screen1_pod.dmi'
	exit.icon_state = "exit"
	exit.name = "Exit Spacepod"
	exit.screen_loc = UI_SPACEPOD_EXIT
	mymob.spacepod_exit = exit

	var/obj/screen/locate = new /obj/screen()
	locate.icon = 'icons/mob/screen1_pod.dmi'
	locate.icon_state = "locate"
	locate.name = "Locate Sector"
	locate.screen_loc = UI_SPACEPOD_LOCATE
	mymob.spacepod_locate = locate

	var/obj/screen/cargo = new /obj/screen()
	cargo.icon = 'icons/mob/screen1_pod.dmi'
	cargo.icon_state = "cargo"
	cargo.name = "Access Cargo"
	cargo.screen_loc = UI_SPACEPOD_CARGO
	mymob.spacepod_cargo = cargo

	var/obj/screen/fire = new /obj/screen()
	fire.icon = 'icons/mob/screen1_pod.dmi'
	fire.icon_state = "fire"
	fire.name = "Fire Spacepod"
	fire.screen_loc = UI_SPACEPOD_FIRE
	mymob.spacepod_fire = fire

	var/obj/screen/door = new /obj/screen()
	door.icon = 'icons/mob/screen1_pod.dmi'
	door.icon_state = "door"
	door.name = "Toggle Nearby Pod Doors"
	door.screen_loc = UI_SPACEPOD_DOOR
	mymob.spacepod_door = door

	var/obj/screen/light = new /obj/screen()
	light.icon = 'icons/mob/screen1_pod.dmi'
	light.icon_state = "light"
	light.name = "Toggle Spacepod Lights"
	light.screen_loc = UI_SPACEPOD_LIGHT
	mymob.spacepod_light = light

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
								 mymob.fade )

#undef UI_SPACEPOD_DASH
#undef UI_SPACEPOD_HEALTH
#undef UI_SPACEPOD_FUEL
#undef UI_SPACEPOD_CHARGE
#undef UI_SPACEPOD_EXIT
#undef UI_SPACEPOD_LOCATE
#undef UI_SPACEPOD_CARGO
#undef UI_SPACEPOD_FIRE