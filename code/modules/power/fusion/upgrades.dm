/datum/fusionUpgradeTable
	var/list/rod = list()
	var/list/crystal = list()
	var/list/rod_color = list()
	var/list/gas_color = list()
	var/maxfuel = 360

/datum/fusionUpgradeTable/New()
	rod = list(\
	"iron"				= 0.0,\
	"sandstone brick" 	= 0.1,\
	"Plastic"			= 0.2,\
	"platinum"			= 0.4,\
	"solid phoron" 		= 0.8,\
	"silver" 			= 1.6,\
	"gold"				= 3.2,\
	"osmium"			= 6.4,\
	"diamond"			= 12.8,\
	"tritium"			= 25.6)

	rod_color = list(\
	"iron"				= "#0067FF",\
	"solid phoron" 		= "#00ccff",\
	"silver" 			= "#ffff00",\
	"gold"				= "#00ff00",\
	"platinum" 			= "#a31aff",\
	"osmium"			= "#ff00ff",\
	"diamond"			= "#ff3300",\
	"tritium"			= "#8f29ce")

	crystal = list(\
	"iron"				= 0.0,\
	"sandstone brick" 	= 0.1,\
	"Plastic"			= 0.2,\
	"platinum"			= 0.3,\
	"solid phoron" 		= 0.4,\
	"silver" 			= 0.6,\
	"gold"				= 1.2,\
	"osmium"			= 3.0,\
	"diamond"			= 6.0,\
	"tritium"			= 12.8)

	gas_color = list(\
	"phoron" 			= "#b30059",\
	"nitrogen" 			= "#b30059",\
	"oxygen"			= "#009900",\
	"carbon_dioxide" 	= "#ff0000",\
	"sleeping_agent"	= "#ff9900")

//Neutron & heat upgrade
/datum/fusionUpgradeTable/proc/rod_coef(obj/item/weapon/neutronRod/rod)
	return src.rod[rod.mineral]

//Returns a color asosiated with a rod
/datum/fusionUpgradeTable/proc/rod_color(obj/item/weapon/neutronRod/rod)
	return src.rod_color[rod.mineral]

//Field upgrade
/datum/fusionUpgradeTable/proc/field_coef(obj/item/weapon/shieldCrystal/crystal)
	return src.crystal[crystal.mineral]

//Mixes gass into color (SO UGLY NEEDS FOR LOOPING)
/datum/fusionUpgradeTable/proc/gas_color(datum/gas_mixture/plasma, base_color)
	//var/tmp/phoron = plasma.gas["phoron"]/maxfuel
	var/tmp/nitrogen = plasma.gas["nitrogen"]/maxfuel
	var/tmp/oxygen = plasma.gas["oxygen"]/maxfuel
	var/tmp/carbon_dioxide = plasma.gas["carbon_dioxide"]/maxfuel
	var/tmp/sleeping_agent = plasma.gas["sleeping_agent"]/maxfuel

	//base_color = BlendRGB(base_color, src.gas_color["phoron"], phoron)
	base_color = BlendRGB(base_color, src.gas_color["nitrogen"], nitrogen)
	base_color = BlendRGB(base_color, src.gas_color["oxygen"], oxygen)
	base_color = BlendRGB(base_color, src.gas_color["carbon_dioxide"], carbon_dioxide)
	base_color = BlendRGB(base_color, src.gas_color["sleeping_agent"], sleeping_agent)
	return base_color


//Coefs on the fusion event determening heat, neutron, conversion rate, and fuel coefs
/datum/fusionUpgradeTable/proc/gas_coef(datum/gas_mixture/plasma, nr_corners)
	//maxfuel = maxfuel*nr_corners
	//Gas propeties:
	//Phoron - Basic fuel need at least 120 moles for 100% reactivity
	//Nitrogen - Shield vitalizer, enhance shield regen rate
	//Oxygen - Neutron releaser.
	//CarbonDioxide	- Heat absorver, neutron releaser.
	//Nitrous Oxide - Neutron obsorber, heat releaser.
	var/fuel_coef = Clamp(plasma.gas["phoron"]/(maxfuel/2), 0, 2)	//120 moles are needed for full reactivity
	var/dampening = 1 //1 - Clamp(plasma.gas["nitrogen"]/100, 0, 1) - Depreciated
	var/neutron_coef = 1 + Clamp(plasma.gas["oxygen"]/maxfuel, 0, 1)
	var/heat_neutron_coef = plasma.gas["carbon_dioxide"]/maxfuel*2
	var/neutron_heat_coef = plasma.gas["sleeping_agent"]/maxfuel
	var/shield_coef = 1 + Clamp(plasma.gas["nitrogen"]/(maxfuel*2), 0 ,1)
	var/explosive = 0
	if(plasma.gas["phoron"] > 0 && plasma.gas["oxygen"] > 0)
		explosive = 1
	if(plasma.gas["carbon_dioxide"] > 0)
		explosive = 0

	var/list/gas_coefs = list(\
	"fuel" = fuel_coef,\
	"dampening" = dampening,\
	"neutron" = neutron_coef,\
	"shield" = shield_coef,\
	"heat_neutron" = heat_neutron_coef,\
	"neutron_heat" = neutron_heat_coef,\
	"explosive" = explosive\
	)
	return gas_coefs

//Upgrade items for the fusion reactor
//The rod has an effect on heat/neutron production.
/obj/item/weapon/neutronRod
	name = "Neutron Focusing Rod"
	desc = " neutron absorbtion rod."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "smes_coil"			// Just few icons patched together. If someone wants to make better icon, feel free to do so!
	w_class = 4.0 						// It's LARGE (backpack size)
	var/mineral = "iron"

//The crystal has an effect on the decay/strengh of plasma/shields
/obj/item/weapon/shieldCrystal
	name = "Field Amplification Crystal"
	desc = " field amplification crystal."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "ansible_crystal"			// Just few icons patched together. If someone wants to make better icon, feel free to do so!
	w_class = 4.0 						// It's LARGE (backpack size)
	var/mineral = "iron"