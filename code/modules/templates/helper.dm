var/list/_TempTemplateTurfs = list()

/datum/template_controller

	proc/GetCategories(var/names_only = 0)
		if(!names_only)
			return flist("[template_config.directory]/")
		else
			var/list/categories = flist("[template_config.directory]/")
			for(var/c in categories)
				categories[categories.Find(c)] = replacetext(c, "/", "")
			return categories

	proc/GetAllTemplates()
		var/list/templates
		for(var/c in GetCategories())
			for(var/template in flist("[template_config.directory]/[c]/"))
				templates[template] = c

		return templates

	proc/GetCategoryFromTemplate(var/name)
		for(var/category in GetCategories(1))
			if(name in flist("[template_config.directory]/[category]/"))
				return category

		return 0

	proc/FlattenArea(var/turf/point1, var/turf/point2, var/replace_with = /turf/space)
		for(var/turf/T in block(point1, point2))
			for(var/atom/movable/M in T)
				if(istype(M, /mob))
					var/mob/mob = M
					if(mob.client || mob.key)
						continue
				qdel(M)
			T.ChangeTurf(replace_with)

	proc/GetTemplateCount(var/category = 0)
		var/count = 0
		if(!category)
			for(var/c in GetCategories())
				count += length(flist("[template_config.directory]/[c]/"))
		else
			count = length(flist("[template_config.directory]/[category]/"))
		return count

	proc/GetTemplatesFromCategory(var/category)
		if(!category)	return 0
		return flist("[template_config.directory]/[category]/")

	proc/GetTemplateSize(var/path)
		var/datum/dmm_object_collection/collection = parser.GetCollection(file2list(path))
		return list(collection.x_size, collection.y_size)
