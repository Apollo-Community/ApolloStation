/datum/paint
	var/static/icon = 'icons/effects/paint.dmi'
	var/static/base_icon = "base_wall"
	var/static/stripe0_icon = "stripe0_wall"
	var/static/stripe1_icon = "stripe1_wall"

	var/base_color = null
	var/stripe0_color = null
	var/stripe1_color = null

/datum/paint/proc/paint( var/color, var/mode = "base" )
	switch( mode )
		if( "base" )
			base_color = color
			return
		if( "stripe0" )
			stripe0_color = color
			return
		if( "stripe1" )
			stripe1_color = color
			return

/datum/paint/proc/unpaint( var/mode = null )
	if( !mode )
		base_color = null
		stripe0_color = null
		stripe1_color = null
	else
		switch( mode )
			if( "base" )
				base_color = null
				return
			if( "stripe0" )
				stripe0_color = null
				return
			if( "stripe1" )
				stripe1_color = null
				return

/datum/paint/proc/getColor( var/mode = "base" )
	switch( mode )
		if( "base" )
			if( base_color )
				return paint_colors[base_color]
			else
				return null
		if( "stripe0" )
			if( stripe0_color )
				return paint_colors[stripe0_color]
			else
				return null
		if( "stripe1" )
			if( stripe1_color )
				return paint_colors[stripe1_color]
			else
				return null

/datum/paint/red
	base_color = "red"

/datum/paint/orange
	base_color = "orange"

/datum/paint/yellow
	base_color = "yellow"

/datum/paint/green
	base_color = "green"

/datum/paint/blue
	base_color = "blue"

/datum/paint/purple
	base_color = "purple"

/datum/paint/brown
	base_color = "brown"

/datum/paint/black
	base_color = "black"

/datum/paint/phoron
	base_color = "phoron"