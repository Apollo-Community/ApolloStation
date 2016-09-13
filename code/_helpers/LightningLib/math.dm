/**
 * math functions
 */

proc
	__atan2(x,y)
		return (x||y)&&(y>=0 ? arccos(x/sqrt(x*x+y*y)) : 360-arccos(x/sqrt(x*x+y*y)))


	__rand(min, max, precision = 3)
		var/d = 10 ** precision

		return rand(min * d, max * d) / d