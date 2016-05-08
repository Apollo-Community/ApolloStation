/**
 * testHeavyProcess
 * This process is an example of a simple update loop process that does tons of
 * processing, but each step is fast.
 */

/datum/controller/process/testHeavyProcess/setup()
	name = "Heavy Process"
	schedule_interval = 29 // every second

/datum/controller/process/testHeavyProcess/doWork()
	var/tmp/v = 1
	for(var/i=0,i<10000000,i++) // Just to pretend we're doing something
		v = v
		if (!(i % 1000)) // Don't scheck too damn much, because we're doing effectively nothing here.
			scheck()


/datum/controller/process/testHeavyProcess/testHeavyProcess2/setup()
	..()
	name = "Heavy Process 2"
	schedule_interval = 31

/datum/controller/process/testHeavyProcess/testHeavyProcess3/setup()
	..()
	name = "Heavy Process 3"
	schedule_interval = 34