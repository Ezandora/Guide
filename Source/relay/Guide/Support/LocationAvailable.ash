//Library for checking if any given location is unlocked.
//Similar to canadv.ash, except there's no code for using items and no URLs are (currently) visited. This limits our accuracy.
//Currently, most locations are missing, sorry.
import "relay/Guide/Support/Error.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Support/Library.ash"


//Version compatibility locations:
location __location_palindome;

boolean __location_compatibility_inited = false;
//Should probably be called manually, as a backup:
void locationCompatibilityInit()
{
    //Different versions refer to locations by different names.
    //For instance, pre-13878 versions refer to the palindome as "The Palindome". Versions after that refer it to "Inside the Palindome".
    //This method provides correct lookups for both versions, without warnings.
    if (__location_compatibility_inited)
        return;
    __location_compatibility_inited = true;
    
    __location_palindome = "Inside the Palindome".to_location();
    if (__location_palindome == $location[none])
        __location_palindome = "The Palindome".to_location();
}

locationCompatibilityInit(); //not sure if calling functions like this is intended. may break in the future?

boolean [location] __la_location_is_available;

boolean __la_commons_were_inited = false;
int __la_turncount_initialized_on = -1;


//Takes into account banishes and olfactions.
//Probably will be inaccurate in many corner cases, sorry.
float [monster] appearance_rates_adjusted(location l)
{
    //FIXME domed city of ronald/grimacia doesn't take into account alien appearance rate
    float [monster] source = l.appearance_rates();
    
    if (l == $location[the sleazy back alley])
        source[$monster[none]] = MIN(MAX(0, 20 - combat_rate_modifier()), 100);
    
    float minimum_monster_appearance = 1000000000.0;
    foreach m in source
    {
        if (m == $monster[none])
            continue;
        float v = source[m];
        if (v > 0.0)
        {
            if (v < minimum_monster_appearance)
                minimum_monster_appearance = v;
        }
    }
    
    float [monster] source_altered;
    foreach m in source
    {
        float v = source[m];
        if (m == $monster[none])
        {
            if (v < 0.0)
                source_altered[m] = 0.0;
            else
                source_altered[m] = v;
        }
        else
            source_altered[m] = v / minimum_monster_appearance;
    }
    
    
    boolean lawyers_relocated = (get_property_int("relocatePygmyLawyer") == my_ascensions());
    boolean janitors_relocated = (get_property_int("relocatePygmyJanitor") == my_ascensions());
    if (l == $location[the hidden park])
    {
        if (janitors_relocated)
            source_altered[$monster[pygmy janitor]] += 1.0;
        if (lawyers_relocated)
            source_altered[$monster[pygmy witch lawyer]] += 1.0;
    }
    if (($locations[The Hidden Apartment Building,The Hidden Bowling Alley,The Hidden Hospital,The Hidden Office Building] contains l))
    {
        if (janitors_relocated && (source_altered contains $monster[pygmy janitor]))
            remove source_altered[$monster[pygmy janitor]];
        if (lawyers_relocated && (source_altered contains $monster[pygmy witch lawyer]))
            remove source_altered[$monster[pygmy witch lawyer]];
    }
    
    foreach m in source_altered
    {
        if (m.is_banished())
            source_altered[m] = 0.0;
    }
    
    if ($effect[on the trail].have_effect() > 0)
    {
        monster olfacted_monster = get_property("olfactedMonster").to_monster();
        if (olfacted_monster != $monster[none])
        {
            if (source_altered contains olfacted_monster)
                source_altered[olfacted_monster] += 3.0; //FIXME is this correct?
        }
    }
    
    
    //Convert source_altered to source.
    if (l == __location_palindome)
    {
        if (!questPropertyPastInternalStepNumber("questL11Palindome", 3))
            source_altered[$monster[none]] = 0.0;
    }
    
    float total = 0.0;
    float nc_rate = clampf(source_altered[$monster[none]], 0.0, 100.0);
    float combat_rate = clampf(100.0 - nc_rate, 0.0, 100.0);
    foreach m in source_altered
    {
        float v = source_altered[m];
        if (m == $monster[none])
            continue;
        if (v > 0)
            total += v;
    }
    if ($locations[Guano Junction,the Batrat and Ratbat Burrow,the Beanbat Chamber] contains l)
    {
        //hacky, probably wrong:
        float v = total / 8.0;
        source_altered[$monster[screambat]] = v;
        total += v;
    }
    //oil peak goes here?
    
    if (total > 0.0)
    {
        foreach m in source_altered
        {
            if (m == $monster[none])
                continue;
            float v = source_altered[m];
            source_altered[m] = v / total * combat_rate;
        }
    }
    
    return source_altered;
}


