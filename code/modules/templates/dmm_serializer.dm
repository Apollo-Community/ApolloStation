/datum/dmm_serializer

	var/id_character_set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

	// these are vars that are usually set by the game when the objects are loaded
	// therefore, saving them is mostly redundant
	var/list/ignore_vars = list(
		"animate_movement",
		"visibility",
		"invisibility",
		"override",
		"health",
		"ini_dir",
		"explosion_resistance",
		"dat",
		"on",
		"on_gs",
		"switchcount",
		"light_color"
	)

	// finds the variable list for an atom (that {} part)

	proc/get_variable_list(var/atom/A)
		// don't muck with space
		if(istype(A, /turf/space))
			return ""

		var/definition = ""

		var/modified_vars = 0
		var/first_written_var = 1

		for(var/V in A.vars)
			if(V in ignore_vars)
				continue

			var/var_modified = (A.vars[V] != initial(A.vars[V]))

			if(!var_modified)
				continue

			var/class = null

			if(isnum(A.vars[V]))
				class = "num"
			else if(istext(A.vars[V]))
				class = "text"
			else
				// don't save anything more complex than numbers and text
				continue

			if(!modified_vars)
				modified_vars = 1
				definition += "{"

			if(!first_written_var)
				definition += "; "
			else
				first_written_var = 0

			definition += "[V] = "
			switch(class)
				if("num")
					definition += "[A.vars[V]]"
				if("text")
					definition += "\"[A.vars[V]]\""

		if(modified_vars)
			definition += "}"

		return definition

	// Finds the DMM collection "signature" (definition) for a turf

	proc/find_signature(var/turf/T)
		var/signature = "("

		var/first_type = 1

		for(var/atom/A in T)
			// lighting overlays are generated at runtime and should not be saved
			if(istype(A, /atom/movable/lighting_overlay))
				continue

			// goood no don't save mobs
			if(istype(A, /mob))
				continue

			if(!first_type)
				signature += ","
			else
				first_type = 0

			signature += "[A.type][get_variable_list(A)]"

		// at this point it won't matter much whether or not we set first_type = 0
		if(!first_type)
			signature += ","

		signature += "[T.type][get_variable_list(T)],[T.loc.type]"

		signature += ")"

		return signature


	/*
		Serialize a portion of a z-level to a DMM file

		Starts out by creating object collections, and then serializes via those collections from
		the bottom left of the block, working towards the right for each row and then upwards
	*/

	//for debug: x82 y37 z4 w98 h164
	proc/serialize_block(var/x, var/y, var/z, var/w, var/h, var/file_name, var/folder = "serialized")
		var/path = "maps/[folder]/[file_name].dmm"
		var/start = world.timeofday

		log_game("Saving [w * h] turfs on z-level [z] as a map. Brace for lag!")

		var/relative_w = x + w
		var/relative_h = y + h

		// find all the signatures that exist in the block
		var/list/signatures = list()

		var/list/block_turfs = get_turfs(x, relative_w, y, relative_h, 4)

		for(var/V in block_turfs)
			var/turf/T = V
			if(isnull(T))
				continue

			var/signature = find_signature(T)

			if(signature in signatures)
				continue

			signatures.Add(signature)


		fdel(path)
		var/map_file = file(path)


		// how many characters are used to represent one collection?
		// for each character, there are 52 possible letters (a-z A-Z)
		var/collection_size = 1
		while(length(signatures) > 52**collection_size)
			collection_size++

		var/list/collections = list()

		var/progresses[collection_size]
		for(var/i = 1; i <= collection_size; i++)
			progresses[i] = 1

		// figuring out how to make this ID generation was fucking hell
		for(var/S in signatures)
			var/id = ""
			// grab each "progress" along the character set and append it to the id
			for(var/i = 1; i <= collection_size; i++)
				id += copytext(id_character_set, progresses[i], progresses[i] + 1)

			// by making the signature the index, we can just grab turfs' signatures and find which id to put in
			collections[S] = id

			map_file << "\"[id]\" = [S]"

			// start at the back of the ID progress list
			var/pos = collection_size

			// if we've come to the end of the character set (52), start cascading down the progress list
			// for every position in the ID that has come to the end of the character set, reset it to 1
			// this goes on until we've found a position in the ID that has NOT come to the end of the character set
			// that position's "progress" is then incremented. after this it goes back to incrementing the last position's "progress" until it hits the end again

			if(progresses[pos] == 52)
				while(progresses[pos] == 52)
					progresses[pos] = 1
					pos--

				progresses[pos]++
			else
				progresses[pos]++


		map_file << "\n(1, 1, 1) = {\""

		// loops through each column in every row
		// goes left-right, top-bottom, as map files do
		for(var/r = relative_h; r > y; r--)

			var/row_collection_string = ""
			for(var/c = x; c < relative_w; c++)
				var/turf/T = locate(c, r, z)
				if(isnull(T))
					continue

				var/signature = find_signature(T)

				row_collection_string += collections[signature]

			map_file << row_collection_string

		map_file << "\"}"

		log_game("DMM serialization finished! Map placed in [path]")
		log_debug("DMM serialization took [(world.timeofday - start) / 10] seconds")
