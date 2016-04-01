// This system defines news that will be displayed in the course of a round.
// Uses BYOND's type system to put everything into a nice format

/datum/news_announcement
	var
		round_time // time of the round at which this should be announced, in seconds
		message // body of the message
		author = "NanoTrasen Editor"
		channel_name = "Nyx Daily"
		can_be_redacted = 0
		message_type = "Story"

	revolution_inciting_event

		paycuts_suspicion
			round_time = 60*10
			message = {"Reports have leaked that Nanotrasen Inc. is planning to put paycuts into
						effect on many of its Research Stations in Tau Ceti. Apparently these research
						stations haven't been able to yield the expected revenue, and thus adjustments
						have to be made."}
			author = "Unauthorized"

		paycuts_confirmation
			round_time = 60*40
			message = {"Earlier rumours about paycuts on Research Stations in the Tau Ceti system have
						been confirmed. Shockingly, however, the cuts will only affect lower tier
						personnel. Heads of Staff will, according to our sources, not be affected."}
			author = "Unauthorized"

		human_experiments
			round_time = 60*90
			message = {"Unbelievable reports about human experimentation have reached our ears. According
			 			to a refugee from one of the Tau Ceti Research Stations, their station, in order
			 			to increase revenue, has refactored several of their facilities to perform experiments
			 			on live humans, including virology research, genetic manipulation, and \"feeding them
			 			to the slimes to see what happens\". Allegedly, these test subjects were neither
			 			humanified monkeys nor volunteers, but rather unqualified staff that were forced into
			 			the experiments, and reported to have died in a \"work accident\" by Nanotrasen Inc."}
			author = "Unauthorized"

	bluespace_research

		announcement
			round_time = 60*20
			message = {"The new field of research trying to explain several interesting spacetime oddities,
						also known as \"Bluespace Research\", has reached new heights. Of the several
						hundred space stations now orbiting in Tau Ceti, fifteen are now specially equipped
						to experiment with and research Bluespace effects. Rumours have it some of these
						stations even sport functional \"travel gates\" that can instantly move a whole research
						team to an alternate reality."}

	random_junk

		cheesy_honkers
			author = "Assistant Editor Carl Ritz"
			channel_name = "The Gibson Gazette"
			message = {"Do cheesy honkers increase risk of having a miscarriage? Several health administrations
						say so!"}
			round_time = 60 * 15

		net_block
			author = "Assistant Editor Carl Ritz"
			channel_name = "The Gibson Gazette"
			message = {"Several corporations banding together to block access to 'wetskrell.nt', site administrators
			claiming violation of net laws."}
			round_time = 60 * 50

		found_ssd
			channel_name = "Nyx Daily"
			author = "Doctor Eric Hanfield"

			message = {"Several people have been found unconscious at their terminals. It is thought that it was due
						to a lack of sleep or of simply migraines from staring at the screen too long. Camera footage
						reveals that many of them were playing games instead of working and their pay has been docked
						accordingly."}
			round_time = 60 * 90

	lotus_tree

		explosions
			channel_name = "Nyx Daily"
			author = "Reporter Leland H. Howards"

			message = {"The newly-christened civillian transport Lotus Tree suffered two very large explosions near the
						bridge today, and there are unconfirmed reports that the death toll has passed 50. The cause of
						the explosions remain unknown, but there is speculation that it might have something to do with
						the recent change of regulation in the Moore-Lee Corporation, a major funder of the ship, when M-L
						announced that they were officially acknowledging inter-species marriage and providing couples
						with marriage tax-benefits."}
			round_time = 60 * 30

	food_riots

		breaking_news
			channel_name = "Nyx Daily"
			author = "Reporter Ro'kii Ar-Raqis"

			message = {"Breaking news: Food riots have broken out throughout the Refuge asteroid colony in the Tenebrae
						Lupus system. This comes only hours after NanoTrasen officials announced they will no longer trade with the
						colony, citing the increased presence of \"hostile factions\" on the colony has made trade too dangerous to
						continue. NanoTrasen officials have not given any details about said factions. More on that at the top of
						the hour."}
			round_time = 60 * 10

		more
			channel_name = "Nyx Daily"
			author = "Reporter Ro'kii Ar-Raqis"

			message = {"More on the Refuge food riots: The Refuge Council has condemned NanoTrasen's withdrawal from
			the colony, claiming \"there has been no increase in anti-NanoTrasen activity\", and \"\[the only] reason
			NanoTrasen withdrew was because the \[Tenebrae Lupus] system's Phoron deposits have been completely mined out.
			We have little to trade with them now\". NanoTrasen officials have denied these allegations, calling them
			\"further proof\" of the colony's anti-NanoTrasen stance. Meanwhile, Refuge Security has been unable to quell
			the riots. More on this at 6."}
			round_time = 60 * 60

	nyx_developments

		legal_struggle
			channel_name = "Curios Commoner"
			author = "Editor Brad Oakley"

			message = {"A \"turf war\" between several megacorporations has broken out over a much disputed asteroid field
			in the Nyx system. Reports indicate the legal teams of Mattermonger and NanoTrasen have been hard at work.
			The past week, a total of over 100 legal papers from these two companies have flowed through the
			RAO (Regional Administration Office) in charge of Nyx. At least 90% of these are assumed to concern the
			disputed territory. The RAO have so far refused to provide any more details."}
			round_time = 60 * 10

		organized_crime
			channel_name = "Curios Commoner"
			author = "Journalist Reisso Ilsa"

			message = {"An increase in the activity of organized crime has Nyx officials worried. Experts fear that the
			sudden burst in criminal activity may be evidence of larger sleeper cells existing in the system.
			Director of System Security John Kelper from Safespace, the company tasked with the Nyx system's protection,
			says they still lack a lot of information, but mention that the criminals may be part of multiple organizations
			that are cooperating in a coalition. He also emphazises that even though civilian and logistics
			stations have been attacked, the ulterior motive seems to be corporate espionage."}
			round_time = 60 * 20

		new_station
			channel_name = "Curios Commoner"
			author = "Reporter Carly Baker"

			message = {"The recent discovery of a mineral rich asteroid field in close proximity to a planetary mist in
			the Nyx solar system has prompted the construction of a new research station. An asteroid prospecting drone investigating
			the asteroid field gave results that may indicate the existence of new, promising phoron structures. While Curios Commoner
			investiagors were turned away by construction site security, few companies have described an interest in working asteroids like
			the ones found in this field. It is most likely that Jenk Research, Mattermonger, NanoTrasen or Vagrant Exploration
			are behind the new station. Curios Commoner is following the case closely, and will follow up with more detailed reports."}
			round_time = 60 * 30

		legal_struggle_end
			channel_name = "Curios Commoner"
			author = "Editor Brad Oakley"

			message = {"Investigations carried out by the Regional Administration Office in the Nyx system seems to have put an end
			to the legal struggle between several megacorporations interested in a mineral rich asteroid field. Upon arrival at the
			fields, the inspectors were turned away by security officers assigned to the protection of the construction site. It has now
			become clear that NanoTrasen is behind the construction of the new station. The RAO claims to have \"granted NanoTrasen full
			permission and authority over the asteroid field in question\". NanoTrasen has commented on the case, saying \"we're excited to
			to be the pioneers behind what may very well be the beginning of a new field within phoron research. Nearly all of our Nyx resources
			have now been moved to the construction of this new research station\"."}
			round_time = 60 * 45


var/global/list/newscaster_standard_feeds = list(/datum/news_announcement/bluespace_research, /datum/news_announcement/lotus_tree, /datum/news_announcement/random_junk,  /datum/news_announcement/food_riots)

proc/process_newscaster()
	check_for_newscaster_updates(ticker.mode.newscaster_announcements)

var/global/tmp/announced_news_types = list()
proc/check_for_newscaster_updates(type)
	for(var/subtype in typesof(type)-type)
		var/datum/news_announcement/news = new subtype()
		if(news.round_time * 10 <= world.time && !(subtype in announced_news_types))
			announced_news_types += subtype
			announce_newscaster_news(news)

proc/announce_newscaster_news(datum/news_announcement/news)
	var/datum/feed_channel/sendto
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == news.channel_name)
			sendto = FC
			break

	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.locked = 1
		sendto.is_admin_channel = 1
		news_network.network_channels += sendto

	var/author = news.author ? news.author : sendto.author
	news_network.SubmitArticle(news.message, author, news.channel_name, null, !news.can_be_redacted, news.message_type)
