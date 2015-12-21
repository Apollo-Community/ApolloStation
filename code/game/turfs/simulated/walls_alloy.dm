/turf/simulated/wall/alloy
	name = "alloy wall"
	desc = "An alloy wall."
	var/list/materials = list()
	var/unique_id = ""

// don't think New can be called properly considering how girders handle wall building
/turf/simulated/wall/alloy/proc/set_materials(var/list/comp)
	if(!comp)
		return
	// why set it twice? this has actually proved to be an issue
	if(materials.len >= 2 && unique_id != "")
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

	// alloy benefits, woo!

	// phoron - +100 max temp. per %, up to 5000
	if(materials["solid phoron"])
		max_temperature += (100 * (2 * materials["solid phoron"] * 100))

// urametallic walls give partial or full rot immunity
/turf/simulated/wall/alloy/rot()
	if(materials["uranium"])
		var/rot_prob = 100 - (2 * materials["uranium"] * 100)
		usr << "Uranium percentage: [materials["uranium"]]"
		usr << "Rot probability: [rot_prob]"
		if(prob(rot_prob))
			usr << "Wall is rotting"
			..()
