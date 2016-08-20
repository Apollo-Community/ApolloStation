/datum/controller/process/fusion/setup()
	name = "fusion controller"
	schedule_interval = 5 // every 0.5 seconds

	if(!fusion_controller)
		fusion_controller = new

/datum/controller/process/fusion/doWork()
	fusion_controller.process()


/datum/controller/process/fusion_ball/setup()
	name = "fusion ball controller"
	schedule_interval = 5 // every 0.5 seconds
	if(isnull(fusion_balls))
		fusion_balls = list()

/datum/controller/process/fusion_ball/doWork()
	if(fusion_balls.len > 0)
		for(var/obj/fusion_ball/ball in fusion_balls)
			ball.process()