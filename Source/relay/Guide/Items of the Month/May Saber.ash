RegisterTaskGenerationFunction("IOTMMaySaberPartyGenerateTasks");
void IOTMMaySaberPartyGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (lookupItem("Fourth of May Cosplay Saber").available_amount() == 0) return;
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
	if (lookupItem("Fourth of May Cosplay Saber").available_amount() == 0) return;
	if (get_property_int("_saberForceUses") < 5) {
		int uses_remaining = clampi(5 - get_property_int("_saberForceUses"), 0, 5);
		string url = "";
        if (!lookupItem("Fourth of May Cosplay Saber").equipped())
        	url = "inventory.php?ftext=fourth+of+may+cosplay+saber";
        string [int] description;
        description.listAppend("Use the force skill in combat, which lets you:");
        description.listAppend("Banish a monster for thirty turns.");
        description.listAppend("Make the monster appear 3x times in the zone.");
        description.listAppend("Or collect all* their items.");
        if (myPathId() == PATH_COMMUNITY_SERVICE && $skill[Meteor Lore].have_skill())
        {
        	description.listAppend("Bonus! Use Meteor Shower + lightsaber skill to save a bunch of turns on weapon damage/spell damage/familiar weight tests.");
        }
        //description.listAppend("Choose one of:|*" + options.listJoinComponents("|*"));
        resource_entries.listAppend(ChecklistEntryMake("__item Fourth of May Cosplay Saber", url, ChecklistSubentryMake(pluralise(uses_remaining, "force use", "forces uses"), "", description), 0));
	}	
}

RegisterResourceGenerationFunction("IOTMMaySaberBanishResource");
void IOTMMaySaberBanishResource(ChecklistEntry [int] resource_entries) {

    int banishesAvailable = clampi(5 - get_property_int("_saberForceUses"), 0, 5);

    ChecklistSubentry getBanishes() {
        // Title
        string main_title = banishesAvailable + " force uses";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;

        if (banishesAvailable > 0) {
            if (!have_equipped(lookupItem("Fourth of May Cosplay Saber"))) {
                description.listAppend(HTMLGenerateSpanFont("Equip the Fourth of May saber first", "red"));
            } else {
                description.listAppend("Free run/banish");
            }
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (lookupItem("Fourth of May Cosplay Saber").available_amount() == 0) return;
	
    ChecklistEntry entry;
    entry.ChecklistEntryTagEntry("banish");
    entry.image_lookup_name = "__item Fourth of May Cosplay Saber";
    entry.url = "inventory.php?which=2";

    if (banishesAvailable > 0) {
        ChecklistSubentry banishes = getBanishes();
        entry.subentries.listAppend(banishes);
    }
    
    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}