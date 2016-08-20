/**
 * A lightning bolt drawn between two vectors with 3 to 6 branched lightning bolts
 */

BranchedBolt

	var
		list/bolts
		vector/end

		fade

	/**
	 * Constructs the branched bolt, from vector source to vector dest
	 *
	 * @param source source vector, where the bolt starts
	 * @param dest   destination vector, where the bold ends
	 * @param fade   assigns fade out rate, default of 50
	 */
	New(vector/start, vector/end, fade = 50, targets=null)
		..()

		src.end  = end
		src.fade = fade

		Create(start, end, targets)

	proc
		/**
		 * Draws a branched lightning bolt of type with a color between two assigned vectors on z or client screen
		 *
		 * @param z         the map z level to draw on, if z is client it will draw on client screen
		 * @param type      basic segment to use when drawing
		 * @param color     color of the branched bolt
		 * @param thickness thickness of the branched bolt
		 * @param split     if set to 1 will create an obj for each segment, if not it will only create one object with segments as overlays
		 */
		Draw(z, type = /obj/segment, color = "#fff", thickness = 1, split = 0)
			for(var/bolt/b in bolts)
				b.fade = fade
				b.Draw(z, type, color, thickness, split)

		/**
		 * Initializes the branched lightning bolts list
		 * the first bolt in the list will be the main bolt between the two given vectors with the addition of 3 to 6 branched bolts
		 *
		 * @param source source vector, where the bolt starts
		 * @param dest   destination vector, where the bolt ends
		 */
		Create(vector/start, vector/end, targets = null)
			var/bolt/mainbolt = new (start, end)

			bolts = list(mainbolt)

			var/branches
			var/boltTargets = FALSE

			if(!targets)
				branches = rand(3, 6)
			else if(isnum(targets))
				branches = targets
			else
				branches    = length(targets)
				boltTargets = TRUE

			var/list/positions = list()

			var/growth = 0.5 / branches
			var/p = 0
			for(var/i = 1 to branches)
				var/r = __rand(growth / 3, growth * 3)
				p += r
				positions += p

				if(p >= 0.50) break

			var/vector/diff = vectorSubtract(end, start)

			for(var/i = 1 to positions.len)
				// bolt.GetPoint() gets the position of the lightning bolt at specified fraction (0 = start of bolt, 1 = end)
				var/vector/boltStart = mainbolt.GetPoint(positions[i])

				var/vector/boltEnd
				if(boltTargets)
					var/atom/target = targets[i]
					boltEnd = new (target.x * world.icon_size, target.y * world.icon_size)
				else
					// rotate 30 degrees. Alternate between rotating left and right.
					var/vector/v = vectorRotate(vectorMultiply(diff, 1 - positions[i]), pick(30,-30))
					boltEnd = vectorAdd(boltStart, v)

				var/bolt/bolt = new (boltStart, boltEnd)
				bolt.fade     = fade
				bolts        += bolt

		/**
		 * Returns a list of turfs between the bolt's starting vector to the bolt's end vector without including branched bolts
		 * because this only checks first and last vectors it returns a form of line between both vectors and can be inaccurate if bolt segments stray too far
		 * It can return null if no turfs are found.
		 *
		 * @param z         the map z level to search
		 * @param accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
		 *                  1 being the minimum, it should be noted even at 1 this will not be too accurate, use GetAllTurfs() for a more accurate result
		 * @return a partial list of turfs the main bolt passes on
		 */
		GetTurfs(z, accurate = 16)
			var/bolt/b = bolts[1]
			var/line/l = b.segments[1]

			return vectorGetTurfs(l.A, end, z, accurate)

		/**
		 * Returns a list of turfs between the bolt's starting vector to the bolt's end vector checking all segments including all branched bolts
		 * It can return null if no turfs are found.
		 *
		 * @param z         the map z level to search
		 * @param accurate  controlls the accurecy of this function, lower number means more accurate results however it reduces performance
		 *                  1 being the minimum
		 * @return a list of turfs the bolts pass on
		 */
		GetAllTurfs(z, accurate = 16)
			var/list/locs = list()

			for(var/bolt/b in bolts)
				locs = locs|b.GetAllTurfs(z, accurate)

			return locs.len ? locs : null