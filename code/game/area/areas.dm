/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = list( 'sound/music/music.ogg' )

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/area
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = 10
	luminosity = 0
	mouse_opacity = 0

	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1
	var/party = null

	var/lightswitch = 1

	var/eject = null

	var/debug = 0
	var/requires_power = 1
	var/always_unpowered = 0	// this gets overriden to 1 for space in area/New()

	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0

	var/has_gravity = 1
	var/list/apc = list()
	var/no_air = null
//	var/list/lights				// list of all lights on this area
	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = 0
	var/list/ambience = list( 'sound/ambience/shipambience.ogg' )
	var/list/music = list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambigen14.ogg')
	var/sound/forced_ambience = null

	var/base_turf = /turf/space

	var/parallax_style = "space"

	var/rad_shielded = 0
	var/environment = ROOM

/*-----------------------------------------------------------------------------*/

/////////
//SPACE//
/////////

/area/space
	name = "\improper Space"
	icon_state = "space"
	requires_power = 1
	always_unpowered = 1
	lighting_use_dynamic = 0
	power_light = 0
	power_equip = 0
	power_environ = 0
	music = list('sound/ambience/ambispace.ogg','sound/ambience/ambispace1.ogg','sound/ambience/ambispace2.ogg')
	ambience = list()
	environment = PLAIN

/area/space/s_hanger_1
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_2
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_3
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_4
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_5
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_6
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_7
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_8
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_9
	name = "\improper Space"
	icon_state = "space_1"

/area/space/s_hanger_10
	name = "\improper Space"
	icon_state = "space_1"

/area/space/inner
	name = "\improper Inner Station Space"
	icon_state = "space"

area/space/atmosalert()
	return

/area/space/firealert()
	return

/area/space/readyalert()
	return

/area/space/partyalert()
	return

/area/space/bluespace
	name = "\improper Bluespace"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/space/bluespace/hanger_1
	icon_state = "start"
	name = "\improper Bluespace"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/space/bluespace/hanger_2
	icon_state = "start"
	name = "\improper Bluespace"

/area/space/bluespace/hanger_3
	icon_state = "start"
	name = "\improper Bluespace"

/area/space/bluespace/hanger_4
	icon_state = "start"
	name = "\improper Bluespace"

/area/space/bluespace/hanger_5
	icon_state = "start"
	name = "\improper Bluespace"

/area/space/bluespace/hanger_6
	icon_state = "start"
	name = "\improper Bluespace"

/area/space/bluespace/hanger_7
	icon_state = "start"
	name = "\improper Bluespace"

/area/engine/
	music = list('sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg' )

/area/turret_protected/

/area/arrival
	requires_power = 0

/area/arrival/start
	name = "\improper Arrival Area"
	icon_state = "start"

/area/admin
	name = "\improper Admin room"
	icon_state = "start"



//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	requires_power = 0
	lighting_use_dynamic = 1
	environment = CAVE

/area/hanger
	requires_power = 0
	lighting_use_dynamic = 1
	environment = CAVE

/area/hanger/north
	name = "\improper Hangar"
	icon_state = "north"

/area/hanger/northeast
	name = "\improper Hangar"
	icon_state = "northeast"

/area/hanger/east
	name = "\improper Hangar"
	icon_state = "east"

/area/hanger/southeast
	name = "\improper Hangar"
	icon_state = "southeast"

/area/hanger/south
	name = "\improper Hangar"
	icon_state = "south"

/area/hanger/southwest
	name = "\improper Hangar"
	icon_state = "southwest"

/area/hanger/west
	name = "\improper Hangar"
	icon_state = "west"

/area/hanger/northwest
	name = "\improper Hangar"
	icon_state = "northwest"

/area/shuttle/arrival
	name = "\improper Arrival Shuttle"

/area/shuttle/escape
	name = "\improper Emergency Shuttle"

