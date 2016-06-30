// Credit to @Tastyfish

client/verb/vendgen()
	set category = "Debug"
	set name = "Vender JSON"

	// generate names file
	fdel("vtypes.json")
	var/txt = "{"
	for(var/type in typesof(/obj/machinery/vending))
		var/obj/inst = new type()
		txt += {""[type]":"[inst.name]","}
		qdel(inst)
	txt = copytext(txt, 1, length(txt))
	txt += "}"
	file("vtypes.json") << txt

	// generate full listing
	fdel("vinsts.json")
	txt = "\["
	for(var/obj/machinery/vending/O)
		if(O.z == 1)
			txt += {"{"type":"[O.type]","loc":\[[O.x],[O.y]\]},"}
	txt = copytext(txt, 1, length(txt))
	txt += "\]"
	file("vinsts.json") << txt

client/verb/areagen()
	set category = "Debug"
	set name = "Area JSON"

	// generate areas file
	fdel("areas.json")
	var/txt = "\["
	for(var/type in typesof(/area))
		var/area/inst = new type()
		txt += {""[inst.name]","}
		qdel(inst)
	txt = copytext(txt, 1, length(txt))
	txt += "\]"
	file("areas.json") << txt

// generate ALL MAP TILES
client/verb/genmapall()
	set category = "Debug"
	set name = "Generate Map All Zooms"

	genmap()
	for(var/i = 4; i >= 2; i--)
		genmapzooms(i)

// generate the zoomed out tiles
client/verb/genmapzooms(z as num)
	set category = "Debug"
	set name = "Generate Map Zoom"

	// figure out output grid size
	var/size = 32 / 2 ** (5 - z)

	for(var/x = 0; x < size; x++)
		for(var/y = 0; y < size; y++)
			var/icon/res = icon('icons/effects/96x96.dmi', "")
			res.Scale(256, 256)
			// Initialize to black.
			var/icon/i = icon("./tiles/[z+1]/[round(x*2)]/[round(y*2)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=1,y=1)
			i = icon("./tiles/[z+1]/[round(x*2+1)]/[round(y*2)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=129,y=1)
			i = icon("./tiles/[z+1]/[round(x*2)]/[round(y*2+1)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=1,y=129)
			i = icon("./tiles/[z+1]/[round(x*2+1)]/[round(y*2+1)].png")
			i.Scale(128,128)
			res.Blend(i,ICON_OVERLAY,x=129,y=129)
			fcopy(res, "./tiles/[z]/[round(x)]/[round(y)].png")

// generate the 1:1 zoom tiles
client/verb/genmap()
	set category = "Debug"
	set name = "Generate Web Map"

	var/z_level = input("which z-level?") as num|null
	for(var/x = 1; x <= world.maxx; x += 8)
		for(var/y = 1; y <= world.maxy; y += 8)
			var/icon/I = map_get_icon(
				block(locate(max(1,x - 1), max(1,y - 1), z_level),locate(min(world.maxx,x + 8), min(world.maxy,y + 8), z_level)),
				locate(x + 3.5, y + 3.5, 1))
			fcopy(new/icon(I, "", SOUTH, 1, 0),
				"./tiles/5/[round(x/8)]/[round(y/8)].png")

client/proc/map_get_icon(list/turfs, turf/center)
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(8*32, 8*32)
	// Initialize to black.
	//res.Blend("#ff1aff", ICON_OVERLAY)

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
				// Check if we're looking at a mob that's lying down
				if(istype(A, /mob/living) && A:lying)
					// If they are, apply that effect to their picture.
					img.BecomeLying()
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

client/verb/gen_special_all()
	set category = "Debug"
	set name = "Generate Special Maps All Zooms"

	var/z_level = input("which z-level?") as num|null

	gen_special_mapall("wires", list(/obj/structure/cable, /obj/machinery/power), z_level)
	gen_special_mapall("disposals", list(/obj/structure/disposalpipe, /obj/structure/disposaloutlet, /obj/machinery/disposal), z_level)
	gen_special_mapall("atmos", list(/obj/machinery/atmospherics, /obj/machinery/portable_atmospherics), z_level)

// generate ALL MAP TILES
client/proc/gen_special_mapall(path, list/types, z_level)
	gen_special_map(path, types, z_level)
	for(var/i = 4; i >= 2; i--)
		gen_special_mapzooms(path, i)

// generate the zoomed out tiles
client/proc/gen_special_mapzooms(path, z)
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
client/proc/gen_special_map(path, list/types, z_level = 3)
	for(var/x = 1; x <= world.maxx; x += 8)
		for(var/y = 1; y <= world.maxy; y += 8)
			var/icon/I = map_get_special_icon(
				block(locate(max(1,x - 1), max(1,y - 1), z_level),locate(min(world.maxx,x + 8), min(world.maxy,y + 8), z_level)),
				locate(x + 3.5, y + 3.5, 1),
				types)
			fcopy(new/icon(I, "", SOUTH, 1, 0),
				"./[path]/5/[round(x/8)]/[round(y/8)].png")

client/proc/map_get_special_icon(list/turfs, turf/center, list/types)
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
				// Check if we're looking at a mob that's lying down
				if(istype(A, /mob/living) && A:lying)
					// If they are, apply that effect to their picture.
					img.BecomeLying()
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
