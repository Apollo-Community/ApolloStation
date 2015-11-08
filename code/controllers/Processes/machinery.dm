var/global/machinery_sort_required = 0
var/global/datum/controller/process/machinery/MachineProcess
var/list/MachineProcessing = list()

/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 40 // every 4 seconds
	cpu_threshold = 40	// just keep this chugging along

	MachineProcess = src

/datum/controller/process/machinery/doWork()
	internal_sort()
	internal_process_pipenets()
	internal_process_machinery()
	internal_process_power()
	internal_process_power_drain()

/datum/controller/process/machinery/proc/internal_sort()
	if(machinery_sort_required)
		machinery_sort_required = 0
		machines = dd_sortedObjectList(machines)

/datum/controller/process/machinery/proc/internal_process_machinery()
	for(var/obj/machinery/M in MachineProcessing)
		if(M && !M.gcDestroyed)
			if(M.process() == PROCESS_KILL)
				MachineProcessing -= M
				continue
			if(M.use_power)
				M.auto_use_power()

			scheck()

/datum/controller/process/machinery/proc/internal_process_power()
	for(var/datum/powernet/powerNetwork in powernets)
		if(istype(powerNetwork) && !powerNetwork.disposed)
			powerNetwork.reset()
			scheck()
			continue

		powernets.Remove(powerNetwork)

/datum/controller/process/machinery/proc/internal_process_power_drain()
	// Currently only used by powersinks. These items get priority processed before machinery
	for(var/obj/item/I in processing_power_items)
		if(!I.pwr_drain()) // 0 = Process Kill, remove from processing list.
			processing_power_items.Remove(I)
		scheck()

/datum/controller/process/machinery/proc/internal_process_pipenets()
	for(var/datum/pipe_network/pipeNetwork in pipe_networks)
		if(istype(pipeNetwork) && !pipeNetwork.disposed)
			pipeNetwork.process()
			scheck()
			continue

		pipe_networks.Remove(pipeNetwork)

/datum/controller/process/machinery/getStatName()
	return ..()+"(MCH:[MachineProcessing.len] PWR:[powernets.len] PIP:[pipe_networks.len])"