/area/shuttle/escape/spawn_area
	name = "\improper Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "\improper Emergency Shuttle Transit"
	icon_state = "shuttle"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/shuttle/escape_pod1
	name = "\improper Escape Pod One"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/shuttle/escape_pod2
	name = "\improper Escape Pod Two"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/shuttle/escape_pod3
	name = "\improper Escape Pod Three"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "\improper Escape Pod Five"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/shuttle/mining
	name = "\improper Mining Shuttle"

/area/shuttle/mining/station
	icon_state = "shuttle2"

/area/shuttle/mining/outpost
	icon_state = "shuttle"

/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Base"
	requires_power = 1
	luminosity = 0

/area/shuttle/merchant
	icon_state = "shuttle"
	name = "\improper Merchant Shuttle"
	requires_power = 1
	luminosity = 0

/area/shuttle/merchant/dock
	icon_state = "shuttle"
	name = "\improper Merchant Shuttle Dock"
	requires_power = 1
	luminosity = 0

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper Alien Shuttle Mine"
	requires_power = 1
	luminosity = 0

/area/shuttle/prison/
	name = "\improper Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/specops/station
	name = "\improper Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite/mothership
	name = "\improper Merc Elite Shuttle"
	icon_state = "shuttlered"
	lighting_use_dynamic = 0

/area/shuttle/syndicate_elite/station
	name = "\improper Merc Elite Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/administration/centcom
	name = "\improper Administration Shuttle Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "\improper Administration Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"

/area/shuttle/thunderdome/grnshuttle
	name = "\improper Thunderdome GRN Shuttle"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "\improper GRN Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "\improper GRN Station"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "\improper Thunderdome RED Shuttle"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "\improper RED Shuttle"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "\improper RED Station"
	icon_state = "shuttlered2"
// === Trying to remove these areas:

/area/shuttle/research
	name = "\improper Research Shuttle"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost
	icon_state = "shuttle"

/area/shuttle/vox/station
	name = "\improper Vox Skipjack"
	icon_state = "yellow"
	requires_power = 0
	lighting_use_dynamic = 0


/area/shuttle/laborcamp/station
	name = "\improper Labor Camp Shuttle"
	icon_state = "shuttlered"

/area/shuttle/laborcamp/outpost
	name = "\improper Labor Camp Shuttle"
	icon_state = "shuttlered"

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

// === end remove

/area/alien
	name = "\improper Alien base"
	icon_state = "yellow"
	requires_power = 0

//SYNDICATES

/area/syndicate_mothership/control
	name = "\improper Mercenary Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/shuttle
	name = "\improper Elite Mercenary Squad"
	icon_state = "syndie-elite"

//EXTRA

/area/asteroid					// -- TLE
	name = "\improper Asteroid"
	icon_state = "asteroid"
	requires_power = 0

/area/asteroid/cave				// -- TLE
	name = "\improper Asteroid - Underground"
	icon_state = "cave"
	requires_power = 0

/area/asteroid/artifactroom
	name = "\improper Asteroid - Artifact"
	icon_state = "cave"




/area/planet/clown
	name = "\improper Clown Planet"
	icon_state = "honk"
	requires_power = 0

//ENEMY

//names are used
/area/syndicate_station
	name = "\improper Independant Station"
	icon_state = "yellow"
	requires_power = 0
	rad_shielded = 1
	lighting_use_dynamic = 0

/area/syndicate_station/start
	name = "\improper Mercenary Forward Operating Base"
	icon_state = "yellow"

/area/syndicate_station/southwest
	name = "\improper south-west of SS13"
	icon_state = "southwest"

/area/syndicate_station/northwest
	name = "\improper north-west of SS13"
	icon_state = "northwest"

/area/syndicate_station/northeast
	name = "\improper north-east of SS13"
	icon_state = "northeast"

/area/syndicate_station/southeast
	name = "\improper south-east of SS13"
	icon_state = "southeast"

/area/syndicate_station/south
	name = "\improper south of SS13"
	icon_state = "south"

/area/syndicate_station/commssat
	name = "\improper south of the communication satellite"
	icon_state = "south"

