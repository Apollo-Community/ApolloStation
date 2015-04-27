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

				res.Blend(img, blendMode2iconMode(A.blend_mode), A.pixel_x, A.pixel_y)

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
		fullmapgen_DumpTile(text2num(input(usr,"Enter the Z level to generate")))

/client/proc/fullmapgen_DumpTile( var/currentZ = 1)

	// Checks if currentZ is outside of the bounds
	if (currentZ < 0 || currentZ > world.maxz)
		usr << "NanoMapGen: <B>ERROR: currentZ ([currentZ]) must be between 1 and [world.maxz]</B>"
		return FULLMAP_TERMINALERR

	world.log << "FullMapGen: <B>GENERATE FULL MAP</B>"
	usr << "FullMapGen: <B>GENERATE FULL MAP</B>"

	var/list/icon/Sectors = list()

	// Where the magic happens
	var/abort = 0
	var/OverMaxX = round((world.maxx+1)/FULLMAP_TILES_PER_IMAGE)
	var/OverMaxY = round((world.maxy+1)/FULLMAP_TILES_PER_IMAGE)
	for( var/OverX = 0, OverX <= OverMaxX, OverX++ )
		for( var/OverY = 0, OverY <= OverMaxY, OverY++ )
			// Loads the base image
			var/icon/Sector = icon(file("nano/mapbase1024.png"))

			// Checks if the image is 1024x1024
			if (Sector.Width() != FULLMAP_MAX_ICON_DIMENSION || Sector.Height() != FULLMAP_MAX_ICON_DIMENSION)
				world.log << "FullMapGen: <B>ERROR: BASE IMAGE DIMENSIONS ARE NOT [FULLMAP_MAX_ICON_DIMENSION]x[FULLMAP_MAX_ICON_DIMENSION]</B>"
				return FULLMAP_TERMINALERR

			// Rendering the individual section
			for(var/LocalX = 1, LocalX <= FULLMAP_TILES_PER_IMAGE, LocalX++)
				for(var/LocalY = 1, LocalY <= FULLMAP_TILES_PER_IMAGE, LocalY++)
					var/atom/Turf = locate(LocalX+( OverX*FULLMAP_TILES_PER_IMAGE ), LocalY+(OverY*FULLMAP_TILES_PER_IMAGE ), currentZ)
					var/icon/TurfIcon = get_turf_icon(Turf)

					if( !TurfIcon )
						continue
					//TurfIcon.Scale(FULLMAP_ICON_SIZE, FULLMAP_ICON_SIZE)

					Sector.Blend(TurfIcon, ICON_OVERLAY, (( LocalX-1 ) * FULLMAP_ICON_SIZE)+1, (( LocalY-1 ) * FULLMAP_ICON_SIZE)+1 )
					del(TurfIcon)

			var/mapFilename = "fullmap_[OverX]_[OverY]_[currentZ].png"

			if (Sector.Width() != FULLMAP_MAX_ICON_DIMENSION || Sector.Height() != FULLMAP_MAX_ICON_DIMENSION)
				usr << "FullMapGen: ERROR <B>File [mapFilename] had a bad output</B>"

				sleep(3)
				return FULLMAP_BADOUTPUT

			world.log << "FullMapGen: <B>[mapFilename] rendered</B>"
			Sectors[mapFilename] = Sector
			if( mapFilename == "fullmap_2_1_1.png" )
				abort = 1
				break

			sleep(10)

		if( abort )
			break

	// Exporting the final product
	world.log << "FullMapGen: <B>Number of sectors: [Sectors.len]</B>"
	var/icon/Sector
	for( Sector in Sectors )
		world.log << "FullMapGen: <B>Exporting [Sector]...</B>"
		/*
		spawn(0)
			world.log << "FullMapGen: <B>Sending [Sector] to client</B>"
			usr << browse_rsc(Sectors[Sector], "[Sector]")
			world.log << "FullMapGen: <B>Done.</B>"
			usr << "FullMapGen: <B>Done. File [Sector] uploaded to your cache.</B>"
		*/

	usr << "FullMapGen: <B>Full map complete.</B>"
	return FULLMAP_SUCCESS