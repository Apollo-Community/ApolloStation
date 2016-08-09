#define SECOND *10
#define SECONDS *10

#define MINUTE *600
#define MINUTES *600

//Returns the world time in english
proc/worldtime2text(time = world.time, var/bonus_time = 8)
	var/hours = round(time / 36000)+bonus_time
	return "[hours < 10 ? hours : add_zero( hours )]:[(time / 600 % 60) < 10 ? add_zero(time / 600 % 60, 1) : time / 600 % 60]"

proc/time_stamp()
	return time2text(world.timeofday, "hh:mm:ss")

/* Returns 1 if it is the selected month and day */
proc/isDay(var/month, var/day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1
	return 0

// Returns whether or not time since start is greater than delay or less than 0
/proc/delayPassed( var/delay, var/start )
	if((( world.timeofday - start) > delay ) || (( world.timeofday - start ) < 0))
		return 1
	return 0

/proc/getMonthDays( var/month )
	var/list/month_days = list( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ) // yuck
	var/days = 31

	if( month_days[month] )
		days = month_days[month]

	return days

/proc/getMonthName( var/month )
	if( month < 1 || month > 12 )
		return "ERROR"

	var/list/months = list( "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" )
	return months[month]

/proc/print_date( var/list/date )
	if( !date || date.len < 3 )
		return "BAD DATE"

	var/year = text2num( date["year"] )
	var/month = text2num( date["month"] )
	var/day = text2num( date["day"] )

	if( !year )
		year = 2560

	if( !month )
		month = 1

	if( !day )
		day = 1

	return "[getMonthName( month )] [day], [year]"

/proc/progessDate( var/list/date, var/progression = 1 )
	var/year = date["year"]
	var/month = date["month"]
	var/days = date["day"]

	days += progression

	while( days > getMonthDays( month ))
		days -= getMonthDays( month )
		month++

		if( month > 12 )
			month = 1
			year++

	if( days < 1 )
		days = 1

	return list( "year" = year, "month" = month, "day" = days )

// Returns how many days are between current and future
/proc/daysTilDate( var/list/current, var/list/future )
	return daysSinceDefaultDate( future )-daysSinceDefaultDate( current )

/proc/daysSinceDefaultDate( var/list/date )
	if( !date || date.len != 3 )
		return 0

	var/years = date["year"]-START_YEAR
	var/months = date["month"]-1
	var/days = date["day"]-1

	for( var/i = 1, i <= months, i++ )
		days += getMonthDays( i )

	days += years*365

	return days
