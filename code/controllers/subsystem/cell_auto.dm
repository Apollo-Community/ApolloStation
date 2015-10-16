var/global/datum/cell_auto_handler/v_wave_handler = new()

/datum/subsystem/cell_auto
	//things you will want to define
	name = "Cellular Automata"			//name of the subsystem

	var/list/datum/cell_auto_handler/handlers = list()

//used to initialize the subsystem BEFORE the map has loaded
/datum/subsystem/cell_auto/New()
	..()

	handlers += v_wave_handler

//previously, this would have been named 'process()' but that name is used everywhere for different things!
//fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
//fire(), and the procs it calls, SHOULD NOT HAVE ANY SLEEP OPERATIONS in them!
//YE BE WARNED!
/datum/subsystem/cell_auto/fire()
	for( var/datum/cell_auto_handler/handler in handlers )
		handler.process()
