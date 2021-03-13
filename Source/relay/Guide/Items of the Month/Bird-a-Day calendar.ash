string [int] convertMafiaModifierStringToOurStyle(string modifier_string)
{
	string [int] modifiers;
    foreach key, s in modifier_string.split_string(", ")
    {
        if (s == "") continue;
        string [int] line = s.split_string(": ");
        if (line.count() == 2)
        {
            string value = line[1];
            string modifier = line[0].to_lower_case();
            
            string [string] short_name_for_modifiers = {
            "muscle percent":"muscle",
            "mysticality percent":"mysticality",
            "moxie percent":"moxie",
            "item drop":"item",
            "food drop":"food",
            "damage absorption":"DA",
            "damage reduction":"DR",
            "combat rate":"combat",
            };
            
            if (modifier == "muscle percent" || modifier == "mysticality percent" || modifier == "moxie percent" || modifier == "item drop" || modifier == "food drop" || modifier == "combat rate")
            {
                value += "%";
            }
            if (short_name_for_modifiers contains modifier)
                modifier = short_name_for_modifiers[modifier];
            modifiers.listAppend(value + " " + modifier);
        }
        else
            modifiers.listAppend(s);
    }
	return modifiers;
}

RegisterResourceGenerationFunction("IOTMBirdADayCalendarGenerateResource");
void IOTMBirdADayCalendarGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!$item[bird-a-day calendar].have()) return;
	
	//_birdOfTheDay: unknown
	//_birdOfTheDayMods: 
	//_birdsSoughtToday: unknown
	//_canSeekBirds: boolean
	
	int birds_sought_today = get_property_int("_birdsSoughtToday");
	int skill_mp_cost = 5 * powi(2, birds_sought_today);
	string bird_of_the_day = get_property("_birdOfTheDay");
	
	if (true)
	{
    	string [int] modifiers;
        if (bird_of_the_day != "")
	        modifiers = convertMafiaModifierStringToOurStyle(get_property("_birdOfTheDayMods"));
    	string [int] description;
        string url = "skillz.php";
        if (modifiers.count() == 0)
        	modifiers.listAppend("Unknown");
        description.listAppend(modifiers.listJoinComponents(", ") + " buff. (10 turns, " + skill_mp_cost + " mp)");
        if (!get_property_boolean("_canSeekBirds"))
        {
        	description.listAppend("Use your bird-a-day calendar first.");
            url = "inventory.php?which=3&ftext=bird-a-day+calendar";
        }
        
        if (birds_sought_today == 6 && bird_of_the_day != get_property("yourFavoriteBird"))
        {
        	description.listAppend(HTMLGenerateSpanFont("Warning: casting this skill again will make it your favourite bird, which stays across ascension.", "red"));
        }
        	
        resource_entries.listAppend(ChecklistEntryMake(539, "__skill " + $skill[Seek out a bird], url, ChecklistSubentryMake("Seek out a Bird", "", description), 5).ChecklistEntryTag("bird-a-day calendar").ChecklistEntrySetCategory("buff").ChecklistEntrySetShortDescription(skill_mp_cost + "mp"));
	}
	//_favoriteBirdVisited: boolean
	//yourFavoriteBird: string, name
	//yourFavoriteBirdMods: what the birds does. format: "Moxie Percent: +75, Spooky Resistance: +2, Item Drop: +20, Damage Absorption: +100, Damage Reduction: 5"
	
	//thought about putting this in skills.ash, but it's here instead
    if ($skill[Visit your Favorite Bird].skill_is_usable() && !get_property_boolean("_favoriteBirdVisited"))
    {
    	string [int] modifiers = convertMafiaModifierStringToOurStyle(get_property("yourFavoriteBirdMods"));
    	string [int] description;
        description.listAppend(modifiers.listJoinComponents(", ") + " buff. (20 turns)");
        resource_entries.listAppend(ChecklistEntryMake(540, "__skill Visit your Favorite Bird", "skillz.php", ChecklistSubentryMake("Visit your favourite bird", "", description), 5).ChecklistEntryTag("bird-a-day calendar").ChecklistEntrySetCategory("buff"));
    }
}
	
	
