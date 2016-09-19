/datum/controller/process/discord/setup()
	name = "Discord A help Puller"
	schedule_interval = 10 // every seccond

	if(!fusion_controllers)
		fusion_controllers = new()

/datum/controller/process/discord/doWork()
	check_discord_ahelp()