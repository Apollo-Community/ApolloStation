bolt/force
	Effect(obj/o)
		set waitfor = 0

		// delayed spawn
		o.alpha = rand(0, 40)
		sleep(rand(0, 3))
		o.alpha = 255

		animate(o, alpha = 0, time = 255 / rand(fade * 0.8, fade * 1.2), loop = -1)


mob
	var/tmp/list/attached

	mouse_over_pointer = MOUSE_HAND_POINTER

	proc
		refresh()
			for(var/mob/m in attached)
				detach(m)
				attach(m)

		attach(mob/m)
			var/vector/start = new (src.x * world.icon_size + world.icon_size / 2, src.y * world.icon_size + world.icon_size / 2)
			var/vector/dest  = new (m.x   * world.icon_size + world.icon_size / 2, m.y   * world.icon_size + world.icon_size / 2)

			var/list/bolts = list()
			for(var/i = 1 to 4)

				var/bolt/force/b = new(start, dest, 50)
				b.Draw(usr.z, color = c)

				bolts += b.lastCreatedBolt

			if(!attached) attached = list()
			attached[m] = bolts

		detach(mob/m)
			for(var/obj/o in attached[m])
				o.loc = null
			attached[m] = null

			attached -= m

			if(!usr.attached.len) usr.attached = null

	Click()
		if(src == usr) return

		if(usr.attached && (src in usr.attached))
			usr.detach(src)
			return

		usr.attach(src)

	Move()
		..()

		if(attached)
			refresh()