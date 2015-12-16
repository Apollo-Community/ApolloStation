/obj/machinery/atmospherics/unary
	dir = SOUTH
	initialize_directions = SOUTH
	//layer = TURF_LAYER+0.1

	var/datum/gas_mixture/air_contents

	var/obj/machinery/atmospherics/node

	var/datum/pipe_network/network

	New()
		..()
		initialize_directions = dir
		air_contents = new

		air_contents.volume = 200

// Housekeeping and pipe network stuff below
	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node)
			network = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	Destroy()
		loc = null

		if(node)
			node.disconnect(src)
			qdel(network)

		node = null

		..()

	initialize()
		if( src.node )
			return

		var/node_connect = dir

		for( var/obj/machinery/atmospherics/target in get_step( src,node_connect ))
			if( target.initialize_directions & get_dir( target,src ))
				if( check_connect_types( target, src ))
					src.node = target
					src.node.initialize()
					break

		update_icon()
		update_underlays()

	build_network()
		if( !network && node )
			network = new /datum/pipe_network()
			network.normal_members += src
			network.build_network(node, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node)
			return network

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network == old_network)
			network = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(network == reference)
			results += air_contents

		return results

	disconnect()
		qdel(network)
		node.disconnect(src)
		node = null

		update_icon()
		update_underlays()

		return null

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (istype(W, /obj/item/weapon/wrench))
			if (!(stat & NOPOWER) && use_power)
				user << "\red You cannot unwrench this [src], turn it off first."
				return 1

			var/turf/T = src.loc
			if (node && node.level==1 && isturf(T) && T.intact)
				user << "\red You must remove the plating first."
				return 1

			var/datum/gas_mixture/int_air = return_air()
			var/datum/gas_mixture/env_air = loc.return_air()

			add_fingerprint(user)

			if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
				user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
				return 1

			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)

			if( anchored )
				user << "\blue You begin to unfasten \the [src]..."
				if (do_after(user, 40))
					user.visible_message( \
						"[user] unfastens \the [src].", \
						"\blue You have unfastened \the [src].", \
						"You hear ratchet.")
					anchored = 0
					disconnect()
			else
				user << "\blue You begin to fasten \the [src]..."
				if (do_after(user, 40))
					user.visible_message( \
						"[user] fastens \the [src].", \
						"\blue You have fastened \the [src].", \
						"You hear ratchet.")
					anchored = 1
					initialize()

			return

		..()

	verb/rotate()
		set name = "Rotate"
		set category = "Object"
		set src in oview(1)

		if (src.anchored || usr:stat)
			usr << "It is fastened to the floor!"
			return 0
		src.set_dir(turn(src.dir, 270))
		src.initialize_directions = src.dir
		return 1