//FIXME this should be customizable. But an interface for that would be tricky...

record PlantSuggestion
{
	location loc;
	string plant_name;
	string details;
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
		string [int] internal_plants_used = split_string(get_property("_floristPlantsUsed"), ",");
		foreach key in internal_plants_used
			plants_used[internal_plants_used[key]] = true;
	}
	//Shuffle Truffle - underground, init:
	if (!(__quest_state["Level 7"].state_boolean["alcove finished"] || __quest_state["Level 7"].state_int["alcove evilness"] < 27))
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled alcove], "Shuffle Truffle", "+2.5% modern zmobie"));
	}
	//Horn of Plenty - underground, +item:
	if (!__quest_state["Level 7"].state_boolean["nook finished"] && item_drop_modifier() < 400.0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled nook], "horn of plenty", "Evil eye, 20% drop."));
	}
	if (!__quest_state["Level 11"].finished && item_drop_modifier() < 400.0)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the upper chamber], "horn of plenty", "Tomb ratchets, 20% drop."));
	}
	if (__quest_state["Level 4"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() < 3)
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the batrat and ratbat burrow], "horn of plenty", "Sonars-in-a-biscuit, 15% drop."));
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
	if (my_primestat() == $stat[mysticality] && __misc_state["need to level"])
	{
		//Wizard's Wig - underground, +5 myst stats/fight:
        if (!__quest_state["Level 4"].finished)
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Boss Bat's Lair], "Wizard's Wig", ""));
        if (!__quest_state["Level 7"].state_boolean["niche finished"])
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[The Defiled Niche], "Wizard's Wig", ""));
	}
	//Blustery Puffball - underground, +ML:
	if (!__quest_state["Level 7"].state_boolean["cranny finished"])
	{
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[the defiled cranny], "Blustery Puffball", "More beeps from swarm of ghuol whelps."));
	}
	//Canned Spinach - indoor, +5 muscle stats/fight:
    if (my_primestat() == $stat[muscle] && __misc_state["need to level"])
    {
        //let's see... castle?
        if ($item[Spookyraven gallery key].available_amount() > 0 && !__misc_state["Stat gain from NCs reduced"])
        {
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[the haunted gallery], "Canned Spinach", "While powerlevelling."));
        }
    }
	
	//Stealing Magnolia - indoor, +item:
	//The haunted ballroom, except they may be changing that?
    if (my_primestat() == $stat[moxie] && __misc_state["need to level"])
    {
        //let's see... castle?
        if (my_path_id() != PATH_CLASS_ACT_2)
            __plants_suggested_locations.listAppend(PlantSuggestionMake($location[the haunted ballroom], "Stealing Magnolia", "Dance cards from waltzers, for power leveling.")); //FIXME if stat changes in the future, remove this suggestion
        
	}
	//War Lily - indoor, +ML:
	//Rad-ish Radish - outdoor, +5 moxie stats/fight:
    if (my_primestat() == $stat[moxie] && __misc_state["need to level"])
    {
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
		__plants_suggested_locations.listAppend(PlantSuggestionMake($location[oil peak], "Rabid Dogwood", ""));
    }
	if (!__quest_state["Level 11 Pyramid"].state_boolean["Desert Explored"] && __misc_state["need to level"]) //you spend a lot of turns in the desert
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
		if (current_plants_used[suggestion.loc][suggestion.plant_name] || plants_used[suggestion.plant_name])
		{
			keys_removing.listAppend(key);
		}
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