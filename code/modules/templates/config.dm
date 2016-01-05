#define TEMPLATE_CONFIG_FILE "config/template_config.txt"

var/datum/template_config/template_config

/datum/template_config
	var/place_amount_min = 1
	var/place_amount_max = 3

	var/list/chances = list()
	var/list/ignore_types = list()
	var/list/zs = list()
	var/list/place_last = list()
	var/tries = 10
	var/directory

/datum/template_config/New()
	..()
	var/list/values = GetTemplateConfigValues()
	for(var/val in values)
		if(hasvar(src, val))
			var/value
			if(isnum(text2num(values[val])))
				value = text2num(values[val])
			else
				value = values[val]
			vars[val] = value

	PostInit()

/datum/template_config/proc/PostInit()
	if(istype(chances, /list) && length(chances))
		var/list/parsed_chances = list()

		for(var/chance in chances)
			var/list/parsed = params2list(chance)
			parsed_chances[parsed[1]] = text2num(parsed[parsed[1]])

		chances = parsed_chances
	else
		chances = params2list(chances)

	var/list/parsed_place_last_paths = list()
	if(istype(place_last, /list))
		for(var/path in place_last)
			parsed_place_last_paths += text2path(path)
	else
		parsed_place_last_paths = list(text2path(place_last))

	place_last = parsed_place_last_paths

/proc/GetTemplateConfigValues()
	var/list/lines = file2list(TEMPLATE_CONFIG_FILE)
	for(var/line in lines)
		if(copytext(line, 1, 2) == "#")
			lines.Remove(line)
		if(line == null || line == "" || line == "\n" || line == " ")
			lines.Remove(line)

	var/list/values = list()
	for(var/line in lines)
		var/token = lowertext(copytext(line, 1, findtext(line, " ", 1, 0)))
		var/value = copytext(line, length(token) + 2)
		if(!token)
			continue
		if(values.Find(token))
			var/list/newlist = list()
			newlist += values[token]
			newlist += value
			values[token] = newlist
			continue
		values.Add(token)
		values[token] = value
	return values

#undef TEMPLATE_CONFIG_FILE
