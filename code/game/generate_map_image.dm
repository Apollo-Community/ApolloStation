/proc/get_turf_icon(turf/T)

	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
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
#define FULLMAP_MAX_ICON_DIMENSION 8192

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

	if (endX < 0 || endX > world.maxx)
		endX = world.maxx

	if (endY < 0 || endY > world.maxy)
		endY = world.maxy

	if (currentZ < 0 || currentZ > world.maxz)
		usr << "NanoMapGen: <B>ERROR: currentZ ([currentZ]) must be between 1 and [world.maxz]</B>"

		sleep(3)
		return FULLMAP_TERMINALERR

	if (startX > endX)
		usr << "NanoMapGen: <B>ERROR: startX ([startX]) cannot be greater than endX ([endX])</B>"

		sleep(3)
		return FULLMAP_TERMINALERR

	if (startY > endX)
		usr << "NanoMapGen: <B>ERROR: startY ([startY]) cannot be greater than endY ([endY])</B>"
		sleep(3)
		return FULLMAP_TERMINALERR

	var/icon/Tile = icon(file("nano/mapbase8192.png"))
	if (Tile.Width() != FULLMAP_MAX_ICON_DIMENSION || Tile.Height() != FULLMAP_MAX_ICON_DIMENSION)
		world.log << "NanoMapGen: <B>ERROR: BASE IMAGE DIMENSIONS ARE NOT [FULLMAP_MAX_ICON_DIMENSION]x[FULLMAP_MAX_ICON_DIMENSION]</B>"
		sleep(3)
		return FULLMAP_TERMINALERR

	world.log << "NanoMapGen: <B>GENERATE MAP ([startX],[startY],[currentZ]) to ([endX],[endY],[currentZ])</B>"
	usr << "NanoMapGen: <B>GENERATE MAP ([startX],[startY],[currentZ]) to ([endX],[endY],[currentZ])</B>"

	var/count = 0;
	for(var/WorldX = startX, WorldX <= endX, WorldX++)
		for(var/WorldY = startY, WorldY <= endY, WorldY++)

			var/atom/Turf = locate(WorldX, WorldY, currentZ)

			var/icon/TurfIcon = get_turf_icon(Turf)
			//TurfIcon.Scale(FULLMAP_ICON_SIZE, FULLMAP_ICON_SIZE)

			Tile.Blend(TurfIcon, ICON_OVERLAY, ((WorldX - 1) * FULLMAP_ICON_SIZE), ((WorldY - 1) * FULLMAP_ICON_SIZE))
			del(TurfIcon)

			count++
			world.log << "NanoMapGen: <B>[count] tiles done</B>"


	var/mapFilename = "fullmap_z[currentZ]-new.png"

	world.log << "NanoMapGen: <B>sending [mapFilename] to client</B>"

	usr << browse(Tile, "window=picture;file=[mapFilename];display=0")

	world.log << "NanoMapGen: <B>Done.</B>"

	usr << "NanoMapGen: <B>Done. File [mapFilename] uploaded to your cache.</B>"

	if (Tile.Width() != FULLMAP_MAX_ICON_DIMENSION || Tile.Height() != FULLMAP_MAX_ICON_DIMENSION)
		return FULLMAP_BADOUTPUT

	return FULLMAP_SUCCESS