/area/syndicate_station/mining
	name = "\improper north east of the mining asteroid"
	icon_state = "north"

/area/syndicate_station/maint_dock
	name = "\improper docked with station"
	icon_state = "shuttle"

/area/syndicate_station/transit
	name = "\improper bluespace"
	icon_state = "shuttle"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/vox_station
	requires_power = 0
	rad_shielded = 1
	lighting_use_dynamic = 0

/area/vox_station/transit
	name = "\improper bluespace"
	icon_state = "shuttle"
	ambience = list('sound/ambience/ambbspace.ogg')
	environment = UNDERWATER
	parallax_style = "bluespace"

/area/vox_station/southwest_solars
	name = "\improper aft port solars"
	icon_state = "southwest"
	lighting_use_dynamic = 0

/area/vox_station/northwest_solars
	name = "\improper fore port solars"
	icon_state = "northwest"
	lighting_use_dynamic = 0

/area/vox_station/northeast_solars
	name = "\improper fore starboard solars"
	icon_state = "northeast"
	lighting_use_dynamic = 0

/area/vox_station/southeast_solars
	name = "\improper aft starboard solars"
	icon_state = "southeast"
	lighting_use_dynamic = 0

/area/vox_station/mining
	name = "\improper nearby mining asteroid"
	icon_state = "north"

//PRISON
/area/prison
	name = "\improper Prison Station"
	icon_state = "brig"
	environment = HALLWAY

/area/prison/arrival_airlock
	name = "\improper Prison Station Airlock"
	icon_state = "green"
	requires_power = 0

/area/prison/control
	name = "\improper Prison Security Checkpoint"
	icon_state = "security"

/area/prison/crew_quarters
	name = "\improper Prison Security Quarters"
	icon_state = "security"

/area/prison/rec_room
	name = "\improper Prison Rec Room"
	icon_state = "green"

/area/prison/closet
	name = "\improper Prison Supply Closet"
	icon_state = "dk_yellow"
	environment = ROOM

/area/prison/hallway/fore
	name = "\improper Prison Fore Hallway"
	icon_state = "yellow"

/area/prison/hallway/aft
	name = "\improper Prison Aft Hallway"
	icon_state = "yellow"

/area/prison/hallway/port
	name = "\improper Prison Port Hallway"
	icon_state = "yellow"

/area/prison/hallway/starboard
	name = "\improper Prison Starboard Hallway"
	icon_state = "yellow"

/area/prison/morgue
	name = "\improper Prison Morgue"
	icon_state = "morgue"

/area/prison/medical_research
	name = "\improper Prison Genetic Research"
	icon_state = "medresearch"

/area/prison/medical
	name = "\improper Prison Medbay"
	icon_state = "medbay"

/area/prison/solar
	name = "\improper Prison Solar Array"
	icon_state = "storage"
	requires_power = 0
	lighting_use_dynamic = 0

/area/prison/podbay
	name = "\improper Prison Podbay"
	icon_state = "dk_yellow"

/area/prison/solar_control
	name = "\improper Prison Solar Array Control"
	icon_state = "dk_yellow"

/area/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/prison/execution
	name = "Execution Chamber"
	icon_state = "brig"

/area/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brig"

/area/prison/cell_block/B
	name = "Prison Cell Block B"
	icon_state = "brig"

/area/prison/cell_block/C
	name = "Prison Cell Block C"
	icon_state = "brig"

/area/holodeck/source_burntest
	name = "\improper Holodeck - Atmospheric Burn Test"

/area/gateway
	name = "\improper Gateway"
	icon_state = "teleporter"
	music = list( 'sound/ambience/signal.ogg' )
	environment = QUARRY

