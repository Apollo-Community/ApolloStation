/**
 * a line made of line segments, used to create a growing animated line (useful for beams, bars etc)
 */

beam
	var
		list/segments
		fade

	/**
	 * Constructs the beam, from vector source to vector dest
	 *
	 * @param source    source vector, where the bolt starts
	 * @param dest      destination vector, where the beam ends
	 * @param placement distance between every segment, lower means more segments, default of 32
	 * @param fade      assigns fade out rate, default of 25
	 */
	New(vector/source, vector/dest, placement = 32, fade = 25)
		..()

		segments      = createBeam(source, dest, placement)
		src.fade      = 25

	proc
		/**
		 * Draws a beam of type with a color between two assigned vectors on z or client screen
		 *
		 * @param z         the map z level to draw on, if z is client it will draw on client screen
		 * @param type      basic segment to use when drawing
		 * @param color     color of the beam
		 * @param thickness thickness of the beam
		 */
		Draw(z, type = /obj/segment, color = "#fff", thickness = 1)
			set waitfor = 0
			var/pos = 1
			for(var/line/segment in segments)
				var/obj/o = segment.Draw(z, type, color, thickness)
				Effect(o, pos++)
				sleep(world.tick_lag)

		/**
		 * Applys animation to beam segment
		 * this could be overriden by child types to allow different animations to beam
		 * by default, a beam will fully grow then begin to fade out
		 *
		 * @param o   the object segment, each beam is made of several segments
		 * @param pos the position of the segment, this could be used to calculate the delay at which it is displayed to provide more control over animations
		 */
		Effect(obj/o, pos)
			set waitfor = 0
			sleep(world.tick_lag * (segments.len - pos))

			animate(o, alpha = 0, time = 255 / fade, loop = 1)

			sleep(255 / fade)
			Dispose(o, pos)

		/**
		 * Handles soft deletion of beam segments
		 * by default after a beam faded it will be disposed
		 *
		 * @param o the object segment to dispose
		 */
		Dispose(obj/o)
			o.loc = null

		/**
		 * Returns a list of segments from vector source to vector dest
		 *
		 * @param  source source vector, where the beam starts
		 * @param  dest   destination vector, where the beam ends
		 * @return dest   a list of line segments forming a beam
		 */
		createBeam(vector/source, vector/dest, placement = 32)
			var/list/results = list()

			var/vector/tangent = vectorSubtract(dest, source)
			var/length = tangent.Length()

			var/vector/prevPoint = source
			for(var/i = 1 to length / placement)

				var/pos = i / (length / placement)
				var/vector/endPoint = new (source.X + (tangent.X * pos), source.Y + (tangent.Y * pos))

				endPoint.Round()
				var/line/l = new(prevPoint, endPoint)
				results   += l

				prevPoint        = endPoint

			var/line/l = new(prevPoint, dest)
			results += l

			return results

		/**
		 * Returns a list of turfs between the beam's starting vector to the beam's end vector
		 * It can return null if no turfs are found.
		 *
		 * @param  z         the map z level to search
		 * @param  accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
		 *                   1 being the minimum
		 * @return a list of turfs the beam passes on
		 */
		GetTurfs(z, accurate = 16)
			var/line/start = segments[1]
			var/line/end = segments[segments.len]

			return vectorGetTurfs(start.A, end.B, z, accurate)