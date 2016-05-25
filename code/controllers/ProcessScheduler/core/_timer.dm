#ifdef PRECISE_TIMER_AVAILABLE
var/global/__btime__lastTimeOfHour = 0
var/global/__btime__callCount = 0
var/global/__btime__lastTick = 0
#define TimeOfHour __btime__timeofhour()
#define __extern__timeofhour text2num(call("btime.[world.system_type==MS_WINDOWS?"dll":"so"]", "gettime")())
proc/__btime__timeofhour()
	if (!(__btime__callCount++ % 50))
		if (world.time > __btime__lastTick)
			__btime__callCount = 0
			__btime__lastTick = world.time
		global.__btime__lastTimeOfHour = __extern__timeofhour
	return global.__btime__lastTimeOfHour
#else
#define TimeOfHour world.timeofday % 36000
#endif
