var/list/gateways = list()			//A list of all gateways avalible at the start of the round
var/list/awaygates = list()			//A list of all awaygates not avalible at the start of the round


/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = 1						//Does it block us?
	anchored = 1					//Is it anchored?
	var/active = 0					//Are we active?


/obj/machinery/gateway/center
	icon_state = "offcenter"

	var/awaygate = 0				//Are we an awaygate?
	var/centgate = 0				//Are we centcomm's gate?
	var/ready = 0					//Do we have all our parts?

	var/list/parts = list()			//List of all our gateway parts
	var/obj/machinery/gateway/center/link = null		//Who are we linked with?


/obj/machinery/gateway/initialize()
	update_icon()					//Update our icon,
	if(dir == 2)					//If we are facing south...
		density = 0					//We don't block movement.


/obj/machinery/gateway/center/initialize()
	update_icon()
	if(awaygate)					//If we are an awaygate...
		awaygates.Add(src)			//Add us to the awaygate list,
		return

	if(centgate)					//Else, if we are a gate in centcomm, add us to no list,
		return

	gateways.Add(src)				//Else, add us to the default gateway list.


/obj/machinery/gateway/update_icon()
	if(active)						//If we are active...
		icon_state = "on"			//Appear on,
		return

	icon_state = "off"				//Else, appear off.


/obj/machinery/gateway/center/update_icon()
	if(active)						//If we are active...
		icon_state = "oncenter"		//Appear on,
		return

	icon_state = "offcenter"		//Else, appear off.


obj/machinery/gateway/center/process()
	if(awaygate || centgate)		//If we are an awaygate or gate in centcomm, don't draw power,
		return

	if(stat & (NOPOWER))			//If we have no stat? or power...
		if(active) toggleoff()		//If we are active, turn us off,
		return

	if(active)						//Else if we have power and are active...
		use_power(5000)				//Use 5000 power.


/obj/machinery/gateway/center/proc/detect()
	parts = list()					//Clear the parts list
	var/turf/T = loc

	for(var/i in alldirs)			//For every direction...
		T = get_step(loc, i)		//Get the turf there,
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T		//Locate a gateway on that turf,
		if(G)						//If it exists...
			parts.Add(G)			//Add it to the parts list,
			continue

									//Else, if we don't find a part...
		ready = 0					//We arn't ready,
		toggleoff()					//We should turn off,
		break

	if(parts.len == 8)				//Else, if there is a gateway part in all directions...
		ready = 1					//We are ready.


/obj/machinery/gateway/center/proc/toggleon(mob/user as mob)
	if(!ready)			return		//If we arn't ready, don't turn on,
	if(!powered())		return		//Else, if we don't have but need power, don't turn on,
	if(awaygate)		return		//Else, if we are an awaygate, don't turn on,

	var/list/opengateways = gateways	//Else, populate the list opengateways with all current gateways,
	var/list/names = list()			//And create a list for names of the gateways,
	if(centgate || world.time > config.gateway_delay)		//If we are a gate in centcomm or the time is past the gateway_delay...
		opengateways += awaygates	//Add awaygates to opengateways,

	for(var/obj/machinery/gateway/center/C in opengateways)		//For every gateway in opengateways...
		names.Add(C.name)			//Add their name to the names list,

	var/name = input("Select Gateway") in names		//Prompt user for gateway from the names list,

	for(var/obj/machinery/gateway/center/C in opengateways)		//For every gateway in opengates....
		if(name == C.name)			//If its name is equal to the one given by the user...
			link = C				//Link the gateway to it.
			break

	if(link == null)	return		//If it doesn't exist, don't turn on,

	for(var/obj/machinery/gateway/G in parts)		//Else, for every gateway part in the parts list...
		G.active = 1				//Turn if on,
		G.update_icon()				//And update its icon,
	active = 1						//Become active,
	update_icon()					//And update our icon.


/obj/machinery/gateway/center/proc/toggleoff()
	for(var/obj/machinery/gateway/G in parts)		//For every gateway part in the parts list...
		G.active = 0				//Turn it off,
		G.update_icon()				//And update its icon,
	active = 0						//Become inactive,
	update_icon()					//And update our icon.


/obj/machinery/gateway/center/attack_hand(mob/user as mob)
	if(!ready)						//If we arn't ready...
		detect()					//Look for gateway parts,
		if(!ready)					//If we are still not ready...
			return					//Do nothing,

	if(!active)						//Else, if we are not on...
		toggleon(user)				//Turn on,
		return
	toggleoff()						//Else, turn off.


/obj/machinery/gateway/center/Bumped(atom/movable/M as mob|obj)
	if(!ready)		return			//If we are not ready, do nothing,
	if(!active)		return			//Else, if we are not active, do nothing
	if(!link)		return			//Else, if we are not linked, do nothing

	if(awaygate & istype(M, /mob/living/carbon))		//Else, if we are an awaygate and if the mob is a carbon...
		for(var/obj/item/weapon/implant/exile/E in M)		//For every exile implant on the mob...
			if(E.imp_in == M)		//If the implant is implanted...
				M << "\black The station gate has detected your exile implant and is blocking your entry."		//Tell them they can't come back,
				return				//And do nothing,

	M.loc = get_step(link.loc, SOUTH)		//Else, teleport the mob to the link's location...
	M.set_dir(SOUTH)				//And make it face south.

