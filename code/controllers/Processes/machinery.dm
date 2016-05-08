var/global/datum/controller/process/machinery/MachineProcess
var/list/MachineProcessing = list()

/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 50 // every 5 seconds
	tick_allowance = 40	// just keep this chugging along

	MachineProcess = src

/datum/controller/process/machinery/doWork()
	internal_process_pipenets()
	internal_process_machinery()
	internal_process_power()
	internal_process_power_drain()

/datum/controller/process/machinery/proc/internal_process_machinery()
	//Going to try processing in batches of 400
	var/tmp/ceil_val = Ceiling(MachineProcessing.len/400)
	schedule_interval = 8+(4*ceil_val)	// fancy variable scheduling
	for(var/i = 0; i < ceil_val; i++)	//have to ceiling this so we don't miss out on extras
		var/adjusted_i = i == 0 ? i : i*400
		spawn(4*i)
			for(var/x = 1+adjusted_i; x < 400+adjusted_i; x++)
				if(x > MachineProcessing.len)		break
				var/obj/machinery/M = MachineProcessing[x]
				if(M && !M.gcDestroyed)
					if(M.process() == PROCESS_KILL)
						MachineProcessing -= M
						scheck()
						continue
					if(M.use_power)
						M.auto_use_power()

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
