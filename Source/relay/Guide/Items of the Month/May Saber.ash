RegisterTaskGenerationFunction("IOTMMaySaberPartyGenerateTasks");
void IOTMMaySaberPartyGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($item[Fourth of May Cosplay Saber].available_amount() == 0) return;
    if (get_property_int("_saberMod") == 0)
    {
    	string [int] options;
        if (in_ronin())
        {
	        options.listAppend("Regen ~17 MP/adventure.");
        	options.listAppend("+20 ML.");
        	options.listAppend("+3 all resistances.");
        }
        options.listAppend("+10 familiar weight.");
        
    	string [int] description;
        if (options.count() > 1)
	        description.listAppend("Choose one of:|*" + options.listJoinComponents("|*"));
        else
        	description.listAppend(options.listJoinComponents("|"));
        optional_task_entries.listAppend(ChecklistEntryMake("__item Fourth of May Cosplay Saber", "main.php?action=may4", ChecklistSubentryMake("Modify your lightsaber", "", description), 8));
    }
    monster saber_monster = get_property_monster("_saberForceMonster");
    if (saber_monster != $monster[none] && get_property_int("_saberForceMonsterCount") > 0)
    {
    	string [int] description;
        int fights_left = clampi(get_property_int("_saberForceMonsterCount"), 0, 3);
        string url = "";
        location [int] possible_appearance_locations = saber_monster.getPossibleLocationsMonsterCanAppearInNaturally().listInvert();
        
        description.listAppend("Will appear when you adventure in " + possible_appearance_locations.listJoinComponents(", ", "or") + ".");
        if (possible_appearance_locations.count() > 0)
        	url = possible_appearance_locations[0].getClickableURLForLocation(); 
        optional_task_entries.listAppend(ChecklistEntryMake("__monster " + saber_monster, url, ChecklistSubentryMake("Fight " + pluralise(fights_left, "more " + saber_monster, "more " + saber_monster + "s"), "", description), -1));
    }
}

RegisterResourceGenerationFunction("IOTMMaySaberGenerateResource");
void IOTMMaySaberGenerateResource(ChecklistEntry [int] resource_entries)
{
	if ($item[Fourth of May Cosplay Saber].available_amount() == 0) return;
	if (get_property_int("_saberForceUses") < 5)
	{
		int uses_remaining = clampi(5 - get_property_int("_saberForceUses"), 0, 5);
		string url = generateEquipmentLink($item[Fourth of May Cosplay Saber]);
        string [int] description;
        description.listAppend("Use the force skill in combat, which lets you:");
        description.listAppend("Banish a monster for thirty turns.");
        description.listAppend("Make the monster appear 3x times in the zone.");
        description.listAppend("Or collect all* their items.");
        if (my_path_id() == PATH_COMMUNITY_SERVICE && $skill[Meteor Lore].have_skill())
        {
        	description.listAppend("Bonus! Use Meteor Shower + lightsaber skill to save a bunch of turns on weapon damage/spell damage/familiar weight tests.");
        }
        //description.listAppend("Choose one of:|*" + options.listJoinComponents("|*"));
        resource_entries.listAppend(ChecklistEntryMake("__item Fourth of May Cosplay Saber", url, ChecklistSubentryMake(pluralise(uses_remaining, "force use", "forces uses"), "", description), 0));
		
	}
	
}