/*
	New()
		..()

		spawn(10) //let objects set up first
			for(var/turf/turfToGrayscale in src)
				if(turfToGrayscale.icon)
					var/icon/newIcon = icon(turfToGrayscale.icon)
					newIcon.GrayScale()
					turfToGrayscale.icon = newIcon
				for(var/obj/objectToGrayscale in turfToGrayscale) //1 level deep, means tables, apcs, locker, etc, but not locker contents
					if(objectToGrayscale.icon)
						var/icon/newIcon = icon(objectToGrayscale.icon)
						newIcon.GrayScale()
						objectToGrayscale.icon = newIcon
*/

////////////WORK IN PROGRESS//////////

//DERELICT

/area/derelict
	name = "\improper Derelict Station"
	icon_state = "storage"
	environment = PLAIN

/area/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "\improper Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "\improper Derelict Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "\improper Derelict Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "\improper Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "\improper Derelict Solar Control"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "\improper Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "\improper Derelict Morgue"
	icon_state = "morgue"

/area/derelict/medical/chapel
	name = "\improper Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "\improper Derelict Teleporter"
	icon_state = "teleporter"

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/derelict/ship
	name = "\improper Abandoned Ship"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "\improper Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "\improper Derelict Aft Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "\improper Derelict Singularity Engine"
	icon_state = "engine"

//HALF-BUILT STATION (REPLACES DERELICT IN BAYCODE, ABOVE IS LEFT FOR DOWNSTREAM)
/area/constructionsite
	name = "\improper Construction Site"
	icon_state = "storage"
	environment = PLAIN

/area/constructionsite/storage
	name = "\improper Construction Site Storage Area"

/area/constructionsite/science
	name = "\improper Construction Site Research"

/area/constructionsite/bridge
	name = "\improper Construction Site Bridge"
	icon_state = "bridge"

/area/constructionsite/maintenance
	name = "\improper Construction Site Maintenance"
	icon_state = "yellow"

/area/constructionsite/hallway/aft
	name = "\improper Construction Site Aft Hallway"
	icon_state = "hallP"

/area/constructionsite/hallway/fore
	name = "\improper Construction Site Fore Hallway"
	icon_state = "hallS"

/area/constructionsite/atmospherics
	name = "\improper Construction Site Atmospherics"
	icon_state = "green"

/area/constructionsite/medical
	name = "\improper Construction Site Medbay"
	icon_state = "medbay"

/area/constructionsite/ai
	name = "\improper Construction Computer Core"
	icon_state = "ai"

/area/constructionsite/engineering
	name = "\improper Construction Site Engine Bay"
	icon_state = "engine"

/area/solar/constructionsite
	name = "\improper Construction Site Solars"
	icon_state = "aft"

//Misc

/area/wreck/ai
	name = "\improper AI Chamber"
	icon_state = "ai"
	environment = PLAIN

/area/wreck/main
	name = "\improper Wreck"
	icon_state = "storage"
	environment = PLAIN

/area/wreck/engineering
	name = "\improper Power Room"
	icon_state = "engine"
	environment = PLAIN

/area/wreck/bridge
	name = "\improper Bridge"
	icon_state = "bridge"
	environment = PLAIN

/area/generic
	name = "Unknown"
	icon_state = "storage"
	environment = QUARRY

// Labor Camp
/area/laborcamp
	name = "Labor Camp"
	icon_state = "brig"
	environment = QUARRY

/area/laborcamp/cargohold
	name = "\improper Cargohold"
	icon_state = "brig"

/area/laborcamp/armory
	name = "\improper Armory"
	icon_state = "brig"

/area/laborcamp/office
	name = "\improper Office"
	icon_state = "brig"

/area/laborcamp/officebackroom
	name = "\improper Office Backroom"
	icon_state = "brig"

/area/laborcamp/atmosphericsequip
	name = "\improper Atmospherics Equipment"
	icon_state = "brig"

/area/laborcamp/yard
	name = "\improper Yard"
	icon_state = "brig"

/area/laborcamp/yardairlock
	name = "\improper Yard Airlock"
	icon_state = "brig"

/area/laborcamp/guardpostnorth
	name = "\improper Guard Post North"
	icon_state = "brig"

