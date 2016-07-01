// Credit to @Tastyfish

/proc/generate_every_map()
	//generate apollo map first
	genmapall(3, "/apollo")
	gen_special_all(3, "apollo/")

	//generate slater map
	genmapall(5, {"/slater"})
	gen_special_all(5, "slater/")

	shell("sh scripts/move_map.sh")

	shutdown()

// generate ALL MAP TILES
/proc/genmapall(var/z_level = null, var/prefix = null)
	genmap(z_level, prefix)
	for(var/i = 4; i >= 2; i--)
		genmapzooms(i, prefix )

// generate the zoomed out tiles
/proc/genmapzooms(z as num, prefix = "")
	var/path = ".[prefix]/tiles"
	// figure out output grid size
	var/size = 32 / 2 ** (5 - z)

	for(var/x = 0; x < size; x++)
		for(var/y = 0; y < size; y++)
			var/icon/res = icon('icons/effects/96x96.dmi', "")
			res.Scale(256, 256)
			var/icon/i = icon("[path]/[z+1]/[round(x*2)]/[round(y*2)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=1,y=1)
			i = icon("[path]/[z+1]/[round(x*2+1)]/[round(y*2)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=129,y=1)
			i = icon("[path]/[z+1]/[round(x*2)]/[round(y*2+1)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=1,y=129)
			i = icon("[path]/[z+1]/[round(x*2+1)]/[round(y*2+1)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=129,y=129)
			fcopy(res, "[path]/[z]/[round(x)]/[round(y)].png")

// generate the 1:1 zoom tiles
/proc/genmap(z_level = null, var/prefix = null)
	if(!z_level)	z_level = input("which z-level?") as num|null

	for(var/x = 1; x <= world.maxx; x += 8)
		for(var/y = 1; y <= world.maxy; y += 8)
			var/icon/I = map_get_icon(	block(locate(max(1,x - 1), max(1,y - 1), z_level),
										locate(min(world.maxx,x + 8), min(world.maxy,y + 8), z_level)),
										locate(x + 3.5, y + 3.5, 1))
			fcopy(new/icon(I, "", SOUTH, 1, 0),	".[prefix]/tiles/5/[round(x/8)]/[round(y/8)].png")

/proc/map_get_icon(list/turfs, turf/center)
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(8*32, 8*32)

	var/atoms[] = list()
	for(var/turf/the_turf in turfs)
		// Add outselves to the list of stuff to draw
		if(!istype(the_turf, /turf/space) && !istype(the_turf, /turf/simulated/floor/plating/airless/fakespace))	atoms.Add(the_turf)
		// As well as anything that isn't invisible.
		for(var/atom/A in the_turf)
			if(!A.invisibility)
				atoms.Add(A)

	// Sort the atoms into their layers
	var/list/sorted = sort_atoms_by_layer(atoms)
	var/center_offset = 3 * 32
	for(var/i; i <= sorted.len; i++)
		var/atom/A = sorted[i]
		if(A)
			var/icon/img = getFlatIcon(A)//build_composite_icon(A)

			// If what we got back is actually a picture, draw it.
			if(istype(img, /icon))
				// Calculate where we are relative to the center of the photo
				var/xoff = (A.x - center.x) * 32 + center_offset
				var/yoff = (A.y - center.y) * 32 + center_offset
				if (istype(A,/atom/movable))
					xoff+=A:step_x
					yoff+=A:step_y
				res.Blend(img, blendMode2iconMode(A.blend_mode),  A.pixel_x + xoff, A.pixel_y + yoff)

	// Lastly, render any contained effects on top.
	for(var/turf/the_turf in turfs)
		// Calculate where we are relative to the center of the photo
		var/xoff = (the_turf.x - center.x) * 32 + center_offset
		var/yoff = (the_turf.y - center.y) * 32 + center_offset
		res.Blend(getFlatIcon(the_turf.loc), blendMode2iconMode(the_turf.blend_mode),xoff,yoff)

	return res

/proc/gen_special_all(var/z_level = null, var/prefix = null)
	if(!z_level)	z_level = input("which z-level?") as num|null

	gen_special_mapall("[prefix]wires", list(/obj/structure/cable, /obj/machinery/power), z_level)
	gen_special_mapall("[prefix]disposals", list(/obj/structure/disposalpipe, /obj/structure/disposaloutlet, /obj/machinery/disposal), z_level)
	gen_special_mapall("[prefix]atmos", list(/obj/machinery/atmospherics, /obj/machinery/portable_atmospherics), z_level)

// generate ALL MAP TILES
/proc/gen_special_mapall(path, list/types, z_level)
	gen_special_map(path, types, z_level)
	for(var/i = 4; i >= 2; i--)
		gen_special_mapzooms(path, i)

// generate the zoomed out tiles
/proc/gen_special_mapzooms(path, z)
	// figure out output grid size
	var/size = 32 / 2 ** (5 - z)

	for(var/x = 0; x < size; x++)
		for(var/y = 0; y < size; y++)
			var/icon/res = icon('icons/effects/96x96.dmi', "")
			res.Scale(256, 256)
			var/icon/i = icon("./[path]/[z+1]/[round(x*2)]/[round(y*2)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=1,y=1)
			i = icon("./[path]/[z+1]/[round(x*2+1)]/[round(y*2)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=129,y=1)
			i = icon("./[path]/[z+1]/[round(x*2)]/[round(y*2+1)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=1,y=129)
			i = icon("./[path]/[z+1]/[round(x*2+1)]/[round(y*2+1)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=129,y=129)
			fcopy(res, "./[path]/[z]/[round(x)]/[round(y)].png")

// generate the 1:1 zoom tiles
/proc/gen_special_map(path, list/types, z_level = 3)
	for(var/x = 1; x <= world.maxx; x += 8)
		for(var/y = 1; y <= world.maxy; y += 8)
			var/icon/I = map_get_special_icon(	block(locate(max(1,x - 1), max(1,y - 1), z_level),
												locate(min(world.maxx,x + 8), min(world.maxy,y + 8), z_level)),
												locate(x + 3.5, y + 3.5, 1),
												types)
			fcopy(new/icon(I, "", SOUTH, 1, 0),	"./[path]/5/[round(x/8)]/[round(y/8)].png")

/proc/map_get_special_icon(list/turfs, turf/center, list/types)
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(8*32, 8*32)

	var/atoms[] = list()
	for(var/turf/the_turf in turfs)
		// Add anything of the valid types
		for(var/atom/A in the_turf)
			for(var/T in types)
				if(istype(A, T))
					atoms.Add(A)
					break

	// Sort the atoms into their layers
	var/list/sorted = sort_atoms_by_layer(atoms)
	var/center_offset = 3 * 32
	for(var/i; i <= sorted.len; i++)
		var/atom/A = sorted[i]
		if(A)
			var/icon/img = getFlatIcon(A)//build_composite_icon(A)

			// If what we got back is actually a picture, draw it.
			if(istype(img, /icon))
				// Calculate where we are relative to the center of the photo
				var/xoff = (A.x - center.x) * 32 + center_offset
				var/yoff = (A.y - center.y) * 32 + center_offset
				if (istype(A,/atom/movable))
					xoff+=A:step_x
					yoff+=A:step_y
				res.Blend(img, blendMode2iconMode(A.blend_mode),  A.pixel_x + xoff, A.pixel_y + yoff)

	// Lastly, render any contained effects on top.
	for(var/turf/the_turf in turfs)
		// Calculate where we are relative to the center of the photo
		var/xoff = (the_turf.x - center.x) * 32 + center_offset
		var/yoff = (the_turf.y - center.y) * 32 + center_offset
		res.Blend(getFlatIcon(the_turf.loc), blendMode2iconMode(the_turf.blend_mode),xoff,yoff)
	return res
