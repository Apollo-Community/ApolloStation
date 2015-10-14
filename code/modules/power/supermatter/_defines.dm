var/list/SM_COLORS = list( SM_DEFAULT_COLOR, \
						   "#00FF99", \
						   "#0099FF", \
						   "#6600FF", \
						   "#FF00FF", \
						   "#FF3399", \
						   "#FFFF00", \
						   "#FF6600", \
						   "#FF0000" )

/proc/getSMColor( var/level )
	if( level < 1 )
		level = 1

	if( level > 9 )
		level = 9

	return SM_COLORS[level]
