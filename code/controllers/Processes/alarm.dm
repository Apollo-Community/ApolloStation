/datum/controller/process/alarm/setup()
	name = "alarm"
	schedule_interval = 40 // every 4 seconds
	cpu_threshold = 20

/datum/controller/process/alarm/doWork()
	alarm_manager.fire()

/datum/controller/process/alarm/getStatName()
	var/list/alarms = alarm_manager.active_alarms()
	return ..()+"([alarms.len])"
