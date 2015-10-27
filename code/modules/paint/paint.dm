/datum/paint
	var/name = ""

	var/static/icon = 'icons/effects/paint.dmi'
	var/static/base_icon = "base_wall"
	var/static/stripe0_icon = "stripe0_wall"
	var/static/stripe1_icon = "stripe1_wall"

	var/base_color = null
	var/stripe0_color = null
	var/streip1_color = null

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
		streip1_color = null
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

/datum/paint/red
	name = "red"
	base_color = "#992E2E"

/datum/paint/orange
	name = "orange"
	base_color = "#CC6A29"

/datum/paint/yellow
	name = "yellow"
	base_color = "#CCCC3E"

/datum/paint/green
	name = "green"
	base_color = "#2E992E"

/datum/paint/blue
	name = "blue"
	base_color = "#2E2E99"

/datum/paint/purple
	name = "purple"
	base_color = "#62358D"

/datum/paint/brown
	name = "brown"
	base_color = "#62462B"

/datum/paint/black
	name = "black"
	base_color = "#1A1A1A"

/datum/paint/phoron
	name = "phoron"
	base_color = "#603F7F"