//To pull the forms from the wiki for easy editing.

//Global to store public forms (printable at the photocopier)
var/global/list/public_forms[0]

//Pulls a page from the wiki and gets the relevant data
/datum/pullFromWiki
	var/list/lineList

/datum/pullFromWiki/New()
	spawn()
		pullFromWeb()

/datum/pullFromWiki/proc/pullFromWeb()
	//var/url = "[config.wikiurl]index.php?title=Example_Paperwork"
	var/url = "https://apollo-community.org/wiki/index.php?title=Example_Paperwork"

	shell("python scripts/pullFromWiki.py \"[url]\"")

	//if(shell("python scripts/pullFromWiki.py [url]"))
	//	log_debug << "WARNING: error in retrieving forms from the wiki !"

	//Lets start the extracting and parsing
	var/page = file2text("scripts/wikiForms.txt")
	if(isnull(page) || page == "")
		log_debug("WARNING: pulled page is empty or none")
		return

	lineList = text2list(page)
	for(var/i = 1, i <= lineList.len, i++)
		world << "[i]: [lineList[i]]"
		//End of the document.
		if(findtext(lineList[i], "NewPP") > 0)
			break
		//This we will always find before a form starts.
		if(findtext(lineList[i], "--start--") != 0)
			i++
			world << "DEBUG found a form"
			var/formContent
			var/formName
			while(!(findtext(lineList[i], "--stop--") != 0))
				if(findtext(lineList[i], "Branch of Operation") != 0)
					formName = lineList[i+1]
				formContent += lineList[i]
				i++
			if(!isnull(formContent) && formContent != "" && !isnull(formName) && formName != "")
				public_forms["[formName]"] = formContent

	world << "DONE with getting forms"


/obj/item/weapon/paper/form/publicForm/New(var/content ,date , user as mob, index = 0)
	info = content
	//info = replacetext(info, "\[b\]Index:\[/b\] \[field\]", "\[b\]Index:\[/b\] [index]")
	..()