//FIXME this should be customizable. But an interface for that would be tricky...

record PlantSuggestion
{
	location loc;
	string plant_name;
	string details;
    
    boolean no_stat_remove; //for +ML plants mainly
};

PlantSuggestion PlantSuggestionMake(location loc, string plant_name, string details)
{
	PlantSuggestion result;
	result.loc = loc;
	result.plant_name = plant_name;
	result.details = details;
	return result;
}


void listAppend(PlantSuggestion [int] list, PlantSuggestion entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


PlantSuggestion [int] __plants_suggested_locations;

record Plant
{
	string name;
	string image_lookup_name; //auto-generated
	string zone_effect;
	string terrain;
	boolean territorial;
};

Plant PlantMake(string name, string zone_effect, string terrain, boolean territorial)
{
	Plant result;
	result.name = name;
	result.image_lookup_name = "Plant " + name;
	result.zone_effect = zone_effect;
	result.terrain = terrain;
	result.territorial = territorial;
	return result;
}
Plant [string] __plant_properties;
string [int] __plant_output_order; //MUST contain all plants


void finalizeSetUpFloristState()
{
	if (!florist_available())
		return;
	
	//Set up suggestions:
	//We can have this as either plants keeping track of a bunch of locations, or locations keeping track of a bunch of plants.
	//Keeping it the same as get_florist_plants makes it mentally easier to track, I guess.
	
	
	__plant_properties["Rabid Dogwood"] = PlantMake("Rabid Dogwood", "+30 ML", "outdoor", true);
	__plant_properties["Rutabeggar"] = PlantMake("Rutabeggar", "+25% item", "outdoor", true);
	__plant_properties["Rad-ish Radish"] = PlantMake("Rad-ish Radish", "+5 moxie stats/fight", "outdoor", true);
	
	__plant_properties["War Lily"] = PlantMake("War Lily", "+30 ML", "indoor", true);
	__plant_properties["Stealing Magnolia"] = PlantMake("Stealing Magnolia", "+25% item", "indoor", true);
	__plant_properties["Canned Spinach"] = PlantMake("Canned Spinach", "+5 muscle stats/fight", "indoor", true);
	
	__plant_properties["Blustery Puffball"] = PlantMake("Blustery Puffball", "+30 ML", "underground", true);
	__plant_properties["Horn of Plenty"] = PlantMake("Horn of Plenty", "+25% item", "underground", true);
	__plant_properties["Wizard's Wig"] = PlantMake("Wizard's Wig", "+5 myst stats/fight", "underground", true);
	__plant_properties["Shuffle Truffle"] = PlantMake("Shuffle Truffle", "+25% init", "underground", false);
	
	
	__plant_output_order = split_string("Rabid Dogwood,Rutabeggar,Rad-ish Radish,Artichoker,Smoke-ra,Skunk Cabbage,Deadly Cinnamon,Celery Stalker,Lettuce Spray,Seltzer Watercress,War Lily,Stealing Magnolia,Canned Spinach,Impatiens,Spider Plant,Red Fern,BamBOO!,Arctic Moss,Aloe Guv'nor,Pitcher Plant,Blustery Puffball,Horn of Plenty,Wizard's Wig,Shuffle Truffle,Dis Lichen,Loose Morels,Foul Toadstool,Chillterelle,Portlybella,Max Headshroom,Spankton,Kelptomaniac,Crookweed,Electric Eelgrass,Duckweed,Orca Orchid,Sargassum,Sub-Sea Rose,Snori,Up Sea Daisy", ",");
    
	//Go through all potentials:
	boolean [string] plants_used;
	if (true)
	{
		string [int] internal_plants_used = split_string_alternate(get_property("_floristPlantsUsed"), ",");
		foreach key in internal_plants_used
			plants_used[internal_plants_used[key]] = true;
	}
	//Shuffle Truffle - underground, init:
	if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
    {
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled alcove], "Shuffle Truffle", "+2.5% modern zmobie"));
	}
	//Horn of Plenty - underground, +item:
	if (__quest_state["Level 7"].state_boolean["nook needs speed tricks"] && $location[the defiled nook].item_drop_modifier_for_location() < 400.0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled nook], "horn of plenty", "Evil eye, 20% drop."));
	}
	if (!__quest_state["Level 11"].finished && $location[the middle chamber].item_drop_modifier_for_location() < 400.0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the middle chamber], "horn of plenty", "Tomb ratchets, 20% drop."));
	}
	if (__quest_state["Level 4"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() < 3)
	{
        string description = "Sonars-in-a-biscuit, 15% drop.";
        if (!__quest_state["Level 7"].state_boolean["nook finished"]) //FIXME test if that plant is planted already
            description += " Or ignore in favor of the defiled nook?";
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the batrat and ratbat burrow], "horn of plenty", description));
	}
    //Intentionally ignored: +item plants in the orchard. Normally you'd plant in the upper chamber instead, since both of these quests often happen on the same day? And there's three zones to plant in - way too complicated.
	if (!__quest_state["Level 12"].finished && __misc_state["need to level"] && __quest_state["Level 12"].state_int["frat boys left on battlefield"] != 0 && __quest_state["Level 12"].state_int["hippies left on battlefield"] != 0)
	{
		location battlefield_zone = $location[the battlefield (hippy uniform)];
        if (__quest_state["Level 12"].state_int["frat boys left on battlefield"] > __quest_state["Level 12"].state_int["hippies left on battlefield"])
            battlefield_zone = $location[the battlefield (frat uniform)];
		if (my_primestat() == $stat[moxie])
			__plants_suggested_locations.listAppend(PlantSuggestionMake(battlefield_zone, "Rad-ish Radish", ""));
		else
			__plants_suggested_locations.listAppend(PlantSuggestionMake(battlefield_zone, "Rabid Dogwood", ""));
	}
	if (__misc_state["need to level mysticality"])
	{
		//Wizard's Wig - underground, +5 myst stats/fight:
        //in SC, can reach level 7 first, so ignore this one:
        //if (!__quest_state["Level 4"].finished)
            //__plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Boss Bat's Lair], "Wizard's Wig", ""));
        if (!__quest_state["Level 7"].state_boolean["niche finished"])
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Defiled Niche], "Wizard's Wig", ""));
	}
	//Blustery Puffball - underground, +ML:
	if (__quest_state["Level 7"].state_int["cranny evilness"] > 25 + 3)
	{
        PlantSuggestion ps = PlantSuggestionMake($location[the defiled cranny], "Blustery Puffball", "More beeps from swarm of ghuol whelps.");
        ps.no_stat_remove = true;
		__plants_suggested_locations.listAppend(ps);
	}
	//Canned Spinach - indoor, +5 muscle stats/fight:
    if (my_primestat() == $stat[muscle] && __misc_state["need to level"])
    {
        //castle?
        if ($item[Spookyraven gallery key].available_amount() > 0 && !__misc_state["Stat gain from NCs reduced"])
        {
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[the haunted gallery], "Canned Spinach", "While powerlevelling."));
        }
    }
	
	//Stealing Magnolia - indoor, +item:
	//The haunted ballroom, except they may be changing that?
    if (my_primestat() == $stat[moxie] && __misc_state["need to level"] && false) //disabled for now, not sure if it's a good idea or not
    {
        if (my_path_id() != PATH_CLASS_ACT_2)
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[the haunted ballroom], "Stealing Magnolia", "Dance cards from waltzers, for power leveling.")); //FIXME if stat changes in the future, remove this suggestion
        
	}
	//War Lily - indoor, +ML:
    if (__misc_state["need to level"])
    {
        __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The castle in the clouds in the sky (ground floor)], "War Lily", ""));
        //Haunted bedroom?
    }
	//Rad-ish Radish - outdoor, +5 moxie stats/fight:
    if (__misc_state["need to level moxie"])
    {
        //you wouldn't plant +30ML at airship - because oil peak likely needs it today. FIXME suggest if oil peak done/planted? HCO I guess? I dunno
        __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Spooky Forest], "Rad-ish Radish", ""));
        __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Penultimate Fantasy Airship], "Rad-ish Radish", ""));
    }
	//Rutabeggar - outdoor, +item:
	if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[a-boo peak], "Rutabeggar", "A-boo clue, 15% drop."));
	}
	
	//Rabid Dogwood - outdoor, +ML:
	if (__quest_state["Level 9"].state_float["oil peak pressure"] > 0 && monster_level_adjustment() < 100)
    {
        PlantSuggestion ps = PlantSuggestionMake($location[oil peak], "Rabid Dogwood", "");
        ps.no_stat_remove = true;
		__plants_suggested_locations.listAppend(ps);
    }
	if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && __misc_state["need to level"]) //you spend a lot of turns in the desert
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the arid, extra-dry desert], "Rabid Dogwood", ""));
	
	//Now, go through results, and remove all plants that are already in that location:
	
	string [location][int] current_plants = get_florist_plants();
	boolean [location][string] current_plants_used; //inverse of current_plants, used for quick searching
	foreach l in current_plants
	{
		foreach key in current_plants[l]
		{
			string plant = current_plants[l][key];
			current_plants_used[l][plant] = true;
		}
	}
	
	int [int] keys_removing;
	foreach key in __plants_suggested_locations
	{
		PlantSuggestion suggestion = __plants_suggested_locations[key];
        
        boolean should_remove = false;
		if (current_plants_used[suggestion.loc][suggestion.plant_name] || plants_used[suggestion.plant_name])
		{
			should_remove = true;
		}
        else
        {
            if (suggestion.plant_name == "Rad-ish Radish" || suggestion.plant_name == "Canned Spinach" || suggestion.plant_name == "Wizard's Wig") //+stat plants
            {
                boolean area_has_ml_plant = false;
                if (current_plants_used[suggestion.loc]["Rabid Dogwood"])
                    area_has_ml_plant = true;
                if (current_plants_used[suggestion.loc]["War Lily"])
                    area_has_ml_plant = true;
                if (current_plants_used[suggestion.loc]["Blustery Puffball"])
                    area_has_ml_plant = true;
                if (area_has_ml_plant)
                    should_remove = true;
            }
            
            //opposite:
            if (suggestion.plant_name == "Rabid Dogwood" || suggestion.plant_name == "War Lily" || suggestion.plant_name == "Blustery Puffball")
            {
                boolean area_has_stat_plant = false;
                if (current_plants_used[suggestion.loc]["Rad-ish Radish"])
                    area_has_stat_plant = true;
                if (current_plants_used[suggestion.loc]["Canned Spinach"])
                    area_has_stat_plant = true;
                if (current_plants_used[suggestion.loc]["Wizard's Wig"])
                    area_has_stat_plant = true;
                if (area_has_stat_plant && !suggestion.no_stat_remove)
                    should_remove = true;
            }
            
        }
        
        if (should_remove)
            keys_removing.listAppend(key);
	}
	foreach key in keys_removing
	{
		remove __plants_suggested_locations[keys_removing[key]];
	}
}

