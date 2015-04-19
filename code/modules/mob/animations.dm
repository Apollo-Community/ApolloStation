/proc/anim_spin(var/mob/user)
    // cast a spell on a monster: make the icon spin
    // this animation takes 3s total (6 ticks * 5)
    animate(src, transform = turn(matrix(), 360), time = 1)

/proc/anim_grow(var/mob/user)
    // expand (scale by 2x2) and fade out over 1/2s
    animate(src, transform = matrix()*2, time = 4)

/*
/proc/anim_attack( var/mob/user, var/mob/target )
	if( user.loc == target.loc )
		return

	var/attack_dir = get_dir(user.loc, target)

	var/init_x = user.pixel_x
	var/init_y = user.pixel_y
	var/temp_x = 0
	var/temp_y = 0
	var/anim_dist = 4 // Distance to shift the sprite in an attack

	switch(attack_dir)
		if(NORTH)
			temp_x = 0
			temp_y = anim_dist
		if(NORTHEAST)
			temp_x = anim_dist
			temp_y = anim_dist
		if(EAST)
			temp_x = anim_dist
			temp_y = 0
		if(SOUTHEAST)
			temp_x = anim_dist
			temp_y = -anim_dist
		if(SOUTH)
			temp_x = 0
			temp_y = -anim_dist
		if(SOUTHWEST)
			temp_x = -anim_dist
			temp_y = -anim_dist
		if(WEST)
			temp_x = anim_dist
			temp_y = 0
		if(NORTHWEST)
			temp_x = -anim_dist
			temp_y = anim_dist

    animate(user, pixel_x = init_x+temp_x, pixel_y = init_y+temp_y, time = 2, easing = LINEAR_EASING)
    animate(user, pixel_x = init_x, pixel_y = init_y, time = 1, easing = LINEAR_EASING)
*/