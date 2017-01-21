//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "Wiki"
	set desc = "Visit the wiki."
	set hidden = 1
	if( config.wikiurl )
		if(alert("This will open the wiki in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.wikiurl)
	else
		src << "<span class='alert'>The wiki URL is not set in the server configuration.</span>"
	return

/client/verb/forum()
	set name = "Forum"
	set desc = "Visit the forum."
	set hidden = 1
	if( config.forumurl )
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.forumurl)
	else
		src << "<span class='alert'>The forum URL is not set in the server configuration.</span>"
	return

#define RULES_FILE "config/rules.html"
/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = 1
	if( config.wikiurl )
		if(alert("This will open the rules in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link("http://apollo-community.enjin.com/forum/m/41735571/viewthread/29434722-community-guidelines-rules")
	else
		src << "<span class='alert'>The wiki URL is not set in the server configuration.</span>"
	return


	//src << browse(file(RULES_FILE), "window=rules;size=480x320")
#undef RULES_FILE

/client/verb/sourcecode()
	set name = "Source Code"
	set desc = "View the source code on GitHub."
	set hidden = 1
	if( config.gitrepourl )
		if(alert("This will open the server's git repository in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.gitrepourl)
	else
		src << "<span class='alert'>The server's git repository is not set in the server configuration.</span>"
	return

/client/verb/discord()
	set name = "Discord"
	set desc = "Join Apollo Station's Discord chat!"
	set hidden = 1
	if( config.discordinvurl )
		if(alert("This will open the server's discord invite page in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.discordinvurl)
	else
		src << "<span class='alert'>This server's discord chat is not set in the server configuration.</span>"
	return

#define CHANGELOG_FILE "html/changelog.html"
/client/verb/changelog()
	set name = "Changelog"
	set desc = "Show Server Changelog."
	set hidden = 1
	src << browse(file(CHANGELOG_FILE), "window=changelog;size=480x320")
#undef CHANGELOG_FILE

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tt = say
\t5 = emote
\tx = swap-hand
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tF1 = adminhelp
\tF2 = ooc
\tF3 = say
\tF4 = emote
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
</font>"}

	var/admin = {"<font color='purple'>
Admin:
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel-new
\tF7 = admin-pm
\tF8 = Invisimin
</font>"}

	src << hotkey_mode
	src << other
	if(holder)
		src << admin
