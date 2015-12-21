/turf/simulated/wall/alloy
	name = "alloy wall"
	desc = "An alloy wall."
	var/list/materials = list()
	var/unique_id = ""

// don't think New can be called properly considering how girders handle wall building
/turf/simulated/wall/alloy/proc/set_materials(var/list/comp)
	if(!comp)
		return
	materials = comp.Copy()
	var/pre = ""
	var/post = ""
	var/sum = 0
	for(var/M in materials)
		sum += materials[M]
		if(alloy_prefix[M])
			pre = alloy_prefix[M]
		else
			post = alloy_postfix[M]
	name = "[pre][post] wall"
	for(var/M in materials)
		materials[M] /= sum
		unique_id += "[M][materials[M]]"
	desc += " This one is plated with a [pre][post] alloy."
