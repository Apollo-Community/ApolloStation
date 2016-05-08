/*
	These are simple defaults for your project.
 */
#define DEBUG

var/global/datum/processSchedulerView/processSchedulerView

world
	loop_checks = 0
	tick_lag = 0.5
	New()
		..()
		processScheduler = new
		processSchedulerView = new

mob
	step_size = 8

	New()
		..()


	verb
		startProcessScheduler()
			set name = "Start Process Scheduler"
			processScheduler.setup()
			processScheduler.start()

		getProcessSchedulerContext()
			set name = "Get Process Scheduler Status Panel"
			processSchedulerView.getContext()

		stopProcessScheduler()
			processScheduler.isRunning = 0

		getTime()
			world << "[world.timeofday % 36000] == [TimeOfHour]"