/**
 * adjustable bar
 */

beam/bar

	var/list/objects
	var/index


	/**
	 * Draws a adjustable bar of type with a color between two assigned vectors on z or client screen
	 *
	 * @param z          the map z level to draw on, if z is client it will draw on client screen
	 * @param type       basic segment to use when drawing
	 * @param color      color of the segment
	 * @param thickness  thickness of the segment
	 */
	Draw(z, type = /obj/segment, color = "#fff", thickness = 1)

		objects = list()
		for(var/line/segment in segments)
			var/obj/o = segment.Draw(z, type, color, thickness)
			objects += o

		index = objects.len

	proc
		/**
		 * Adjusts the bar to a percent
		 *
		 * @param percent percent of bar filled
		 */
		Adjust(percent)
			set waitfor = 0

			var/newIndex = round((percent * objects.len) / 100)
			var/s        = newIndex > index ? 1 : -1

			for(var/i = index to newIndex step s)
				var/obj/o = objects[i]

				o.invisibility = !o.invisibility

				sleep(world.tick_lag)

			index = newIndex