void generateFloristFriar(Checklist [int] checklists)
{
	if (!florist_available())
		return;
    if (!__misc_state["In run"]) //currently, these suggestions are in-run only
        return;
	ChecklistEntry [int] florist_entries;
	
    ChecklistSubentry [int] subentries;
	foreach key in __plant_output_order
	{
		string plant_name = __plant_output_order[key];
		if (!(__plant_properties contains plant_name))
			continue;
		Plant plant = __plant_properties[plant_name];
		
		ChecklistSubentry subentry;
		subentry.header = plant_name + ", " + plant.terrain;
		subentry.modifiers.listAppend(plant.zone_effect);
		
		//See if we suggested this plant anywhere:
		foreach key in __plants_suggested_locations
		{
			PlantSuggestion suggestion = __plants_suggested_locations[key];
			if (suggestion.plant_name == plant_name)
			{
				//we did
				string suggestion_text = suggestion.loc;
				if (suggestion.details != "")
					suggestion_text += " (" + suggestion.details + ")";
				if (!locationAvailable(suggestion.loc))
					subentry.entries.listAppend(HTMLGenerateSpanOfClass(suggestion_text, "r_future_option"));
				else
					subentry.entries.listAppend(suggestion_text);
			}
		}
        
        string image_name = plant.image_lookup_name;
		if (subentry.entries.count() > 0)
        {
            if (false)
                florist_entries.listAppend(ChecklistEntryMake(image_name, "place.php?whichplace=forestvillage&amp;action=fv_friar", subentry));
            else
                subentries.listAppend(subentry);
        }
	}
    if (subentries.count() > 0)
    {
        florist_entries.listAppend(ChecklistEntryMake("plant up sea daisy", "place.php?whichplace=forestvillage&amp;action=fv_friar", subentries));
    }
	
	checklists.listAppend(ChecklistMake("Florist Friar", florist_entries));
}

