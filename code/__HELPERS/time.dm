#define SECOND *10
#define SECONDS *10

#define MINUTE *600
#define MINUTES *600

//Returns the world time in english
proc/worldtime2text(time = world.time)
	return "[round(time / 36000)+8]:[(time / 600 % 60) < 10 ? add_zero(time / 600 % 60, 1) : time / 600 % 60]"

proc/time_stamp()
	return time2text(world.timeofday, "hh:mm:ss")

/* Preserving this so future generations can see how fucking retarded some people are
proc/time_stamp()
	var/hh = text2num(time2text(world.timeofday, "hh")) // Set the hour
	var/mm = text2num(time2text(world.timeofday, "mm")) // Set the minute
	var/ss = text2num(time2text(world.timeofday, "ss")) // Set the second
	var/ph
	var/pm
	var/ps
	if(hh < 10) ph = "0"
	if(mm < 10) pm = "0"
	if(ss < 10) ps = "0"
	return"[ph][hh]:[pm][mm]:[ps][ss]"
*/

/* Returns 1 if it is the selected month and day */
proc/isDay(var/month, var/day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

// Returns whether or not time since start is greater than delay or less than 0
/proc/delayPassed( var/delay, var/start )
	if((( world.timeofday - start) > delay ) || (( world.timeofday - start ) < 0))
		return 1
	return 0

/proc/getMonthDays( var/month )
	switch( month )
		if( 1 )
			return 31
		if( 2 )
			return 28
		if( 3 )
			return 31
		if( 4 )
			return 30
		if( 5 )
			return 31
		if( 6 )
			return 30
		if( 7 )
			return 31
		if( 8 )
			return 31
		if( 9 )
			return 30
		if( 10 )
			return 31
		if( 11 )
			return 30
		if( 12 )
			return 31

/proc/getMonthName( var/month )
	if( month < 1 || month > 12 )
		return "ERROR"

	var/list/months = list( "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" )
	return months[month]

/proc/print_date( var/list/date )
	if( !date || date.len < 3 )
		return "BAD DATE"

	var/year = text2num( date[1] )
	var/month = text2num( date[2] )
	var/day = text2num( date[3] )

	return "[getMonthName( month )] [day], [year]"