float [monster] appearance_rates_adjusted_cancel_nc(location l)
{
    float [monster] base_rates = appearance_rates_adjusted(l);
    float nc_rate = base_rates[$monster[none]];
    float nc_inverse_multiplier = 1.0;
    if (nc_rate != 1.0)
        nc_inverse_multiplier = 1.0 / (1.0 - nc_rate);
    foreach m in base_rates
    {
        if (m == $monster[none])
            base_rates[m] = 0.0;
        else
            base_rates[m] *= nc_inverse_multiplier;
    }
    return base_rates;
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
            return true; //FIXME exact detection
		case $location[The Haunted Billiards Room]:
            if (lookupItem("7301").available_amount() > 0)
                return true;
			//return get_property_int("lastManorUnlock") == my_ascensions();
		case $location[The Haunted Bedroom]:
		case $location[The Haunted Bathroom]:
            //FIXME detect this
			return get_property_int("lastSecondFloorUnlock") == my_ascensions();
		case $location[cobb's knob barracks]:
		case $location[cobb's knob kitchens]:
		case $location[cobb's knob harem]:
		case $location[cobb's knob treasury]:
			string quest_value = get_property("questL05Goblin");
			if (quest_value == "finished")
				return true;
			else if (quest_value == "started") //FIXME questPropertyPastInternalStepNumber
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
			return questPropertyPastInternalStepNumber("questL11Worship", 4);
        case $location[the hidden temple]:
            return (get_property_int("lastTempleUnlock") == my_ascensions());
		case $location[the spooky forest]:
			return questPropertyPastInternalStepNumber("questL02Larva", 1);
		case $location[The Smut Orc Logging Camp]:
			return questPropertyPastInternalStepNumber("questL09Topping", 1);
		case $location[the black forest]:
			return questPropertyPastInternalStepNumber("questL11MacGuffin", 1);
		case $location[guano junction]:
		case $location[the bat hole entrance]:
			return questPropertyPastInternalStepNumber("questL04Bat", 1);
		case $location[itznotyerzitz mine]:
			return questPropertyPastInternalStepNumber("questL08Trapper", 2);
        case $location[the arid, extra-dry desert]:
			return (questPropertyPastInternalStepNumber("questL11MacGuffin", 3) || $item[your father's MacGuffin diary].available_amount() > 0);
        case $location[the oasis]:
			return (get_property_int("desertExploration") > 0) && (questPropertyPastInternalStepNumber("questL11MacGuffin", 3) || $item[your father's MacGuffin diary].available_amount() > 0);
        case $location[the defiled alcove]:
			return questPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptAlcoveEvilness") > 0;
        case $location[the defiled cranny]:
			return questPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptCrannyEvilness") > 0;
        case $location[the defiled niche]:
			return questPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptNicheEvilness") > 0;
        case $location[the defiled nook]:
			return questPropertyPastInternalStepNumber("questL07Cyrptic", 1) && get_property_int("cyrptNookEvilness") > 0;
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
	
	string [int] zones_never_accessible = split_string_alternate(zones_never_accessible_string, ",");
	
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




string getClickableURLForLocation(location l, Error unable_to_find_url)
{
    if (l == $location[none])
        return "";
    switch (l)
    {
        //quite the list:
        case $location[the beanbat chamber]:
        case $location[the bat hole entrance]:
        case $location[the batrat and ratbat burrow]:
        case $location[guano junction]:
        case $location[the boss bat's lair]:
            return "place.php?whichplace=bathole";
        case $location[the \"fun\" house]:
        case $location[pre-cyrpt cemetary]:
        case $location[post-cyrpt cemetary]:
        case $location[Spectral Pickle Factory]:
            return "place.php?whichplace=plains";
        case $location[South of the Border]:
        case $location[The Oasis]:
        case $location[The Arid, Extra-Dry Desert]:
        case $location[The Shore, Inc. Travel Agency]:
            return "place.php?whichplace=desertbeach";
        case $location[The Upper Chamber]:
        case $location[The Middle Chamber]:
        case $location[The Lower Chambers]:
            return "pyramid.php";
        case $location[Goat Party]:
        case $location[Pirate Party]:
        case $location[Lemon Party]:
        case $location[The Roulette Tables]:
        case $location[The Poker Room]:
            return "casino.php";
        case $location[The Haiku Dungeon]:
        case $location[The Limerick Dungeon]:
        case $location[The Enormous Greater-Than Sign]:
        case $location[The Dungeons of Doom]:
        case $location[The Daily Dungeon]:
            return "da.php";
        case $location[Video Game Level 1]:
        case $location[Video Game Level 2]:
        case $location[Video Game Level 3]:
            return "place.php?whichplace=faqdungeon";
        case $location[A Maze of Sewer Tunnels]:
            return "clan_hobopolis.php";
        case $location[The Slime Tube]:
            return "clan_slimetube.php";
        case $location[Dreadsylvanian Woods]:
        case $location[Dreadsylvanian Village]:
        case $location[Dreadsylvanian Castle]:
            return "clan_dreadsylvania.php";
        case $location[The Briny Deeps]:
        case $location[The Brinier Deepers]:
        case $location[The Briniest Deepests]:
            return "place.php?whichplace=thesea";
        case $location[An Octopus's Garden]:
        case $location[The Wreck of the Edgar Fitzsimmons]:
        case $location[Madness Reef]:
        case $location[The Mer-Kin Outpost]:
        case $location[The Skate Park]:
        case $location[The Marinara Trench]:
        case $location[Anemone Mine]:
        case $location[Anemone Mine (Mining)]:
        case $location[The Dive Bar]:
        case $location[The Coral Corral]:
        case $location[The Caliginous Abyss]:
            return "seafloor.php";
        case $location[Mer-kin Elementary School]:
        case $location[Mer-kin Library]:
        case $location[Mer-kin Gymnasium]:
        case $location[Mer-kin Colosseum]:
            return "sea_merkin.php?seahorse=1";
        case $location[The Sleazy Back Alley]:
        case lookupLocation("The Copperhead Club"):
            return "place.php?whichplace=town_wrong";
        case $location[The Haunted Pantry]:
            if ($location[the haunted billiards room].locationAvailable())
                return "place.php?whichplace=spookyraven1";
            else
                return "place.php?whichplace=town_right";
        case $location[The Haunted Kitchen]:
        case $location[The Haunted Conservatory]:
        case $location[The Haunted Library]:
        case $location[The Haunted Billiards Room]:
            return "place.php?whichplace=manor1";
        case $location[The Haunted Bathroom]:
        case $location[The Haunted Bedroom]:
        case $location[The Haunted Ballroom]:
        case $location[The Haunted Gallery]:
            return "place.php?whichplace=manor2";
        case lookupLocation("The Haunted Storage Room"):
        case lookupLocation("The Haunted Nursery"):
        case lookupLocation("The Haunted Laboratory"):
            return "place.php?whichplace=manor3";
        //case lookupLocation("The Haunted Wine Cellar"): //incompatible with 16.3
        case lookupLocation("The Haunted Boiler Room"):
        case lookupLocation("The Haunted Laundry Room"):
        case $location[Summoning Chamber]:
            return "place.php?whichplace=manor4";
        case $location[The Hidden Apartment Building]:
        case $location[The Hidden Hospital]:
        case $location[The Hidden Office Building]:
        case $location[The Hidden Bowling Alley]:
        case $location[The Hidden Park]:
        case $location[An Overgrown Shrine (Northwest)]:
        case $location[An Overgrown Shrine (Southwest)]:
        case $location[An Overgrown Shrine (Northeast)]:
        case $location[An Overgrown Shrine (Southeast)]:
        case $location[A Massive Ziggurat]:
            return "place.php?whichplace=hiddencity";
        case $location[The Typical Tavern Cellar]:
            return "cellar.php";
        case $location[8-Bit Realm]:
        case $location[The Spooky Forest]:
        case $location[The Hidden Temple]:
        case $location[Whitey's Grove]:
        case $location[The Road to White Citadel]:
        case $location[The Black Forest]:
        case $location[The Old Landfill]:
        case $location[The Arrrboretum]:
            return "place.php?whichplace=woods";
        case $location[A Barroom Brawl]:
            return "tavern.php";
        case $location[Tower Ruins]:
            return "fernruin.php";
        case $location[Anger Man's Level]:
        case $location[Fear Man's Level]:
        case $location[Doubt Man's Level]:
        case $location[Regret Man's Level]:
            return "place.php?whichplace=junggate_3";
        case $location[The Defiled Nook]:
        case $location[The Defiled Cranny]:
        case $location[The Defiled Alcove]:
        case $location[The Defiled Niche]:
        case $location[Haert of the Cyrpt]:
            return "crypt.php";
        case $location[A-Boo Peak]:
        case $location[Twin Peak]:
        case $location[Oil Peak]:
            return "place.php?whichplace=highlands";
        case $location[The Battlefield (Frat Uniform)]:
        case $location[The Battlefield (Hippy Uniform)]:
            return "bigisland.php";
        case lookupLocation("A Mob of Zeppelin Protesters"):
        case lookupLocation("The Red Zeppelin"):
            return "place.php?whichplace=zeppelin";
        case $location[The Dark Neck of the Woods]:
        case $location[The Dark Heart of the Woods]:
        case $location[The Dark Elbow of the Woods]:
        case $location[Friar Ceremony Location]:
            return "friars.php";
        case $location[Pandamonium Slums]:
            return "pandamonium.php";
        case $location[The Laugh Floor]:
            return "pandamonium.php?action=beli";
        case $location[Infernal Rackets Backstage]:
            return "pandamonium.php?action=infe";
        case $location[The Noob Cave]:
        case $location[The Dire Warren]:
            return "tutorial.php";
        case $location[Itznotyerzitz Mine (in Disguise)]:
        case $location[Itznotyerzitz Mine]:
        case $location[The Goatlet]:
        case $location[Lair of the Ninja Snowmen]:
        case $location[The eXtreme Slope]:
        case $location[Mist-Shrouded Peak]:
        case $location[The Icy Peak]:
            return "place.php?whichplace=mclargehuge";
        case $location[The Smut Orc Logging Camp]:
            return "place.php?whichplace=orc_chasm";
        case $location[The Valley of Rof L'm Fao]:
        case $location[Mt. Molehill]:
        case lookupLocation("The Thinknerd Warehouse"):
            return "place.php?whichplace=mountains";
        case $location[The Nightmare Meatrealm]:
            return "place.php?whichplace=junggate_6";
        case $location[A Kitchen Drawer]:
        case $location[A Grocery Bag]:
            return "place.php?whichplace=junggate_5";
        case $location[Chinatown Shops]:
        case $location[Triad Factory]:
        case $location[1st Floor\, Shiawase-Mitsuhama Building]:
        case $location[2nd Floor\, Shiawase-Mitsuhama Building]:
        case $location[3rd Floor\, Shiawase-Mitsuhama Building]:
        case $location[Chinatown Tenement]:
            return "place.php?whichplace=junggate_1";
        case $location[Sorceress' Hedge Maze]:
            return "lair3.php";
        case $location[Cobb's Knob Laboratory]:
        case $location[The Knob Shaft]:
        case $location[The Knob Shaft (Mining)]:
            return "cobbsknob.php?action=tolabs";
        case $location[Cobb's Knob Menagerie, Level 1]:
        case $location[Cobb's Knob Menagerie, Level 2]:
        case $location[Cobb's Knob Menagerie, Level 3]:
            return "cobbsknob.php?action=tomenagerie";
        case $location[McMillicancuddy's Barn]:
        case $location[McMillicancuddy's Pond]:
        case $location[McMillicancuddy's Back 40]:
        case $location[McMillicancuddy's Other Back 40]:
        case $location[McMillicancuddy's Granary]:
        case $location[McMillicancuddy's Bog]:
        case $location[McMillicancuddy's Family Plot]:
        case $location[McMillicancuddy's Shady Thicket]:
            return "bigisland.php?place=farm";
        case $location[Frat House]:
        case $location[Frat House In Disguise]:
        case $location[The Frat House (Bombed Back to the Stone Age)]:
        case $location[Hippy Camp]:
        case $location[Hippy Camp In Disguise]:
        case $location[The Hippy Camp (Bombed Back to the Stone Age)]:
        case $location[Wartime Frat House]:
        case $location[Wartime Frat House (Hippy Disguise)]:
        case $location[Wartime Hippy Camp]:
        case $location[Wartime Hippy Camp (Frat Disguise)]:
        case $location[The Obligatory Pirate's Cove]:
        case $location[Post-War Junkyard]:
        case $location[McMillicancuddy's Farm]:
            return "island.php";
        case $location[The Broodling Grounds]:
        case $location[The Outer Compound]:
        case $location[The Temple Portico]:
        case $location[Convention Hall Lobby]:
        case $location[Outside the Club]:
        case $location[The Island Barracks]:
        case $location[The Nemesis' Lair]:
            return "volcanoisland.php";
        case $location[The Penultimate Fantasy Airship]:
        case $location[The Hole in the Sky]:
            return "place.php?whichplace=beanstalk";
        case $location[The Castle in the Clouds in the Sky (Basement)]:
        case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
        case $location[The Castle in the Clouds in the Sky (Top Floor)]:
            return "place.php?whichplace=giantcastle";
        case $location[The Outskirts of Cobb's Knob]:
            if ($location[cobb's knob barracks].locationAvailable())
                return "cobbsknob.php";
            else
                return "place.php?whichplace=plains";
        case $location[Cobb's Knob Barracks]:
        case $location[Cobb's Knob Kitchens]:
        case $location[Cobb's Knob Harem]:
        case $location[Cobb's Knob Treasury]:
        case $location[Throne Room]:
            return "cobbsknob.php";
        case $location[Next to that Barrel with Something Burning in it]:
        case $location[Near an Abandoned Refrigerator]:
        case $location[Over Where the Old Tires Are]:
        case $location[Out by that Rusted-Out Car]:
            return "bigisland.php?place=junkyard";
        case $location[The Clumsiness Grove]:
        case $location[The Maelstrom of Lovers]:
        case $location[The Glacier of Jerks]:
            return "suburbandis.php";
        case $location[Domed City of Ronaldus]:
        case $location[Domed City of Grimacia]:
        case $location[Hamburglaris Shield Generator]:
            return "place.php?whichplace=spaaace";
        case $location[Barrrney's Barrr]:
        case $location[The F'c'le]:
        case $location[The Poop Deck]:
        case $location[Belowdecks]:
            return "place.php?whichplace=cove";
        case $location[The Stately Pleasure Dome]:
        case $location[The Mouldering Mansion]:
        case $location[The Rogue Windmill]:
            return "place.php?whichplace=wormwood";
        case $location[The Red Queen's Garden]:
            return "place.php?whichplace=rabbithole";
        case $location[The Primordial Soup]:
        case $location[The Jungles of Ancient Loathing]:
        case $location[Seaside Megalopolis]:
            return "place.php?whichplace=memories";
        case $location[The Degrassi Knoll Restroom]:
        case $location[The Degrassi Knoll Bakery]:
        case $location[The Degrassi Knoll Gym]:
        case $location[The Degrassi Knoll Garage]:
        case $location[The Bugbear Pen]:
        case lookupLocation("The Spooky Gravy Burrow"):
        case $location[Post-Quest Bugbear Pens]:
            if (knoll_available())
                return "place.php?whichplace=knoll_friendly";
            else
                return "place.php?whichplace=knoll_hostile";
        case __location_palindome:
            if ($item[talisman o' nam].equipped_amount() > 0)
                return "place.php?whichplace=palindome";
            else
                return "inventory.php?which=2";
        case lookupLocation("A Deserted Stretch of I-911"):
            return "place.php?whichplace=ioty2014_hare";
        case $location[The Hatching Chamber]:
        case $location[The Feeding Chamber]:
        case $location[The Royal Guard Chamber]:
        case $location[The Filthworm Queen's Chamber]:
            return "bigisland.php?place=orchard";
        case $location[Sonofa Beach]:
            return "bigisland.php?place=lighthouse";
        case $location[The Themthar Hills]:
            return "bigisland.php?place=nunnery";
        case $location[Nemesis Cave]:
            return "cave.php";
        case $location[The Barrel Full of Barrels]:
            return "barrel.php";
        case $location[Fernswarthy's Basement]:
            return "basement.php";
            
        case $location[Pump Up Muscle]:
            return "place.php?whichplace=knoll_friendly&action=dk_gym";
            
        case $location[hobopolis town square]:
            return "clan_hobopolis.php?place=2";
        case $location[Burnbarrel Blvd.]:
            return "clan_hobopolis.php?place=4";
        case $location[Exposure Esplanade]:
            return "clan_hobopolis.php?place=5";
        case $location[The Ancient Hobo Burial Ground]:
            return "clan_hobopolis.php?place=7";
        case $location[The Purple Light District]:
            return "clan_hobopolis.php?place=8";
        case $location[The Heap]:
            return "clan_hobopolis.php?place=6";
        case $location[richard's hobo muscle]:
        case $location[richard's hobo mysticality]:
        case $location[richard's hobo moxie]:
            return "clan_hobopolis.php?place=3";
            
        //Lost to time:
        case $location[Lollipop Forest]:
        case $location[Fudge Mountain]:
        case lookupLocation("WarBear Fortress (First Level)"):
        case lookupLocation("WarBear Fortress (Second Level)"):
        case lookupLocation("WarBear Fortress (Third Level)"):
        case $location[Crimbokutown Toy Factory]:
        case $location[Elf Alley]:
        case $location[CRIMBCO cubicles]:
        case $location[CRIMBCO WC]:
        case $location[Crimbo Town Toy Factory]:
        case $location[The Don's Crimbo Compound]:
        case $location[Atomic Crimbo Toy Factory]:
        case $location[Old Crimbo Town Toy Factory]:
        case $location[Sinister Dodecahedron]:
        case $location[Simple Tool-Making Cave]:
        case $location[Spooky Fright Factory]:
        case $location[Crimborg Collective Factory]:
        case $location[Future Market Square]:
        case $location[Mall of the Future]:
        case $location[Future Wrong Side of the Tracks]:
        case $location[Icy Peak of the Past]:case $location[Shivering Timbers]:
        case $location[A Skeleton Invasion!]:
        case $location[The Cannon Museum]:
        case $location[A Swarm of Yeti-Mounted Skeletons]:
        case $location[The Bonewall]:
        case $location[A Massive Flying Battleship]:
        case $location[A Supply Train]:
        case $location[The Bone Star]:
        case $location[Grim Grimacite Site]:
        case $location[A Pile of Old Servers]:
        case $location[The Haunted Sorority House]:
        case $location[Fightin' Fire]:
        case $location[Super-Intense Mega-Grassfire]:
        case $location[Fierce Flying Flames]:
        case $location[Lord Flameface's Castle Entryway]:
        case $location[Lord Flameface's Castle Belfry]:
        case $location[Lord Flameface's Throne Room]:
        case $location[A Stinking Abyssal Portal]:
        case $location[A Scorching Abyssal Portal]:
        case $location[A Terrifying Abyssal Portal]:
        case $location[A Freezing Abyssal Portal]:
        case $location[An Unsettling Abyssal Portal]:
        case $location[A Yawning Abyssal Portal]:
        case $location[The Space Odyssey Discotheque]:
        case $location[The Spirit World]:
            return "";
    }
    ErrorSet(unable_to_find_url);
    return "";
}

string getClickableURLForLocation(location l)
{
    return l.getClickableURLForLocation(ErrorMake());
}

string getClickableURLForLocationIfAvailable(location l)
{
    Error able_to_find;
    boolean found = l.locationAvailable(able_to_find);
    if (able_to_find.was_error) //assume it's available, since we don't know
        found = true;
    if (found)
        return l.getClickableURLForLocation();
    else
        return "";
}