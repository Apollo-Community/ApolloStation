#define SOLID 1
#define LIQUID 2
#define GAS 3
#define REAGENTS_OVERDOSE 30
#define REM REAGENTS_EFFECT_MULTIPLIER

/*
	Complex Reagents
	----------------

	Complex reagents are 'reagents' that are actually a composite of other different reagents, often in a solution. It allows for different alcohols like 'rum' to react as ethanol in some cases
	even whil registering as 'rum', having its own effects, etc. It's effectively just a reagent with reagents inside of it.

	Complex reagents will generally be stuff like blood, dna, mixed drinks, solutions, etcetera, where it isn't it's own chemical, but it is a compound reagent that it is better to have its own
	effects and stuff. Or when you want it to hide chemicals within itself. For example: A nutriment that scans as "nutriment" and mixes with other nutriments. But is actually verious
	mixtures of 'vitamin x' and 'mineral z'. Where nutriment + nutriment = 2 nutriment, but nutriment is just a common name for the individual, specific, chemicals within it.

	This prevents people from disecting different chemicals like blood or alcohol into its constituents by eyeballing it, but allows it in technologically advanced machines.
*/

/datum/reagent/complex_reagent
	name = "complex compound"
	id = "reagent_complex"
	description = "some ultra-complex compound. You can't tell what it's made of, or what it's used for. It doesn't even seem to do anything!"
	var/datum/reagents/reagents = new/datum/reagents(1)











/*
	Blood Stuff
	-----------
	Blood is a complex reagent usually made up of blood_plasma, red blood cells, platelets, and white blood cells.
	Human blood is about 44% rbc. 54% plasma, 1% wbc, and 1% platelets.

	RBC is in charge of antigens, and oxygen transportation.
	Plasma is in charge of storing and transporting nutrients and waste, as well as water.
	WBC is in charge of combatting contagions and viral infections.
	Platelets are in charge of stemming blood flow.




	Metabolism
	----------
	How i intend for the metabolism to work:
	Vitamins heal and make you healthy.
	Glycerin make you more energetic and faster.
	Sterolins feed you and make energy last longer.
	Water dillutes and sollutes everything. So that it gets absorbed more slowly, it also helps metabolize everything.
	Bicarbonates are waste. And are used for metabolizing nutriments, and exhaling as oxygen.

	Metabolism Cycle:
	Bicarbonate + HCl + Nutriment ->  Vitamin + Glucate + Sterolate + Water + CO2
	Water + Vitamin -> High Health + HCl
	Oxygen + Glycerin -> High Energy + Bicarbonate
	Water + Sterolin -> Low Energy + Low Health

	Being low on Vitamins will make you feel weak and slow.
	Being low on Sterolin will make you feel hungry and weak.
	Being low on Glycerin will make you feel tired and slow.
	Being low on Water will make you feel tired and thirsty.

	Being high on Vitamins will make you feel replenished and hardy.
	Being high on Sterolin will make you feel sated and hardy.
	Being high on Glycerin will make you feel energized and restless.
	Being high on Water will make you feel replenished and sated.

*/
/datum/reagent/complex_reagent/blood
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "95050F" // rgb: 200, 0, 0
	data = new/list("donor"=null,"viruses"=null,"species"="Human","blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","resistances"=null,"trace_chem"=null, "antibodies" = null)

	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"

/datum/reagent/complex_reagent/blood_plasma
	name = "Blood Plasma"
	id = "blood_plasma"
	description = "Mostly water, this is a compound found in the blood of most vertebrates used primarily for transporting nutrients and chemicals and generally everything else."
	color = "#C0A000" // This is based on the contents of the plasma. Which, seeing as they are primarily chlorine and water, is yellow.
	slippery = 5 // Still viscous, but not as viscous as the cells themselves. Is about 54 units in human blood.

	data = new/list("water"=90, "vitamin"=3, "glucate"=1, "bicarbonate"=5, "sterolin"=1)
	//=: Since Plasma is a complex reagent, it doesn't really need any data variables. The data variable is instead used to determine the bodies 'healthy' chemical counts in percentile amounts.
	//=: "Vitamin" is generalized vitamin proteins. It's metabolized from healthy foods and nutriments.
	//=: "Glycerin" is generalized energy proteins. It's metabolized from sugary foods and nutriments.
	//=: "Bicarbonate" is generalized waste proteins. It's metabolized from vitamins, sterolites, and glucates.
	//=: "Sterolin" is generalized fat and steroid proteins. It's metabolized from fatty foods and nutriments.

