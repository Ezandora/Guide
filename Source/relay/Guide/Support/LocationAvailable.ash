//Library for checking if any given location is unlocked.
//Similar to canadv.ash, except there's no code for using items and no URLs are (currently) visited. This limits our accuracy.
//Currently, most locations are missing, sorry.
import "relay/Guide/Support/Error.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Support/Library.ash"

boolean [location] __la_location_is_available;

boolean __la_commons_were_inited = false;
int __la_turncount_initialized_on = -1;

boolean locationQuestPropertyPastInternalStepNumber(string quest_property, int number)
{
	return QuestStateConvertQuestPropertyValueToNumber(get_property(quest_property)) >= number;
}

//Do not call - internal implementation detail.
boolean locationAvailablePrivateCheck(location loc, Error able_to_find)
{
	string zone = loc.zone;
	
	if (zone == "KOL High School")
	{
		if (my_path_id() == PATH_KOLHS)
			return true;
		return false;
	}
	if (zone == "Mothership")
	{
		if (my_path_id() == PATH_BUGBEAR_INVASION)
			return true;
		return false;
	}
	if (zone == "BadMoon")
	{
		if (in_bad_moon())
			return true;
		return false;
	}
	
	switch (loc)
	{
		case $location[The Castle in the Clouds in the Sky (Ground floor)]:
			return get_property_int("lastCastleGroundUnlock") == my_ascensions();
		case $location[The Castle in the Clouds in the Sky (Top floor)]:
			return get_property_int("lastCastleTopUnlock") == my_ascensions();
		case $location[The Haunted Kitchen]:
		case $location[The Haunted Conservatory]:
		case $location[The Haunted Billiards Room]:
            if ($item[spookyraven library key].available_amount() > 0 || $item[spookyraven ballroom key].available_amount() > 0)
                return true;
			return get_property_int("lastManorUnlock") == my_ascensions();
		case $location[The Haunted Bedroom]:
		case $location[The Haunted Bathroom]:
            if ($item[spookyraven ballroom key].available_amount() > 0)
                return true;
			return get_property_int("lastSecondFloorUnlock") == my_ascensions();
		case $location[cobb's knob barracks]:
		case $location[cobb's knob kitchens]:
		case $location[cobb's knob harem]:
		case $location[cobb's knob treasury]:
			string quest_value = get_property("questL05Goblin");
			if (quest_value == "finished")
				return true;
			else if (quest_value == "started") //FIXME locationQuestPropertyPastInternalStepNumber
			{
				//Inference - quest is started. If map is missing, area must be unlocked
				if ($item[cobb's knob map].available_amount() > 0)
					return false;
				else //no map, must be available
					return true;
			}
			//unstarted, impossible
            return false;
		case $location[Vanya's Castle Chapel]:
			if ($item[map to Vanya's Castle].available_amount() > 0)
				return true;
			return false;
		case $location[the hidden park]:
			return locationQuestPropertyPastInternalStepNumber("questL11Worship", 4);
        case $location[the hidden temple]:
            return (get_property_int("lastTempleUnlock") == my_ascensions());
		case $location[the spooky forest]:
			return locationQuestPropertyPastInternalStepNumber("questL02Larva", 1);
		case $location[The Smut Orc Logging Camp]:
			return locationQuestPropertyPastInternalStepNumber("questL09Topping", 1);
		case $location[guano junction]:
			return locationQuestPropertyPastInternalStepNumber("questL04Bat", 1);
		case $location[itznotyerzitz mine]:
			return locationQuestPropertyPastInternalStepNumber("questL08Trapper", 2);
        case $location[the arid, extra-dry desert]:
			return (locationQuestPropertyPastInternalStepNumber("questL11MacGuffin", 3) || $item[your father's MacGuffin diary].available_amount() > 0);
        case $location[the oasis]:
			return (get_property_int("desertExploration") > 0) && (locationQuestPropertyPastInternalStepNumber("questL11MacGuffin", 3) || $item[your father's MacGuffin diary].available_amount() > 0);
        case $location[the defiled alcove]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptAlcoveEvilness") > 0;
        case $location[the defiled cranny]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptCrannyEvilness") > 0;
        case $location[the defiled niche]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptNicheEvilness") > 0;
        case $location[the defiled nook]:
			return locationQuestPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptNookEvilness") > 0;
            
		case $location[south of the border]:
			return $items[pumpkin carriage,desert bus pass, bitchin' meatcar, tin lizzie].available_amount() > 0;
		default:
			break;
	}
    if (loc.turnsAttemptedInLocation() > 0) //FIXME make this finer-grained, this is hacky
        return true;
	
	ErrorSet(able_to_find, "");
	return false;
}

void locationAvailablePrivateInit()
{
	if (__la_commons_were_inited && __la_turncount_initialized_on == my_turncount())
		return;
        
    if (__la_location_is_available.count() > 0)
    {
        foreach key in __la_location_is_available
        {
            remove __la_location_is_available[key];
        }
    }
	
	boolean [location] locations_always_available = $locations[the haunted pantry,the sleazy back alley,the outskirts of cobb's knob,the limerick dungeon,The Haiku Dungeon,The Daily Dungeon];
	foreach loc in locations_always_available
	{
		if (loc == $location[none])
			continue;
		__la_location_is_available[loc] = true;
	}
		
	string zones_never_accessible_string = "Gyms,Crimbo06,Crimbo07,Crimbo08,Crimbo09,Crimbo10,The Candy Diorama,Crimbo12,WhiteWed";
	
	item [location] locations_unlocked_by_item;
	effect [location] locations_unlocked_by_effect;
	
	item [string] zones_unlocked_by_item;
	effect [string] zones_unlocked_by_effect;
	
	locations_unlocked_by_item[$location[Cobb's Knob Menagerie\, Level 1]] = $item[Cobb's Knob Menagerie key];
	locations_unlocked_by_item[$location[Cobb's Knob Menagerie\, Level 2]] = $item[Cobb's Knob Menagerie key];
	locations_unlocked_by_item[$location[Cobb's Knob Menagerie\, Level 3]] = $item[Cobb's Knob Menagerie key];
	
	locations_unlocked_by_item[$location[the haunted ballroom]] = $item[spookyraven ballroom key];
	locations_unlocked_by_item[$location[The Haunted Library]] = $item[spookyraven library key];
	locations_unlocked_by_item[$location[The Haunted Gallery]] = $item[spookyraven gallery key];
	locations_unlocked_by_item[$location[The Castle in the Clouds in the Sky (Basement)]] = $item[S.O.C.K.];
	locations_unlocked_by_item[$location[the hole in the sky]] = $item[steam-powered model rocketship];
	
	locations_unlocked_by_item[$location[Vanya's Castle Foyer]] = $item[map to Vanya's Castle];
	
	
	zones_unlocked_by_item["Magic Commune"] = $item[map to the Magic Commune];
	zones_unlocked_by_item["Landscaper"] = $item[Map to The Landscaper's Lair];
	zones_unlocked_by_item["Kegger"] = $item[map to the Kegger in the Woods];
	zones_unlocked_by_item["Ellsbury's Claim"] = $item[Map to Ellsbury's Claim];
	zones_unlocked_by_item["Memories"] = $item[empty agua de vida bottle];
	zones_unlocked_by_item["Casino"] = $item[casino pass];
	
	zones_unlocked_by_effect["Astral"] = $effect[Half-Astral];
	zones_unlocked_by_effect["Spaaace"] = $effect[Transpondent];
	zones_unlocked_by_effect["RabbitHole"] = $effect[Down the Rabbit Hole];
	zones_unlocked_by_effect["Wormwood"] = $effect[Absinthe-Minded];	
	zones_unlocked_by_effect["Suburbs"] = $effect[Dis Abled];
	
	string [int] zones_never_accessible = split_string_mutable(zones_never_accessible_string, ",");
	
	boolean [string] zone_accessibility_status = zones_never_accessible.listGeneratePresenceMap();
	
	
	foreach loc in $locations[Shivering Timbers,A Skeleton Invasion!,The Cannon Museum,A Swarm of Yeti-Mounted Skeletons,The Bonewall,A Massive Flying Battleship,A Supply Train,The Bone Star,Grim Grimacite Site,A Pile of Old Servers,The Haunted Sorority House,Fightin' Fire,Super-Intense Mega-Grassfire,Fierce Flying Flames,Lord Flameface's Castle Entryway,Lord Flameface's Castle Belfry,Lord Flameface's Throne Room,A Stinking Abyssal Portal,A Scorching Abyssal Portal,A Terrifying Abyssal Portal,A Freezing Abyssal Portal,An Unsettling Abyssal Portal,A Yawning Abyssal Portal,The Space Odyssey Discotheque,The Spirit World]
	{
		__la_location_is_available[loc] = false;
	}
	
	foreach loc in locations_unlocked_by_item
	{
		if (locations_unlocked_by_item[loc].available_amount() > 0)
			__la_location_is_available[loc] = true;
		else
			__la_location_is_available[loc] = false;
	}
	foreach loc in locations_unlocked_by_effect
	{
		if (locations_unlocked_by_effect[loc].have_effect() > 0)
			__la_location_is_available[loc] = true;
		else
			__la_location_is_available[loc] = false;
	}
	
	foreach zone in zones_unlocked_by_item
	{
		if (zones_unlocked_by_item[zone].available_amount() > 0)
			zone_accessibility_status[zone] = true;
		else
			zone_accessibility_status[zone] = false;
	}
	foreach zone in zones_unlocked_by_effect
	{
		if (zones_unlocked_by_effect[zone].have_effect() > 0)
			zone_accessibility_status[zone] = true;
		else
			zone_accessibility_status[zone] = false;
	}
	
	
	
	
	
	foreach loc in $locations[]
	{
		if (zone_accessibility_status contains (loc.zone))
			__la_location_is_available[loc] = zone_accessibility_status[loc.zone];
	}
		
		
	__la_commons_were_inited = true;
    __la_turncount_initialized_on = my_turncount();
}

boolean locationAvailable(location loc, Error able_to_find)
{
    locationAvailablePrivateInit();
	if ((__la_location_is_available contains loc))
		return __la_location_is_available[loc];
	
	boolean [int] could_find;
	boolean is_available = locationAvailablePrivateCheck(loc, able_to_find);
	if (able_to_find.was_error)
		return false;
	__la_location_is_available[loc] = is_available;
	
	return is_available;
}

boolean locationAvailable(location loc)
{
	return locationAvailable(loc, ErrorMake());
}


void locationAvailableRunDiagnostics()
{
	location [string][int] unknown_locations_by_zone;
	
	foreach loc in $locations[]
	{
		Error able_to_find;
		locationAvailable(loc, able_to_find);
		if (!able_to_find.was_error)
			continue;
		if (!(unknown_locations_by_zone contains (loc.zone)))
			unknown_locations_by_zone[loc.zone] = listMakeBlankLocation();
		unknown_locations_by_zone[loc.zone].listAppend(loc);
	}
	if (unknown_locations_by_zone.count() > 0)
	{
		print("Unknown locations in location availability tester:");
		foreach zone in unknown_locations_by_zone
		{
			print(zone + ":");
			foreach key in unknown_locations_by_zone[zone]
			{
				location loc = unknown_locations_by_zone[zone][key];
				print("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + loc);
			}
		}
	}
}

string HTMLGenerateFutureTextByLocationAvailability(string base_text, location place)
{
    if (!locationAvailable(place) && place != $location[none])
    {
        base_text = HTMLGenerateSpanOfClass(base_text, "r_future_option");
    }
    return base_text;
}

string HTMLGenerateFutureTextByLocationAvailability(location place)
{
	return HTMLGenerateFutureTextByLocationAvailability(place.to_string(), place);
}



string [location] __urls_for_locations;
boolean __urls_for_locations_initialized = false;

string getClickableURLForLocation(location l)
{
    if (!__urls_for_locations_initialized)
    {
        foreach l in $locations[The Beanbat Chamber, the bat hole entrance, the batrat and ratbat burrow, guano junction, the boss bat's lair]
            __urls_for_locations[l] = "place.php?whichplace=bathole";
        foreach l in $locations[the \"fun\" house, pre-cyrpt cemetary, post-cyrpt cemetary,The Outskirts of Cobb's Knob]
            __urls_for_locations[l] = "place.php?whichplace=plains";
        
        if ($location[cobb's knob barracks].locationAvailable())
            __urls_for_locations[$location[The Outskirts of Cobb's Knob]] = "cobbsknob.php";
        
        foreach l in $locations[cobb's knob barracks, cobb's knob kitchens, cobb's knob harem, cobb's knob treasury]
            __urls_for_locations[l] = "cobbsknob.php";
        __urls_for_locations[$location[a barroom brawl]] = "tavern.php";
        __urls_for_locations[$location[the sleazy back alley]] = "place.php?whichplace=town_wrong";
        
        foreach l in $locations[the spooky forest, whitey's grove, the road to white citadel, the black forest, the hidden temple]
            __urls_for_locations[l] = "place.php?whichplace=woods";
            
        if ($location[cobb's knob kitchens].locationAvailable())
            __urls_for_locations[$location[The Haunted Pantry]] = "place.php?whichplace=spookyraven1";
        else
            __urls_for_locations[$location[The Haunted Pantry]] = "place.php?whichplace=town_right";
            
            
        foreach l in $locations[The Oasis, the arid\, extra-dry desert, south of the border, The Shore\, Inc. Travel Agency]
            __urls_for_locations[l] = "place.php?whichplace=desertbeach";
        __urls_for_locations[$location[The Smut Orc Logging Camp]] = "place.php?whichplace=orc_chasm";
        foreach l in $locations[the haunted wine cellar (northwest), the haunted wine cellar (southwest), the haunted wine cellar (northeast), the haunted wine cellar (southeast)]
            __urls_for_locations[l] = "manor3.php";
        foreach l in $locations[the castle in the clouds in the sky (basement), the castle in the clouds in the sky (ground floor), the castle in the clouds in the sky (top floor)]
            __urls_for_locations[l] = "place.php?whichplace=giantcastle";
            
        foreach l in $locations[the haunted gallery, the haunted billiards room, the haunted library, the haunted conservatory, the haunted kitchen]
            __urls_for_locations[l] = "place.php?whichplace=spookyraven1";
            
        foreach l in $locations[the haunted bedroom, the haunted ballroom, the haunted bathroom]
            __urls_for_locations[l] = "place.php?whichplace=spookyraven2";
            
            
        foreach l in $locations[the hidden apartment building, the hidden hospital, the hidden office building, the hidden bowling alley, the hidden park]
            __urls_for_locations[l] = "place.php?whichplace=hiddencity";
            
        foreach l in $locations[the extreme slope, the icy peak, lair of the ninja snowmen, the goatlet, itznotyerzitz mine]
            __urls_for_locations[l] = "place.php?whichplace=mclargehuge";
            
            
        foreach l in $locations[the poop deck, Barrrney's Barrr, the f'c'le, belowdecks]
            __urls_for_locations[l] = "place.php?whichplace=cove";
        foreach l in $locations[the penultimate fantasy airship,the hole in the sky]
            __urls_for_locations[l] = "place.php?whichplace=beanstalk";
            
        foreach l in $locations[the haiku dungeon, the limerick dungeon, the dungeons of doom, the enormous greater-than sign, the daily dungeon]
            __urls_for_locations[l] = "da.php";

        __urls_for_locations[$location[Anger Man's Level]] = "place.php?whichplace=junggate_3";
        if ($effect[Absinthe-Minded].have_effect() > 0)
        {
            foreach l in $locations[The Stately Pleasure Dome, the mouldering mansion, the rogue windmill]
                __urls_for_locations[l] = "place.php?whichplace=wormwood";
        }
        else
        {
            foreach l in $locations[The Stately Pleasure Dome, the mouldering mansion, the rogue windmill]
                __urls_for_locations[l] = "mall.php";
        }
        
        foreach l in $locations[chinatown shops, chinatown tenement, triad factory,1st floor\, shiawase-mitsuhama building,2nd floor\, shiawase-mitsuhama building,3rd floor\, shiawase-mitsuhama building]
            __urls_for_locations[l] = "place.php?whichplace=junggate_1";
        
        if ($effect[down the rabbit hole].have_effect() > 0)
            __urls_for_locations[$location[The Red Queen's Garden]] = "place.php?whichplace=rabbithole";
        else
            __urls_for_locations[$location[The Red Queen's Garden]] = "mall.php";
            
        if ($effect[Shape of...Mole!].have_effect() > 0)
            __urls_for_locations[$location[Mt. Molehill]] = "mountains.php";
        else
            __urls_for_locations[$location[Mt. Molehill]] = "mall.php";
        
        foreach l in $locations[the primordial soup, the jungles of ancient loathing, seaside megalopolis]
            __urls_for_locations[l] = "place.php?whichplace=memories";
            
        foreach l in $locations[domed city of ronaldus,domed city of grimacia,hamburglaris shield generator]
        {
            if ($effect[Transpondent].have_effect() > 0)
                __urls_for_locations[l] = "place.php?whichplace=spaaace";
            else
                __urls_for_locations[l] = "mall.php";
        }
            
        foreach l in $locations[the degrassi knoll restroom, the degrassi knoll bakery, the degrassi knoll gym, the degrassi knoll garage]
        {
            if (knoll_available())
                __urls_for_locations[l] = "place.php?whichplace=knoll_friendly";
            else
                __urls_for_locations[l] = "place.php?whichplace=knoll_hostile";
        }
        __urls_for_locations_initialized = true;
    }
    
    if (__urls_for_locations contains l)
        return __urls_for_locations[l];
    return "";
}