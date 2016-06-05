var/list/MachineProcessing = list()
var/list/SolarControl = list()

/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 50 // every 5 seconds

/datum/controller/process/machinery/doWork()
	var/c = 10
	//atmos pipes
	for(var/datum/pipe_network/pipeNetwork in pipe_networks)
		if(!pipeNetwork.disposed)
			pipeNetwork.process()
			if(!(c++ % 10))		scheck()
		else
			pipe_networks.Remove(pipeNetwork)

	//machinery
	for(var/obj/machinery/M in MachineProcessing)
		last_object = "[M] ([M.x],[M.y],[M.z])"
		if(!M.gcDestroyed)
			if(!(c++ % 40))		scheck()
			if(M.process() == PROCESS_KILL)
				MachineProcessing -= M
				continue
			if(M.use_power)				M.auto_use_power()

	//power network
	for(var/datum/powernet/powerNetwork in powernets)
		if(!powerNetwork.disposed)
			powerNetwork.reset()
			if(!(c++ % 5))		scheck()
			continue

		powernets.Remove(powerNetwork)

	//solars -- no need to process all the panels if they're not connected to any control console	~323 panels saved @ 10 May 16
	for(var/obj/machinery/power/solar_control/SC in SolarControl)
		if(!SC.gcDestroyed)
			SC.process()
			for(var/obj/machinery/power/solar/P in SC.connected_panels)
				if(!P.gcDestroyed)
					P.process()
					if(!(c++ % 30))		scheck()
				else
					SC.connected_panels -= P
		else
			SolarControl -= SC

	//power sinks
	for(var/obj/item/I in processing_power_items)
		if(!I.pwr_drain()) // 0 = Process Kill, remove from processing list.
			processing_power_items.Remove(I)

/datum/controller/process/machinery/getContext()
	return ..()+" - (MCH:[MachineProcessing.len] PWR:[powernets.len] PIP:[pipe_networks.len])"
