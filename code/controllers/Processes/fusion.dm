var/global/list/fusion_controllers = list()

/datum/controller/process/fusion/setup()
	name = "fusion controller"
	schedule_interval = 5 // every 0.5 seconds

	if(!fusion_controllers)
		fusion_controllers = new()

/datum/controller/process/fusion/doWork()
	for(var/datum/fusion_controller/c in fusion_controllers)
		c.process()

/datum/controller/process/fusion_ball/setup()
	name = "fusion_ball"
	schedule_interval = 5 // every 0.5 seconds
	if(isnull(fusion_balls))
		fusion_balls = list()

/datum/controller/process/fusion_ball/doWork()
	if(fusion_balls.len > 0)
		for(var/obj/fusion_ball/ball in fusion_balls)
			ball.process()
	else
		disabled = 1