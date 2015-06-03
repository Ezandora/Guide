void SFamiliarsGenerateEntry(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, boolean from_task)
{
	if (get_property_int("_badlyRomanticArrows") == 0 && (familiar_is_usable($familiar[obtuse angel]) || familiar_is_usable($familiar[reanimated reanimator])))
	{
        if (!__misc_state["In aftercore"] && !from_task)
            return;
        if (__misc_state["In aftercore"] && from_task)
            return;
		string familiar_image = __misc_state_string["obtuse angel name"];
        string [int] description;
        string title = "Arrow monster";
        if (familiar_image == "reanimated reanimator")
            title = "Wink at monster";
        string url;
        if (!($familiars[obtuse angel, reanimated reanimator] contains my_familiar()))
            url = "familiar.php";
		
		if ($familiar[reanimated reanimator].familiar_is_usable() || ($familiar[obtuse angel].familiar_is_usable() && $familiar[obtuse angel].familiar_equipment() == $item[quake of arrows]))
            description.listAppend("Three wandering copies.");
        else
            description.listAppend("Two wandering copies.");
		
		string [int] potential_targets;
        //a short list:
        if (__quest_state["Level 7"].state_int["alcove evilness"] > 31)
            potential_targets.listAppend("modern zmobie");
            
        if (!__quest_state["Level 8"].state_boolean["Mountain climbed"] && $items[ninja rope,ninja carabiner,ninja crampons].available_amount() == 0 && !have_outfit_components("eXtreme Cold-Weather Gear"))
            potential_targets.listAppend("ninja assassin");
        
        if (!__quest_state["Level 12"].state_boolean["Lighthouse Finished"] && $item[barrel of gunpowder].available_amount() < 5)
            potential_targets.listAppend("lobsterfrogman");
        
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"] && have_outfit_components("Frat Warrior Fatigues") && have_outfit_components("War Hippy Fatigues")) //brigand trick
            potential_targets.listAppend("brigand");
        
        if (!familiar_is_usable($familiar[angry jung man]) && in_hardcore() && !__quest_state["Level 13"].state_boolean["digital key used"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0 && __misc_state["fax equivalent accessible"])
            potential_targets.listAppend("ghost");
        
        if (__misc_state["In run"] && ($items[bricko eye brick,bricko airship,bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner].available_amount() > 0 || $skill[summon brickos].skill_is_usable()))
            potential_targets.listAppend("BRICKO monster");
        
        if (potential_targets.count() > 0)
            description.listAppend("Possibly a " + potential_targets.listJoinComponents(", ", "or") + ".");
        
		optional_task_entries.listAppend(ChecklistEntryMake(familiar_image, url, ChecklistSubentryMake(title, "", description), 6));
	}
    
    
    if (lookupFamiliar("Crimbo Shrub").familiar_is_usable())
    {
        boolean should_output = false;
        if (__misc_state["In run"])
        {
            if (from_task)
                should_output = true;
        }
        else
        {
            if (!from_task)
                should_output = true;
        }
        if (get_property("shrubGifts") == "meat" && $effect[everything looks red].have_effect() == 0 && should_output)
        {
            string url = "";
            string title = "Open a Big Red Present in combat";
            if (!from_task)
                title = "Big Red Present openable in combat";
            string description = "Gives 2.5k meat.";
            if (my_familiar() != lookupFamiliar("Crimbo Shrub"))
            {
                url = "familiar.php";
                if (from_task)
                    title = "Switch to Crimbo Shrub to open a big red present";
                else
                    description = "Switch to Crimbo Shrub first.|" + description;
            }
            optional_task_entries.listAppend(ChecklistEntryMake("__item dense meat stack", url, ChecklistSubentryMake(title, "", description), 6));
        }
    }
}

void SFamiliarsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (__misc_state["free runs usable"] && ($familiar[pair of stomping boots].familiar_is_usable() || ($skill[the ode to booze].skill_is_usable() && $familiar[Frumious Bandersnatch].familiar_is_usable())))
	{
		int runaways_used = get_property_int("_banderRunaways");
		string name = runaways_used + " familiar runaways used";
		string [int] description;
		string image_name = "";
        
        string url = "";
		
		if ($familiar[Frumious Bandersnatch].familiar_is_usable() && $skill[the ode to booze].skill_is_usable())
		{
			image_name = "Frumious Bandersnatch";
		}
		else if ($familiar[pair of stomping boots].familiar_is_usable())
		{
			image_name = "pair of stomping boots";
		}
        
        if (!($familiars[Frumious Bandersnatch, pair of stomping boots] contains my_familiar()))
            url = "familiar.php";
        
        if (my_path_id() != PATH_HEAVY_RAINS)
        {
            int snow_suit_runs = floor(numeric_modifier($item[snow suit], "familiar weight") / 5.0);
            
            if ($item[snow suit].available_amount() == 0)
                snow_suit_runs = 0;
                
            if (snow_suit_runs >= 2)
                description.listAppend("Snow Suit available (+" + snow_suit_runs + " runs)");
            else if ($item[sugar shield].available_amount() > 0)
                description.listAppend("Sugar shield available (+2 runs)");
        }
			
		available_resources_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(name, "", description)));
	}
	
	if (true)
	{
		int hipster_fights_available = __misc_state_int["hipster fights available"];
			
		if (($familiar[artistic goth kid].familiar_is_usable() || $familiar[Mini-Hipster].familiar_is_usable()) && hipster_fights_available > 0)
		{
			string name = "";
			string [int] description;
				
			name = pluralize(hipster_fights_available, __misc_state_string["hipster name"] + " fight", __misc_state_string["hipster name"] + " fights");
			
			int [int] hipster_chances;
			hipster_chances[7] = 50;
			hipster_chances[6] = 40;
			hipster_chances[5] = 30;
			hipster_chances[4] = 20;
			hipster_chances[3] = 10;
			hipster_chances[2] = 10;
			hipster_chances[1] = 10;
            
            string url = "";
            if (!($familiars[artistic goth kid,mini-hipster] contains my_familiar()))
                url = "familiar.php";
			
			description.listAppend(hipster_chances[hipster_fights_available] + "% chance of appearing.");
			int importance = 0;
            if (!__misc_state["In run"])
                importance = 6;
			available_resources_entries.listAppend(ChecklistEntryMake(__misc_state_string["hipster name"], url, ChecklistSubentryMake(name, "", description), importance));
		}
	}
	
	
	if ($familiar[nanorhino].familiar_is_usable() && get_property_int("_nanorhinoCharge") == 100)
	{
		ChecklistSubentry [int] subentries;
		string [int] description_banish;
		
        string url = "";
        
        if (my_familiar() != $familiar[nanorhino])
            url = "familiar.php";
		
        if (get_property("_nanorhinoBanishedMonster") != "")
            description_banish.listAppend(get_property("_nanorhinoBanishedMonster").HTMLEscapeString().capitalizeFirstLetter() + " currently banished.");
        else
            description_banish.listAppend("All day. Cast muscle combat skill.");
		if (__misc_state["have muscle class combat skill"])
			subentries.listAppend(ChecklistSubentryMake("Nanorhino Banish", "", description_banish));
		if (__misc_state["need to level"] && __misc_state["have mysticality class combat skill"])
			subentries.listAppend(ChecklistSubentryMake("Nanorhino Gray Goo", "", "130? mainstat, fire against non-item monster with >90 attack. Cast mysticality combat skill."));
		if (!$familiar[he-boulder].familiar_is_usable() && __misc_state["have moxie class combat skill"] && __misc_state["In run"])
        {
            if ($effect[everything looks yellow].have_effect() > 0)
                subentries.listAppend(ChecklistSubentryMake(HTMLGenerateSpanFont("Nanorhino Yellow Ray", "gray"), "", HTMLGenerateSpanFont("Cast moxie combat skill once everything looks yellow is gone.", "gray")));
            else
                subentries.listAppend(ChecklistSubentryMake("Nanorhino Yellow Ray", "", "Cast moxie combat skill."));
        }
		if (subentries.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__familiar nanorhino", url, subentries, 5));
	}
	if (__misc_state["yellow ray available"] && !__misc_state["In run"])
    {
        available_resources_entries.listAppend(ChecklistEntryMake(__misc_state_string["yellow ray image name"], "", ChecklistSubentryMake("Yellow ray available", "", "From " + __misc_state_string["yellow ray source"] + "."), 6));
    }
    
    if (my_familiar() == $familiar[happy medium] || $familiar[happy medium].charges > 0 && $familiar[happy medium].familiar_is_usable()) //|| stuff
    {
        //FIXME request support for tracking medium combats.
        string title;
        string [int] description;
        
        int charges = $familiar[happy medium].charges;
        int siphons = get_property_int("_mediumSiphons");
        
        int adventures_to_next_at_most = 3 + siphons;
        
        if (charges == 3)
        {
            title = "Red medium";
            description.listAppend("4.25 turns/drunkenness.");
        }
        else if (charges == 2)
        {
            title = "Orange medium";
            description.listAppend("3.25 turns/drunkenness.");
            description.listAppend(pluralizeWordy(adventures_to_next_at_most, "turn", "turns").capitalizeFirstLetter() + " (at most) to red.");
        }
        else if (charges == 1)
        {
            title = "Blue medium";
            description.listAppend("2.25 turns/drunkenness.");
            description.listAppend(pluralizeWordy(adventures_to_next_at_most, "turn", "turns").capitalizeFirstLetter() + " (at most) to orange.");
        }
        else
        {
            title = "Uncharged medium";
            description.listAppend(pluralizeWordy(adventures_to_next_at_most, "turn", "turns").capitalizeFirstLetter() + " (at most) to blue. ");
        }
        string url;
        if (my_familiar() != $familiar[happy medium])
            url = "familiar.php";
        
        int importance = 6;
        if (my_familiar() == $familiar[happy medium] || charges > 0)
            importance = 0;
        available_resources_entries.listAppend(ChecklistEntryMake("__familiar happy medium", url, ChecklistSubentryMake(title, "", description), importance));
    }
    if (my_familiar() == $familiar[steam-powered cheerleader] || $familiar[steam-powered cheerleader].familiar_is_usable() && get_property_int("_cheerleaderSteam") < 200)
    {
        string title;
        string [int] description;
        
        int steam_remaining = get_property_int("_cheerleaderSteam");
        float multiplier = 1.0;
        float next_multiplier_level = 1.0;
        
        int next_steam_level = 0;
        
        boolean has_socket_set = $familiar[steam-powered cheerleader].familiar_equipped_equipment() == $item[school spirit socket set];
        
        if (steam_remaining >= 151)
        {
            multiplier = 1.4;
            next_multiplier_level = 1.3;
            next_steam_level = 150;
        }
        else if (steam_remaining >= 101)
        {
            multiplier = 1.3;
            next_multiplier_level = 1.2;
            next_steam_level = 100;
        }
        else if (steam_remaining >= 51)
        {
            multiplier = 1.2;
            next_multiplier_level = 1.1;
            next_steam_level = 50;
        }
        else if (steam_remaining >= 1)
        {
            multiplier = 1.1;
            next_multiplier_level = 1.0;
            next_steam_level = 0;
        }
        
        int steam_at_this_level_remaining = steam_remaining - next_steam_level;
        int turns_remaining_at_this_level = steam_at_this_level_remaining;
        if (!has_socket_set)
            turns_remaining_at_this_level = turns_remaining_at_this_level / 2;
        
        
        
        title = multiplier + "x fairy steam-powered cheerleader";
        
        if (turns_remaining_at_this_level > 0)
            description.listAppend(pluralize(turns_remaining_at_this_level, "turn remains", "turns remain") + " until " + next_multiplier_level + "x.");
        
        int importance = 6;
        if (my_familiar() == $familiar[steam-powered cheerleader])
            importance = 0;
        
    
        string url;
        if (my_familiar() != $familiar[steam-powered cheerleader])
            url = "familiar.php";
        
        
        available_resources_entries.listAppend(ChecklistEntryMake("__familiar steam-powered cheerleader", url, ChecklistSubentryMake(title, "", description), importance));
    }
    
    if ($familiar[grim brother].familiar_is_usable() && !get_property_boolean("_grimBuff") && __misc_state["In run"]) //in aftercore, let the maximizer handle it?
    {
        string title;
        string [int] description;
        string url = "familiar.php?action=chatgrim&amp;pwd=" + my_hash();
        
        title = "Chat with grim brother";
        
        description.listAppend("30 turns of +20% init or +HP/MP or +damage.");
        int importance = 9;
        available_resources_entries.listAppend(ChecklistEntryMake("__familiar grim brother", url, ChecklistSubentryMake(title, "", description), importance));
    }
    
    item yellow_pixel = lookupItem("yellow pixel");
    if (yellow_pixel != $item[none] && yellow_pixel.available_amount() > 0 && __misc_state["in run"])
    {
        string title = pluralize(yellow_pixel);
        string [int] description;
        string url = "place.php?whichplace=forestvillage&action=fv_mystic"; //"shop.php?whichshop=mystic";
        //Pixel coin - 10 yellow pixels - 2k autosell (marginal)
        //power pill - 25 yellow pixels - instakill
        //pixel star - 15 yellow pixels, 2 black pixels - 30 turns of +100% HP/MP/spell damage/weapon damage
        //pixel banana - 10 yellow pixels, 1 black pixel - 2-size awesome food, 10 turns of +30% item
        //pixel beer - 10 yellow pixels, 5 white pixels - 2-size awesome drunk, 10 turns of +3 stats/fight (15 mainstat)
        boolean [item] items_to_always_show;
        items_to_always_show[lookupItem("power pill")] = true;
        
        item [int] evalulation_order;
        evalulation_order.listAppend(lookupItem("power pill"));
        
        string [item] reasons;
        if (my_meat() < 20000)
            reasons[lookupItem("pixel coin")] = "Autosells 2000 meat. (marginal)";
        reasons[lookupItem("power pill")] = "Zero-turn instakill.";
        reasons[lookupItem("pixel star")] = "+100% HP/MP/spell/weapon damage. (30 turns)";
        //these (should) show up in mafia's consumption manager and they are fairly marginal, so disabled
        /*if (__misc_state["can eat just about anything"])
            reasons[lookupItem("pixel banana")] = "2-size awesome food, 10 turns of +30% item.";
        if (__misc_state["can drink just about anything"])
            reasons[lookupItem("pixel beer")] = "2-size awesome drunk, 10 turns of +3 stats/fight.";*/
        
        boolean [item] evaluated;
        foreach key, it in evalulation_order
            evaluated[it] = true;
        foreach it in reasons
        {
            if (!(evaluated contains it))
            {
                evaluated[it] = true;
                evalulation_order.listAppend(it);
            }
        }
        
        foreach key, it in evalulation_order
        {
            string reason = reasons[it];
            if (reason.length() == 0)
                continue;
            if (it == $item[none])
                continue;
            if (it.creatable_amount() == 0 && !items_to_always_show[it])
                continue;
            string line;
            line = it.capitalizeFirstLetter() + ": " + reason;
            if (it.creatable_amount() == 0)
                line = HTMLGenerateSpanFont(line, "grey");
            description.listAppend(line);
        }
        int importance = 9;
        available_resources_entries.listAppend(ChecklistEntryMake("__familiar ms. puck man", url, ChecklistSubentryMake(title, "", description), importance));
    }
    if (lookupItem("power pill").available_amount() > 0 && __misc_state["in run"])
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item power pill", "", ChecklistSubentryMake(lookupItem("power pill").pluralize().capitalizeFirstLetter(), "", "Use in combat to instakill without costing a turn."), 9));
    }
    
    //FIXME small medium, organ grinder, charged boots
	SFamiliarsGenerateEntry(available_resources_entries, available_resources_entries, false);
}

void SFamiliarsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_familiar() == $familiar[none] && !__misc_state["single familiar run"] && !__misc_state["familiars temporarily blocked"])
	{
		string image_name = "black cat";
		optional_task_entries.listAppend(ChecklistEntryMake(image_name, "familiar.php", ChecklistSubentryMake("Bring along a familiar", "", "")));
	}
    
    if (lookupFamiliar("Crimbo Shrub").familiar_is_usable())
    {
        boolean configured = get_property("shrubGarland").length() > 0 || get_property("shrubGifts").length() > 0 || get_property("shrubLights").length() > 0 || get_property("shrubTopper").length() > 0;
        if (my_daycount() == 1 && get_property("_shrubDecorated") == "false") //default configuration exists, but
            configured = false;
        if (!configured && (__misc_state["In run"] || my_familiar() == lookupFamiliar("Crimbo Shrub")) && get_property("_shrubDecorated") == "false")
        {
            string [int] description;
            
            string [int] configuration_idea;
            if (my_primestat() == $stat[muscle])
                configuration_idea.listAppend("Veiny Star");
            else if (my_primestat() == $stat[mysticality])
                configuration_idea.listAppend("LED Mandala");
            else if (my_primestat() == $stat[moxie])
                configuration_idea.listAppend("Angel With Sunglasses");
            
            configuration_idea.listAppend("Frosted Lights"); //random pick really
            
            if (hippy_stone_broken())
                configuration_idea.listAppend("Barbed Wire");
            else
                configuration_idea.listAppend("Popcorn Strands");
            
            if (!__misc_state["yellow ray potentially available"])
                configuration_idea.listAppend("Big Yellow-Wrapped Presents");
            else
                configuration_idea.listAppend("Big Red-Wrapped Presents");
            
            description.listAppend("Maybe " + configuration_idea.listJoinComponents(" / ") + "?");
            
            string url = "familiar.php";
            
            if (lookupItem("box of old Crimbo decorations").available_amount() > 0)
                url = "inv_use.php?pwd=" + my_hash() + "&whichitem=7958";
            
            optional_task_entries.listAppend(ChecklistEntryMake("__item box of old Crimbo decorations", url, ChecklistSubentryMake("Configure your Crimbo Shrub", "", description), 6));
        }
        /*
        shrubGarland(user, now 'PvP', default )
        shrubGifts(user, now 'meat', default )
        shrubLights(user, now 'Cold', default )
        shrubTopper(user, now 'Moxie', default )
        */
    }
    
	SFamiliarsGenerateEntry(task_entries, optional_task_entries, true);
}