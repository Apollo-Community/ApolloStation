/obj
	var/explosion_resistance

/turf
	var/explosion_resistance

/turf/space
	explosion_resistance = 3

/turf/simulated/floor
	explosion_resistance = 1

/turf/simulated/mineral
	explosion_resistance = 2

/turf/simulated/shuttle/floor
	explosion_resistance = 1

/turf/simulated/shuttle/floor4
	explosion_resistance = 1

/turf/simulated/shuttle/plating
	explosion_resistance = 1

/turf/simulated/shuttle/wall
	explosion_resistance = 10

/turf/simulated/wall
	explosion_resistance = 10

/turf/simulated/shuttle/wall/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = 0

/turf/simulated/shuttle/wall/engine/propulsion/burst
	name = "burst"

/turf/simulated/shuttle/wall/engine/propulsion/burst/left
	name = "left"
	icon_state = "burst_l"

/turf/simulated/shuttle/wall/engine/propulsion/burst/right
	name = "right"
	icon_state = "burst_r"