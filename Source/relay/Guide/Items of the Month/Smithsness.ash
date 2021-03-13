void smithsnessGenerateCoalSuggestions(string [int] coal_suggestions)
{
    if (!__misc_state["in run"])
        return;
	string [item] coal_item_suggestions;
	
	if (__misc_state["can equip just about any weapon"])
	{
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
            coal_item_suggestions[$item[half a purse]] = "2x smithsness meat for nuns";
		coal_item_suggestions[$item[A Light that Never Goes Out]] = "2x smithsness +item";
			
			
		if (my_class() == $class[seal clubber])
			coal_item_suggestions[$item[Meat Tenderizer is Murder]] = "weapon, +2x smithsness muscle %";
		else if (my_class() == $class[turtle tamer])
			coal_item_suggestions[$item[Ouija Board, Ouija Board]] = "weapon, +2x smithsness muscle %";
		else if (my_class() == $class[pastamancer])
			coal_item_suggestions[$item[Hand that Rocks the Ladle]] = "weapon, +2x smithsness mysticality %";
		else if (my_class() == $class[sauceror])
			coal_item_suggestions[$item[Saucepanic]] = "weapon, +myst stats, +2x smithsness mysticality %";
		else if (my_class() == $class[disco bandit])
			coal_item_suggestions[$item[Frankly Mr. Shank]] = "weapon, +2x smithsness moxie %";
		else if (my_class() == $class[accordion thief])
			coal_item_suggestions[$item[Shakespeare's Sister's Accordion]] = "weapon, +2x smithsness moxie %, useful cadenza";
		//not sure I like these suggestions based off of mainstat, but...
		else if (my_primestat() == $stat[mysticality])
			coal_item_suggestions[$item[Staff of the Headmaster's Victuals]] = "weapon, +smithsnesss spell damage";
		else if (my_primestat() == $stat[muscle])
			coal_item_suggestions[$item[Work is a Four Letter Sword]] = "weapon, +2x smithsness weapon damage";
		else if (my_primestat() == $stat[moxie])
			coal_item_suggestions[$item[Sheila Take a Crossbow]] = "weapon, +smithsness initiative";
        
        string [int] sheila_reasons;
        if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
			sheila_reasons.listAppend("modern zmobies");
        if (!__quest_state["Level 13"].state_boolean["Init race completed"])
            sheila_reasons.listAppend("lair init race");
        if (sheila_reasons.count() > 0)
            coal_item_suggestions[$item[Sheila Take a Crossbow]] = "weapon, +smithsness initiative (useful for " + sheila_reasons.listJoinComponents(", ", "and") + ")";
			
			
	}
	coal_item_suggestions[$item[Hand in Glove]] = "lots of +ML";
	if ($item[dirty hobo gloves].available_amount() == 0)
		coal_item_suggestions[$item[Hand in Glove]] += " (need dirty hobo gloves)";
	else
		coal_item_suggestions[$item[Hand in Glove]] += " (have dirty hobo gloves)";
	if (knoll_available() || $item[maiden wig].available_amount() > 0)
		coal_item_suggestions[$item[Hairpiece On Fire]] = "+4 adventures, +5 smithness hat, +smithsness MP";
	if (knoll_available() || $item[frilly skirt].available_amount() > 0)
	{
		coal_item_suggestions[$item[Vicar's Tutu]] = "+5 smithsness pants, +smithsness HP";
		
		if (hippy_stone_broken())
			coal_item_suggestions[$item[Vicar's Tutu]] = coal_item_suggestions[$item[Vicar's Tutu]] + ", +3 PVP fights";
	}
	
	if ($skill[pulverize].skill_is_usable())
		coal_suggestions.listAppend("Smash smithed equipment for more smithereens");
	foreach it in coal_item_suggestions
	{
		int number_wanted_max = 1;
		if (it.to_slot() == $slot[weapon] && it.weapon_hands() == 1)
		{
			if ($skill[double-fisted skull smashing].skill_is_usable() && it.item_type() != "accordion")
				number_wanted_max += 1;
			if (familiar_is_usable($familiar[disembodied hand]))
				number_wanted_max += 1;
		}
		
		if (it.available_amount() >= number_wanted_max)
			continue;
		string suggestion = coal_item_suggestions[it];
		coal_suggestions.listAppend(it + ": " + suggestion);
	}
}

void smithsnessGenerateSmithereensSuggestions(string [int] smithereen_suggestions) //suggestereens
{
	smithereen_suggestions.listAppend(7014.to_item().to_string() + ": " + (__misc_state["free runs usable"] ? "free run/" : "") + "banish for 20 turns");
	
	if (__misc_state["can eat just about anything"] && availableFullness() >= 2 && my_path_id() != PATH_SLOW_AND_STEADY)
	{
		smithereen_suggestions.listAppend("Charming Flan: 2 fullness epic food<br>Miserable Pie: 2 fullness awesome food, 50 turns of +10 smithsness");
	}
		
	if (__misc_state["can drink just about anything"] && availableDrunkenness() >= 2 && my_path_id() != PATH_SLOW_AND_STEADY)
	{
		smithereen_suggestions.listAppend("Vulgar Pitcher: 2 drunkenness epic drink<br>Bigmouth: 2 drunkenness awesome drink, 50 turns of +10 smithsness");
	}
	if (!$familiar[he-boulder].familiar_is_usable())
    {
        string line = "Golden Light: Yellow ray";
        if ($effect[everything looks yellow].have_effect() > 0)
            line = HTMLGenerateSpanFont(line, "gray");
		smithereen_suggestions.listAppend(line);
    }
    
    if (__misc_state["in run"])
        smithereen_suggestions.listAppend("Handsome Devil: single-turn +100% item");
	
}

RegisterResourceGenerationFunction("IOTMSmithsnessGenerateResource");
void IOTMSmithsnessGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (__misc_state["in run"] && $item[handful of smithereens].available_amount() > 0 && in_ronin())
	{
		string [int] smithereen_suggestions;
		smithsnessGenerateSmithereensSuggestions(smithereen_suggestions);
		resource_entries.listAppend(ChecklistEntryMake(493, "__item handful of smithereens", "", ChecklistSubentryMake(pluralise($item[handful of smithereens]), "", smithereen_suggestions.listJoinComponents("<hr>")), 10));
	}
	if (__misc_state["in run"] && $item[lump of Brituminous coal].available_amount() > 0 && in_ronin())
	{
		string [int] coal_suggestions;
		smithsnessGenerateCoalSuggestions(coal_suggestions);
		resource_entries.listAppend(ChecklistEntryMake(494, "__item lump of Brituminous coal", "", ChecklistSubentryMake(pluralise($item[lump of Brituminous coal]), "", coal_suggestions.listJoinComponents("<hr>")), 10));
	}
	if ($item[flaskfull of hollow].available_amount() > 0 && $effect[Merry Smithsness].have_effect() < 25 && __misc_state["in run"])
	{
		int turns_left = $effect[Merry Smithsness].have_effect();
		string [int] details;
		details.listAppend(pluralise((turns_left + 150 * $item[flaskfull of hollow].available_amount()), "turn", "turns") + " of +25 smithsness");
		if (turns_left > 0)
			details.listAppend("Effect will run out in " + pluralise(turns_left, "turn", "turns"));
		resource_entries.listAppend(ChecklistEntryMake(495, "__item flaskfull of hollow", "inventory.php?which=3", ChecklistSubentryMake(pluralise($item[flaskfull of hollow]), "", details), 10));
	}
}