//Does not return color formatting for elemental damage; will need to add that yourself.
string getPlantDescription(string plant_name)
{
    switch (plant_name)
    {
        case "Rabid Dogwood":
        case "War Lily":
        case "Blustery Puffball":
            return "+30 ML";
        case "Rutabeggar":
        case "Stealing Magnolia":
        case "Horn of Plenty":
            return "+25% item";
        case "Aloe Guv'nor":
            return "HP regen";
        case "Artichoker":
            return "delevel";
        case "Canned Spinach":
            return "5 muscle/fight";
        case "Crookweed":
            return "+60% meat";
        case "Dis Lichen":
            return "delevel";
        case "Duckweed":
            return "hiding";
        case "Electric Eelgrass":
            return "block";
        case "Impatiens":
            return "+25% init";
        case "Kelptomaniac":
            return "+40% item";
        case "Lettuce Spray":
            return "HP regen";
        case "Max Headshroom":
            return "MP regen";
        case "Orca Orchid":
            return "attack";
        case "Pitcher Plant":
            return "MP regen";
        case "Portlybella":
            return "HP regen";
        case "Rad-ish Radish":
            return "5 moxie/fight";
        case "Red Fern":
            return "delevel";
        case "Seltzer Watercress":
            return "MP regen";
        case "Shuffle Truffle":
            return "+25% init";
        case "Smoke-ra":
            return "block";
        case "Snori":
            return "HP/MP regen";
        case "Spankton":
            return "delevel";
        case "Spider Plant":
            return "poison";
        case "Up Sea Daisy":
            return "30 stats/fight";
        case "Wizard's Wig":
            return "5 myst/fight";
        case "Arctic Moss":
        case "Sub-Sea Rose":
        case "Chillterelle":
            return "cold attack";
        case "Celery Stalker":
        case "BamBOO!":
            return "spooky attack";
        case "Deadly Cinnamon":
            return "hot attack";
        case "Loose Morels":
            return "sleaze attack";
        case "Sargassum":
        case "Skunk Cabbage":
        case "Foul Toadstool":
            return "stench attack";
    }
    return "";
}