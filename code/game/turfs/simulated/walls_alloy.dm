/turf/simulated/wall/alloy
	name = "alloy wall"
	desc = "An alloy wall."
	icon_state = "r_wall"

	damage_cap = 350

	var/list/materials = list()
	var/unique_id = ""
	var/scorched = 0

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
		max_temperature += 1000 * (materials["solid phoron"] * 200)

	// diamond - reduces damage and increases health
	if(materials["diamond"])
		damage_cap += materials["diamond"] * 1400
		armor -= materials["diamond"] * 0.9

	// iron - weaker version of diamond
	if(materials["iron"])
		damage_cap += materials["iron"] * 700
		armor -= materials["iron"] * 0.7

// urametallic walls give partial or full rot immunity
/turf/simulated/wall/alloy/rot()
	if(materials["uranium"])
		var/rot_prob = 100 - (materials["uranium"] * 800)
		usr << "Uranium percentage: [materials["uranium"]]"
		usr << "Rot probability: [rot_prob]"
		if(prob(rot_prob))
			usr << "Wall is rotting"
			..()

// osimetallic walls handle explosions much better - they are never guaranteed to get dismantled
/turf/simulated/wall/alloy/ex_act(severity)
	if(materials["osmium"])
		var/damage = 100 - (materials["osmium"] * 150)
		switch(severity)
			if(1)
				if(prob(50 + (materials["osmium"] * 100)))
					take_damage(rand(damage, damage + 100))
				else
					dismantle_wall(1,1)
			if(2)
				take_damage(rand(damage, damage + 50))
			if(3)
				take_damage(rand(0, damage * 2))
				if(!scorched)
					scorched = 1
					desc += " It has some small scorch marks on it."
	else
		..()