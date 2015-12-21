/turf/simulated/wall/alloy
	name = "alloy wall"
	desc = "A wall plated with a synthesized alloy."
	var/list/materials = list()
	var/unique_id = ""

/turf/simulated/wall/alloy/New(var/list/comp)
	..()
	set_materials(comp)

// don't think New can be called properly considering how girders handle wall building
/turf/simulated/wall/alloy/proc/set_materials(var/list/comp)
	if(!comp)
		return
	materials = comp
	var/pre = ""
	var/post = ""
	var/sum = 0
	for(var/M in comp)
		sum += comp[M]
		if(alloy_prefix[M])
			pre = alloy_prefix[M]
		else
			post = alloy_postfix[M]
	name = "[pre][post] alloy wall"
	for(var/M in materials)
		materials[M] /= sum
		unique_id += "[M][materials[M]]"
	desc += " This one is plated with a [pre][post] alloy."