/proc/get_turf_icon(turf/T)

	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	if( !T ) return
	if( !T.icon ) return
	if( !T.icon_state ) return

	var/icon/res = new(T.icon, T.icon_state)

	var/atoms[] = list()

	// Add outselves to the list of stuff to draw
	atoms.Add(T);
	// As well as anything that isn't invisible.
	for(var/atom/A in T)
		if(A.invisibility) continue
		atoms.Add(A)

	// Sort the atoms into their layers
	var/list/sorted = sort_atoms_by_layer(atoms)
	for(var/i; i <= sorted.len; i++)
		var/atom/A = sorted[i]
		if(A)
			var/icon/img = getFlatIcon(A)//build_composite_icon(A)

			// If what we got back is actually a picture, draw it.
			if(istype(img, /icon))
				// Check if we're looking at a mob
				if(istype(A, /mob/living) )
					// If they are, don't draw them
					continue

				res.Blend(img, blendMode2iconMode(A.blend_mode),  A.pixel_x, A.pixel_y)

	return res


// This file is a modified version of https://raw2.github.com/Baystation12/OldCode-BS12/master/code/TakePicture.dm

#define FULLMAP_ICON_SIZE 32
#define FULLMAP_MAX_ICON_DIMENSION 1024

#define FULLMAP_TILES_PER_IMAGE (FULLMAP_MAX_ICON_DIMENSION / FULLMAP_ICON_SIZE)

#define FULLMAP_TERMINALERR 5
#define FULLMAP_INPROGRESS 2
#define FULLMAP_BADOUTPUT 2
#define FULLMAP_SUCCESS 1
#define FULLMAP_WATCHDOGSUCCESS 4
#define FULLMAP_WATCHDOGTERMINATE 3


//Call these procs to dump your world to a series of image files (!!)
//NOTE: Does not explicitly support non 32x32 icons or stuff with large pixel_* values, so don't blame me if it doesn't work perfectly

/client/proc/fullmapgen_DumpImage()
	set name = "Generate Full Map"
	set category = "Server"

	if(holder)
		fullmapgen_DumpTile(1, 1, text2num(input(usr,"Enter the Z level to generate")))

/client/proc/fullmapgen_DumpTile(var/startX = 1, var/startY = 1, var/currentZ = 1, var/endX = -1, var/endY = -1)
	// Checks if endX is outside of the bounds
	if (endX < 0 || endX > world.maxx)
		endX = world.maxx

	// Checks if endY is outside of the bounds
	if (endY < 0 || endY > world.maxy)
		endY = world.maxy

	// Checks if currentZ is outside of the bounds
	if (currentZ < 0 || currentZ > world.maxz)
		usr << "NanoMapGen: <B>ERROR: currentZ ([currentZ]) must be between 1 and [world.maxz]</B>"
		return FULLMAP_TERMINALERR

	// Checks if startX is larger than endX
	if (startX > endX)
		usr << "NanoMapGen: <B>ERROR: startX ([startX]) cannot be greater than endX ([endX])</B>"
		return FULLMAP_TERMINALERR

	// Checks if startY is larger than endY
	if (startY > endX)
		usr << "NanoMapGen: <B>ERROR: startY ([startY]) cannot be greater than endY ([endY])</B>"
		return FULLMAP_TERMINALERR

	// Loads the base image
	var/icon/Tile = icon(file("nano/mapbase1024.png"))
	// Checks if the image is 1024x1024
	if (Tile.Width() != FULLMAP_MAX_ICON_DIMENSION || Tile.Height() != FULLMAP_MAX_ICON_DIMENSION)
		world.log << "NanoMapGen: <B>ERROR: BASE IMAGE DIMENSIONS ARE NOT [FULLMAP_MAX_ICON_DIMENSION]x[FULLMAP_MAX_ICON_DIMENSION]</B>"
		return FULLMAP_TERMINALERR

	world.log << "NanoMapGen: <B>GENERATE MAP ([startX],[startY],[currentZ]) to ([endX],[endY],[currentZ])</B>"
	usr << "NanoMapGen: <B>GENERATE MAP ([startX],[startY],[currentZ]) to ([endX],[endY],[currentZ])</B>"

	// Where the magic happens
	var/OverMaxX = world.maxx/FULLMAP_TILES_PER_IMAGE
	var/OverMaxY = world.maxy/FULLMAP_TILES_PER_IMAGE
	for( var/OverX = 0, OverX <= OverMaxX, OverX++ )
		for( var/OverY = 0, OverY <= OverMaxY, OverY++ )
			for(var/WorldX = startX, WorldX <= FULLMAP_TILES_PER_IMAGE, WorldX++)
				for(var/WorldY = startY, WorldY <= FULLMAP_TILES_PER_IMAGE, WorldY++)
					var/atom/Turf = locate(WorldX+( OverX*FULLMAP_TILES_PER_IMAGE ), WorldY+(OverY*FULLMAP_TILES_PER_IMAGE ), currentZ)
					var/icon/TurfIcon = get_turf_icon(Turf)

					if( !TurfIcon )
						continue
					//TurfIcon.Scale(FULLMAP_ICON_SIZE, FULLMAP_ICON_SIZE)

					Tile.Blend(TurfIcon, ICON_OVERLAY, ( WorldX-1 ) * FULLMAP_ICON_SIZE, ( WorldY-1 ) * FULLMAP_ICON_SIZE )

			var/mapFilename = "fullmap_[OverX]_[OverY]_[currentZ].png"

			if (Tile.Width() != FULLMAP_MAX_ICON_DIMENSION || Tile.Height() != FULLMAP_MAX_ICON_DIMENSION)
				usr << "NanoMapGen: ERROR <B>File [mapFilename] had a bad output</B>"

				sleep(3)
				return FULLMAP_BADOUTPUT

			world.log << "NanoMapGen: <B>sending [mapFilename] to client</B>"
			usr << browse(Tile, "window=picture;file=[mapFilename];display=0")
			world.log << "NanoMapGen: <B>Done.</B>"
			usr << "NanoMapGen: <B>Done. File [mapFilename] uploaded to your cache.</B>"

			sleep(3)

	usr << "NanoMapGen: <B>Full map complete.</B>"
	return FULLMAP_SUCCESS