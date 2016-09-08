var/datum/template_controller/template_controller

/datum/template_controller
	var/list/placed_templates = list()
	var/datum/dmm_parser/parser

	New()
		..()
		world << "<span class='alert'><b>Placing random structures...</b></span>"

		parser = new()

	proc/PlaceTemplateAt(var/turf/location, var/path, var/name, var/return_list = 0, var/ignore_space = 0)
		set background = 1
		var/datum/dmm_object_collection/collection = parser.GetCollection(file2list(path))
		var/list/turfs = new /list()

		if(ignore_space)	collection.RemoveSpaceTurfs()
		
		turfs = collection.Place(location, name)
		log_game("TEMPL: Spawned template [name] at ([location.x], [location.y], [location.z]).")

		if(return_list)
			return turfs
		else
			return collection

	proc/PlaceTemplates()
		set background = 1

		var/list/picked = PickTemplates()
		var/started = world.timeofday

		for(var/template in picked)
			var/list/size = GetTemplateSize(template)

			var/x = size[1]
			var/y = size[2]

			var/tries = template_config.tries
			var/turf/origin
			do
				var/list/zs = (overmap.can_random_teleport_levels - overmap.station_levels - overmap.local_levels)
				var/turf/pick = locate(rand(1, world.maxx), rand(1, world.maxy), text2num(pick(zs)))

				// Keep a buffer of TRANSITIONEDGE+10 between the edges of the map
				if(((pick.x + x) >= (world.maxx - TRANSITIONEDGE - 10)) || (pick.x < (TRANSITIONEDGE + 10)))
					continue

				if(((pick.y + y) >= (world.maxy - TRANSITIONEDGE - 10)) || (pick.y < (TRANSITIONEDGE + 10)))
					continue

				var/list/turfs = block(pick, locate(pick.x + x, pick.y + y, pick.z))

				var/breakout = 0
				for(var/turf/T in turfs)
					if(!(istype(T, /turf/space)))
						breakout = 1
						break

				tries--

				if(breakout)
					continue

				origin = pick
			while(!origin && tries > 0)

			var/reversed = reverse_text(template)
			var/name = reverse_text(copytext(reversed, 1, findtext(reversed, "/")))

			var/datum/dmm_object_collection/collection = PlaceTemplateAt(origin, template, name)
			placed_templates += collection

			// Wait for templates to spawn before continuing so they don't spawn into each other.
			sleep(15)

		log_game("Finished placing templates after [time2text((world.timeofday - started), "mm:ss")]")
		world << "<span class='alert'><b>Finished placing random structures...</b></span>"

	proc/PickTemplates()
		set background = 1

		var/list/picked = list()

		template_config.place_amount_min = min(template_config.place_amount_min, GetTemplateCount())
		template_config.place_amount_max = min(template_config.place_amount_max, GetTemplateCount())

		var/pick_num = rand(template_config.place_amount_min, template_config.place_amount_max)

		log_game("TEMPL: Picking [pick_num] template(s).")

		// remove chances configured to be 0% because of that scary while loop down there
		for(var/c in template_config.chances)
			if(text2num(template_config.chances[c]) == 0)
				template_config.chances -= c

		if(!length(template_config.chances))
			log_game("TEMPL: Aborting PickTemplates: no chances configured.")
			return 0

		while(pick_num > length(picked))
			// Pick a category
			var/max_tries = template_config.tries
			var/picked_category
			do
				for(var/c in shuffle(template_config.chances))
					if(!(c in GetCategories(1)))
						log_game("TEMPL: Configured folder '[c]' not found.")
						return list()
					if(prob(text2num(template_config.chances[c])))
						picked_category = c
				max_tries--
			while(!picked_category && max_tries > 0)

			var/list/category_templates = GetTemplatesFromCategory(picked_category)

			if(length(category_templates) <= 0)
				continue

			// Pick a template from that category
			var/picked_template = category_templates[rand(1, length(category_templates))]

			if(!picked_template)
				continue

			var/formatted = "[template_config.directory]/[picked_category]/[picked_template]"
			if(formatted in picked)
				continue

			log_game("TEMPL: Picked template: [picked_template]")

			picked += formatted

		return picked
