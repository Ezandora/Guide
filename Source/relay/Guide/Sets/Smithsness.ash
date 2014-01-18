void smithsnessGenerateCoalSuggestions(string [int] coal_suggestions)
{
    if (!__misc_state["In run"])
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
	
	if (have_skill($skill[pulverize]))
		coal_suggestions.listAppend("Smash smithed weapon for more smithereens");
	foreach it in coal_item_suggestions
	{
		int number_wanted_max = 1;
		if (it.to_slot() == $slot[weapon] && it.weapon_hands() == 1)
		{
			if (have_skill($skill[double-fisted skull smashing]))
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
	smithereen_suggestions.listAppend(7014.to_item().to_string() + ": free run/banish for 20 turns");
	
	if (__misc_state["can eat just about anything"] && availableFullness() >= 2)
	{
		smithereen_suggestions.listAppend("Charming Flan: 2 fullness epic food|Miserable Pie: 2 fullness awesome food, 50 turns of +10 smithsness");
	}
		
	if (__misc_state["can drink just about anything"] && availableDrunkenness() >= 2)
	{
		smithereen_suggestions.listAppend("Vulgar Pitcher: 2 drunkenness epic drink|Bigmouth: 2 drunkenness awesome drink, 50 turns of +10 smithsness");
	}
	if (!familiar_is_usable($familiar[he-boulder]))
		smithereen_suggestions.listAppend("Yellow ray");
	
}

void SSmithsnessGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (__misc_state["In run"] && $item[handful of smithereens].available_amount() > 0)
	{
		string [int] smithereen_suggestions;
		smithsnessGenerateSmithereensSuggestions(smithereen_suggestions);
		available_resources_entries.listAppend(ChecklistEntryMake("__item handful of smithereens", "", ChecklistSubentryMake(pluralize($item[handful of smithereens]), "", smithereen_suggestions.listJoinComponents("<hr>")), 10));
	}
	if (__misc_state["In run"] && $item[lump of Brituminous coal].available_amount() > 0)
	{
		string [int] coal_suggestions;
		smithsnessGenerateCoalSuggestions(coal_suggestions);
		available_resources_entries.listAppend(ChecklistEntryMake("__item lump of Brituminous coal", "", ChecklistSubentryMake(pluralize($item[lump of Brituminous coal]), "", coal_suggestions.listJoinComponents("<hr>")), 10));
	}
	if ($item[flaskfull of hollow].available_amount() > 0 && $effect[Merry Smithsness].have_effect() < 25 && __misc_state["In run"])
	{
		int turns_left = $effect[Merry Smithsness].have_effect();
		string [int] details;
		details.listAppend(pluralize((turns_left + 150 * $item[flaskfull of hollow].available_amount()), "turn", "turns") + " of +25 smithsness");
		if (turns_left > 0)
			details.listAppend("Effect will run out in " + pluralize(turns_left, "turn", "turns"));
		available_resources_entries.listAppend(ChecklistEntryMake("__item flaskfull of hollow", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[flaskfull of hollow]), "", details), 10));
	}
}