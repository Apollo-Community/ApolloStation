/obj/item/tictac
	name = "Tic-Tac-Toe"
	desc = "A board to play Tic-Tac-Toe on!"
	icon = './icons/apollo/tictac.dmi'

	var/list/base_icons = list("wood", "checker", "bar")
	var/turn = 0
	//0 = blue, 1 = red

/obj/item/tictac/New()
	icon_state = pick(base_icons)
	turn_hud()

/obj/item/tictac/verb/change_board()
	set name = "Change board"
	set category = "Object"
	set src in view(1)

	var/board = input("Select a new board base") as anything in base_icons
	if(prob(40))
		board ="glitch"
		usr.visible_message("<span class='warning'>The [name] board's backlight malfunctions!</span>")

	icon_state = board

/obj/item/tictac/verb/reset()
	set name = "Reset board"
	set category = "Object"
	set src in view(1)

	//Resets the game board
	usr.visible_message("<span class='notice'>[usr] resets the [name] board.</span>")
	overlays.Cut()

/obj/item/tictac/proc/turn_hud()
	for(var/image/I as anything in overlays)
		if(I.icon_state == "turn")
			overlays -= I

	//Have to do this the messy way because of some byond bugs
	var/image/I = image(icon, "turn")
	I.color = turn ? "#FF0033" : "#3300FF"
	overlays += I

/obj/item/tictac/proc/place_piece(var/x_offset, var/y_offset)
	overlays += image(icon, "[turn ? "circle" : "cross"]", pixel_x = x_offset, pixel_y = y_offset)
	turn = turn ? 0 : 1			// Changes players turn
	turn_hud()
	usr.visible_message("<span class='notice'>[usr] places a [turn ? "circle" : "cross"] piece from the [name] board.</span>")

/obj/item/tictac/proc/remove_piece(var/x_offset, var/y_offset)
	if(overlays.len >= 10)	//A Quality of life chance to the board clears if you have all the pieces in play
		overlays.Cut()
		usr.visible_message("<span class='notice'>The [name] board resets the game</span>")
		return 2

	for(var/image/I as anything in overlays)
		if(I.pixel_x == x_offset && I.pixel_y == y_offset)
			overlays -= I
			turn = turn ? 0 : 1			// Changes players turn
			return 1

/obj/item/tictac/proc/calc_x(var/offset_x)
	switch(offset_x)
		if(9 to 13)		return 7
		if(15 to 19)	return 13
		if(21 to 25)	return 19

/obj/item/tictac/proc/calc_y(var/offset_y)
	switch(offset_y)
		if(11 to 15)	return 9
		if(17 to 21)	return 15
		if(23 to 27)	return 21

/obj/item/tictac/Click(location, control, params)
	if(!ishuman(usr) || get_dist(usr,src) > 1 || usr.stat >= 1)	return
	var/paramslist = params2list(params)

	var/click_x = text2num(paramslist["icon-x"]);
	var/click_y = text2num(paramslist["icon-y"])

	click_x = calc_x(click_x)
	click_y = calc_y(click_y)

	//Clicked on the lines or a silly location
	if(!click_x || !click_y)		return

	switch(remove_piece(click_x, click_y))
		if(null)		place_piece(click_x, click_y)
		if(1)			usr.visible_message("<span class='notice'>[usr] removes a [turn ? "circle" : "cross"] piece from the [name] board.</span>")

/obj/item/tictac/DblClick(object,location, control, params)
	//Stops people picking up the board by accident
	Click(location,control,params)