/area/laborcamp/guardpostsouth
	name = "\improper Guard Post South"
	icon_state = "brig"

/area/laborcamp/medical
	name = "\improper Medical Room"
	icon_state = "brig"

/area/laborcamp/recreation
	name = "\improper Recreation"
	icon_state = "brig"

/area/laborcamp/hallwaynorth
	name = "\improper North Wing"
	icon_state = "brig"

/area/laborcamp/hallwaysouth
	name = "\improper South Wing"
	icon_state = "brig"


// Away Missions
/area/awaymission
	name = "\improper Strange Location"
	icon_state = "away"

/area/awaymission/example
	name = "\improper Strange Station"
	icon_state = "away"

/area/awaymission/wwmines
	name = "\improper Wild West Mines"
	icon_state = "away1"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwgov
	name = "\improper Wild West Mansion"
	icon_state = "away2"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwrefine
	name = "\improper Wild West Refinery"
	icon_state = "away3"
	luminosity = 1
	requires_power = 0

/area/awaymission/wwvault
	name = "\improper Wild West Vault"
	icon_state = "away3"
	luminosity = 0

/area/awaymission/wwvaultdoors
	name = "\improper Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = 0
	luminosity = 0

/area/awaymission/desert
	name = "Mars"
	icon_state = "away"

/area/awaymission/BMPship1
	name = "\improper Aft Block"
	icon_state = "away1"

/area/awaymission/BMPship2
	name = "\improper Midship Block"
	icon_state = "away2"

/area/awaymission/BMPship3
	name = "\improper Fore Block"
	icon_state = "away3"

/area/awaymission/spacebattle
	name = "\improper Space Battle"
	icon_state = "away"
	requires_power = 0

/area/awaymission/spacebattle/cruiser
	name = "\improper Nanotrasen Cruiser"

/area/awaymission/spacebattle/syndicate1
	name = "\improper Syndicate Assault Ship 1"

/area/awaymission/spacebattle/syndicate2
	name = "\improper Syndicate Assault Ship 2"

/area/awaymission/spacebattle/syndicate3
	name = "\improper Syndicate Assault Ship 3"

/area/awaymission/spacebattle/syndicate4
	name = "\improper Syndicate War Sphere 1"

/area/awaymission/spacebattle/syndicate5
	name = "\improper Syndicate War Sphere 2"

/area/awaymission/spacebattle/syndicate6
	name = "\improper Syndicate War Sphere 3"

/area/awaymission/spacebattle/syndicate7
	name = "\improper Syndicate Fighter"

/area/awaymission/spacebattle/secret
	name = "\improper Hidden Chamber"

/area/awaymission/listeningpost
	name = "\improper Listening Post"
	icon_state = "away"
	requires_power = 0

// Admin Preperation area for events for use with the valan's ship
/area/adminprep/valansship
	name = "\improper valans shuttle"
	icon_state = "south"
	requires_power = 0
	lighting_use_dynamic = 0 // the ship doesn't have any lights
	environment = PLAIN

/area/adminprep/valansshiparrival
	name = "\improper valans shuttle arrival"
	icon_state = "south"
	requires_power = 0
	lighting_use_dynamic = 0 // the ship doesn't have any lights
	environment = PLAIN

// Asteroid fields - it's space really
/area/asteroidfields/asteroideva
	name = "\improper Pirate Asteroid eva"
	icon_state = "red"
	environment = HANGAR
	requires_power = 0

/area/asteroidfields/asteroidarea1
	name = "\improper Pirate Asteroid area1"
	icon_state = "bluenew"
	environment = STONE_CORRIDOR

/area/asteroidfields/asteroidcave
	name = "\improper Pirate Asteroid cave"
	icon_state = "purple"
	environment = CAVE

/area/asteroidfields/shuttle
	name = "\improper Pirate Asteroid shuttle area"
	icon_state = "south"
	lighting_use_dynamic = 0 // the ship doesn't have any lights
	environment = PLAIN

/area/planet
	base_turf = /turf/planet