/datum/reagent
	erythrocyte
		name = "Erythrocyte" // I chose to call it "erythrocyte" because it doesnt specify that the blood is red. If you feel like 'red blood cell' sounds better, change it.
		id = "erythrocyte"
		description = "Also known as 'red blood cells' used primarily for transporting oxygen throughout the body."
		color = "95050F"
		slippery = -10 // Blood is sticky and viscous. Since about 44 units in human blood is erythrocyte, this should have a noticeable effect.
		alpha = 255

		data = new/list("oxygen_state"=0, "cell_dna"=null, "oxy_color"="F50915", "car_color"="350209", "health"=100, "resistance"=100, "type"=0)
			//=: Oxygen state, between -1 and 1. 0 being depleted. 1 being oxygenated. -1 is used for monoxide poisoning and stuff, which vastly reduces the rate of oxygen intake.
			//=: Cell DNA, this is a string of dna that replaces blood dna, and is used in generally all cell reagents for no reason whatsoever.
			//=: Oxy Color, this is the color of the reagent when it is fully oxygenated.
			//=: Car Color, this is the color of the reagent when it is fully carbonated.
			//=: Health, this is the health of the reagent. At poorer health, it will be less effective at carrying oxygen/waste.
			//=: Resistance, this is the cells tendency to resist damage, caused by mutation, disease, or viral attacks.
			//=: Blood Type, stored as a bitflag. Flags are: 0 = O, 1= A, 2 = B, 3= AB, 4= C, 8= D+. 16=X, allowing for 32 possible blood types. Generally, the higher the number, the more resistant the blood.

	blood_clot
		name = "Platelets"
		id = "blood_clot"
		description = "Affects healing, and blood clotting in mammals."
		color = "#000000" // Lets make them black.
		slippery = -50 // Very viscous. Only about 1 unit in a persons blood, so very little noticeable effect.

		data = new/list("speed"=600, "reduction"=50)
			//=: Speed affects the rate at which the platelets will form a clot over a wound. At 600, bleeding will stop after one minute on an average gash.
			//=: Reduction affects the rate of blood loss. At 1 unit of platelets, with a value of 50, blood loss is reduced by 50%. above 100%, problematic clotting may occur.

	leukocyte
		name = "Leukocyte"
		id = "leukocyte"
		description = "Also known as 'white blood cells', these primarily fight off infections and viruses in the blood."
		color = "#FFFFDD"
		slippery = 0

		data = new/list("cell_dna"=null,"strength"=10, "speed"=3000)
			//=: Cell DNA is a useless variable used for RP and forensics and stuff. I guess.
			//=: Strength is the amount of contagions the cell is able to neutralize before dying off.
			//=: Speed is the amount of time in-ticks it takes for the cell to neutralize a contagion.

	biomass
		name = "Biomass"
		id = "biomass"
		description = "A clump of living cells and tissue of no recognizeable origin."
		color = "A040FF"
		slippery = -10
		alpha = 220

			//=: This is what happens when you mix living tissues with 'clonexadone'. It's bioflesh!
			//=: Used for making specific organic compounds like red blood cells, or making stuff like synthflesh for surgery.

	necromass
		name = "Necromass"
		id = "necromass"
		description = "A clump of dead cells and tissue that has decomposed beyond recognition."
		color = "605040"
		slippery = -10
		alpha = 220

			//=: This is dead tissues. You get it from killing live ones. It's rotting flesh!
			//=: Used for being converted into nutriments or as a fuel. Occasionally used by the chef and botanists.

	thanatocyte
		name = "Thanatocyte"
		id = "thanatocyte"
		description = "A clump of dead cells and tissue showing some sort of post-mortem activity."
		color = "#555555"
		slippery = -10
		alpha = 220

			//=: This is what happens when you mix dead tissues with 'unknown compound'. It's zombieflesh!
			//=: Used for bringing people back from the dead? I only see bad uses for this at the moment. Which is fun!