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
        
        if (!familiar_is_usable($familiar[angry jung man]) && in_hardcore() && !__quest_state["Level 13"].state_boolean["past keys"] && ($item[digital key].available_amount() + creatable_amount($item[digital key])) == 0 && __misc_state["fax accessible"])
            potential_targets.listAppend("ghost");
        
        if (__misc_state["In run"] && ($items[bricko eye brick,bricko airship,bricko bat,bricko cathedral,bricko elephant,bricko gargantuchicken,bricko octopus,bricko ooze,bricko oyster,bricko python,bricko turtle,bricko vacuum cleaner].available_amount() > 0 || $skill[summon brickos].have_skill()))
            potential_targets.listAppend("BRICKO monster");
        
        if (potential_targets.count() > 0)
            description.listAppend("Possibly a " + potential_targets.listJoinComponents(", ", "or") + ".");
        
		optional_task_entries.listAppend(ChecklistEntryMake(familiar_image, url, ChecklistSubentryMake(title, "", description), 6));
	}
}

void SFamiliarsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (__misc_state["free runs usable"] && ($familiar[pair of stomping boots].familiar_is_usable() || (have_skill($skill[the ode to booze]) && $familiar[Frumious Bandersnatch].familiar_is_usable())))
	{
		int runaways_used = get_property_int("_banderRunaways");
		string name = runaways_used + " familiar runaways used";
		string [int] description;
		string image_name = "";
        
        string url = "";
		
		if ($familiar[Frumious Bandersnatch].familiar_is_usable() && $skill[the ode to booze].have_skill())
		{
			image_name = "Frumious Bandersnatch";
		}
		else if ($familiar[pair of stomping boots].familiar_is_usable())
		{
			image_name = "pair of stomping boots";
		}
        
        if (!($familiars[Frumious Bandersnatch, pair of stomping boots] contains my_familiar()))
            url = "familiar.php";
		int snow_suit_runs = floor(numeric_modifier($item[snow suit], "familiar weight") / 5.0);
		
		if ($item[snow suit].available_amount() == 0)
			snow_suit_runs = 0;
			
		if (snow_suit_runs >= 2)
			description.listAppend("Snow Suit available (+" + snow_suit_runs + " runs)");
		else if ($item[sugar shield].available_amount() > 0)
			description.listAppend("Sugar shield available (+2 runs)");
			
			
		available_resources_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(name, "", description)));
	}
	
	if (true)
	{
		int hipster_fights_available = __misc_state_int["hipster fights available"];
			
		if (($familiar[artistic goth kid].familiar_is_usable() || $familiar[Mini-Hipster].familiar_is_usable()) && hipster_fights_available > 0)
		{
			string name = "";
			string [int] description;
				
			name = pluralize(hipster_fights_available, __misc_state_string["hipster name"] + " fight", __misc_state_string["hipster name"] + " fights") + " available";
			
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
                subentries.listAppend(ChecklistSubentryMake(HTMLGenerateSpanFont("Nanorhino Yellow Ray", "gray", ""), "", HTMLGenerateSpanFont("Cast moxie combat skill once everything looks yellow is gone.", "gray", "")));
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
	SFamiliarsGenerateEntry(task_entries, optional_task_entries, true);
}