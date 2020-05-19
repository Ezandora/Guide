RegisterLowKeyGenerationFunction("PathLowKeyGenerateKeys");
void PathLowKeyGenerateKeys(ChecklistEntry [int] low_key_entries) {

    if (my_path_id() != PATH_LOW_KEY_SUMMER) return;
    if (!__misc_state["in run"]) return;
    if (QuestState("Lair").state_boolean["past keys"]) return;	

    record Key {
        string name;
        location zone;
        string url;
        string enchantment;
    };

    Key [int] keys;
    keys[0] = new Key("Actual skeleton key", $location[The Skeleton Store], "place.php?whichplace=town_market", "+100 Damage Absorption, +10 Damage Reduction");
    keys[1] = new Key("Anchovy can key", $location[The Haunted Pantry], "place.php?whichplace=manor1", "+100% Food Drops");
    keys[2] = new Key("Aquí", $location[South of the Border], "place.php?whichplace=desertbeach", "+3 Hot Res, +15 Hot Damage, +30 Hot Spell Damage");
    keys[3] = new Key("Batting cage key", $location[The Bat Hole Entrance], "place.php?whichplace=bathole", "+3 Stench Res, +15 Stench Damage, +30 Stench Spell Damage");
    keys[4] = new Key("Black rose key", $location[The Haunted Conservatory], "place.php?whichplace=manor1", "+5 Familiar Weight, +2 Familiar Exp");
    keys[5] = new Key("Cactus key", $location[The Arid, Extra-Dry Desert], "place.php?whichplace=desertbeach", "Regen HP, Max HP +20");
    keys[6] = new Key("Clown car key", $location[The \"Fun\" House], "place.php?whichplace=plains", "+10 Prismatic Damage, +10 ML");
    keys[7] = new Key("Deep-fried key", $location[Madness Bakery], "place.php?whichplace=town_right", "+3 Sleaze Res, +15 Sleaze Damage, +30 Sleaze Spell Damage");
    keys[8] = new Key("Demonic key", $location[Pandamonium Slums], "pandamonium.php", "+20% Myst Gains, Myst +5, -1 MP Skills");
    keys[9] = new Key("Discarded bike lock key", $location[The Overgrown Lot], "place.php?whichplace=town_wrong", "Max MP + 10, Regen MP");
    keys[10] = new Key("F'c'le sh'c'le k'y", $location[The F\'c\'le], "place.php?whichplace=cove", "+20 ML");
    keys[11] = new Key("Ice key", $location[The Icy Peak], "place.php?whichplace=mclargehuge", "+3 Cold Res, +15 Cold Damage, +30 Cold Spell Damage");
    keys[12] = new Key("Kekekey", $location[The Valley of Rof L\'m Fao], "place.php?whichplace=mountains", "+50% Meat");
    keys[13] = new Key("Key sausage", $location[Cobb\'s Knob Kitchens], "place.php?whichplace=cobbsknob", "-10% Combat");
    keys[14] = new Key("Knob labinet key", $location[Cobb\'s Knob Laboratory], "cobbsknob.php?action=tolabs", "+20% Muscle Gains, Muscle +5, -1 MP Skills");
    keys[15] = new Key("Knob shaft skate key", $location[The Knob Shaft], "cobbsknob.php?action=tolabs", "Regen HP/MP, +3 Adventures");
    keys[16] = new Key("Knob treasury key", $location[Cobb\'s Knob Treasury], "place.php?whichplace=cobbsknob", "+50% Meat, +20% Pickpocket");
    keys[17] = new Key("Music Box Key", $location[The Haunted Nursery], "place.php?whichplace=manor3", "+10% Combat");
    keys[18] = new Key("Peg key", $location[The Obligatory Pirate\'s Cove], "place.php?whichplace=island", "+5 Stats");
    keys[19] = new Key("Rabbit\'s foot key", $location[The Dire Warren], "tutorial.php", "All Attributes +10");
    keys[20] = new Key("Scrap metal key", $location[The Old Landfill], "place.php?whichplace=woods", "+20% Moxie Gains, Moxie +5, -1MP Skills");
    keys[21] = new Key("Treasure chest key", $location[Belowdecks], "place.php?whichplace=cove", "+30% Item, +30% Meat");
    keys[22] = new Key("Weremoose key", $location[Cobb\'s Knob Menagerie, Level 2], "cobbsknob.php?action=tomenagerie", "+3 Spooky Res, +15 Spooky Damage, +30 Spooky Spell Damage");

    foreach index, key in keys {
        ChecklistEntry entry;
        entry.image_lookup_name = "__item " + key.name;
        entry.url = key.url;

        // Title
        string title = key.name;

        // Subtitle
        string subtitle = key.enchantment;

        // Entries
        string [int] description;
        int turnsSpent = key.zone.turns_spent;

        print(__quest_state["Level 13"].state_boolean["Actual skeleton key used"]);

        // Set unlock messages
        switch(key.name) {
            case "Actual skeleton key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by accepting the meathsmith\'s quest");
                    entry.url = "shop.php?whichshop=meatsmith";
                }
                break;
            case "Aquí":
                if(!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by getting access to the desert beach");
                    entry.url = "";
                }
                break;
            case "Batting cage key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by starting the boss bat quest");
                    entry.url = "";
                }
                break;
            case "Cactus key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by reading the diary in the McGuffin quest");
                    entry.url = "";
                }
                break;
            case "Clown car key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the nemesis quest");
                    entry.url = "";
                }
                break;
            case "Deep-fried key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by accepting the Armorer and Leggerer\'s quest");
                    entry.url = "shop.php?whichshop=armory";
                }
                break;
            case "Demonic key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by finishing the Friars quest");
                    entry.url = "";
                }
                break;
            case "Discarded bike lock key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by accepting Doc Galaktik\'s quest");
                    entry.url = "shop.php?whichshop=doc";
                }
                break;
            case "F'c'le sh'c'le k'y":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the pirate\'s quest");
                    entry.url = "";
                }               
                break;
            case "Ice key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the trapper quest");
                    entry.url = "";
                }
                break;
            case "Kekekey":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by finishing the chasm quest");
                    entry.url = "";
                }
                break;
            case "Key sausage":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the Cobb\'s Knob quest");
                    entry.url = "";
                }
                break;
            case "Knob labinet key":    
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by finding the Cobb's Knob lab key during the Cobb\'s Knob quest");
                    entry.url = "";
                }
                break;
            case "Knob shaft skate key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by finding the Cobb's Knob lab key during the Cobb\'s Knob quest");
                    entry.url = "";
                }
                break;
            case "Knob treasury key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the Cobb\'s Knob quest");
                    entry.url = "";
                }
                break;
            case "Music Box Key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the Spookyraven quest");
                    entry.url = "";
                }     
                break;
            case "Peg key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the pirate\'s quest");
                    entry.url = "";
                }     
                break;
            case "Scrap metal key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by starting the Old Landfill quest");
                    entry.url = "";
                }     
                break;
            case "Treasure chest key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by doing the pirate\'s quest'");
                    entry.url = "";
                }     
                break;
            case "weremoose key":
                if (!key.zone.locationAvailable()) {
                    description.listAppend("Unlock " + key.zone + " by finding the  Cobb\'s Knob Menagerie key in the Cobb\'s Knob lab");
                    entry.url = "";
                }
                break;
        }

        // Set delay messages
        if (description.count() == 0) {
            if (turnsSpent < 11) {
                description.listAppend((11 - turnsSpent) + " more delay in " + key.zone);
            } else {
                description.listAppend("Next turn in " + key.zone);
            }
        }

        ChecklistSubentry keyEntry = ChecklistSubentryMake(title, subtitle, description);
        entry.subentries.listAppend(keyEntry);
    
         if (lookupItem(key.name).available_amount() == 0) {
            low_key_entries.listAppend(entry);
        }
    }
}

RegisterLowKeyGenerationFunction("PathLowKeyGenerateStandardKeys");
void PathLowKeyGenerateStandardKeys(ChecklistEntry [int] low_key_entries) {
    if (!__quest_state["Level 13"].state_boolean["past keys"]) {		

        // Skeleton Key
		if ($item[skeleton key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["skeleton key used"]) {
			string line = "loose teeth";
			if ($item[loose teeth].available_amount() == 0)
				line += " (need)";
			else
				line += " (have)";
			line += " + skeleton bone";
			if ($item[skeleton bone].available_amount() == 0)
				line += " (need)";
			else
				line += " (have)";
			low_key_entries.listAppend(ChecklistEntryMake("__item skeleton key", $location[the defiled nook].getClickableURLForLocation(), ChecklistSubentryMake("Skeleton key", "", line)));
		}
		
        // Digital key
		if ($item[digital key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["digital key used"]) {
			string [int] options;
            if ($item[digital key].creatable_amount() > 0) {
                options.listAppend("Have enough pixels, make it.");
            }
            else
            {
                options.listAppend("Fear man's level (jar)");
                if (__misc_state["fax equivalent accessible"] && in_hardcore()) //not suggesting this in SC
                    options.listAppend("Fax/copy a ghost");
                options.listAppend("8-bit realm (olfact blooper, slow)");
                if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
                    options.listAppend("Wait for pixellated monsters");
                
                int total_white_pixels = $item[white pixel].available_amount() + $item[white pixel].creatable_amount();
                if (total_white_pixels > 0)
                    options.listAppend(total_white_pixels + "/30 white pixels found.");
            }
			low_key_entries.listAppend(ChecklistEntryMake("__item digital key", "", ChecklistSubentryMake("Digital key", "", options)));
		}

        // Star key
        if (!__misc_state["in run"] && !__misc_state["Example mode"])
		    return;
        if (__quest_state["Level 13"].state_boolean["Richard\'s star key used"])
            return;

        string url = $location[the hole in the sky].getClickableURLForLocation();
        if (!$location[the hole in the sky].locationAvailable())
            url = $location[The Castle in the Clouds in the Sky (basement)].getClickableURLForLocation();
        if ($item[richard\'s star key].available_amount() == 0)
        {
            string [int] oh_my_stars_and_gauze_garters;
            oh_my_stars_and_gauze_garters.listAppend(MIN(1, $item[star chart].available_amount()) + "/1 star chart");
            oh_my_stars_and_gauze_garters.listAppend(MIN(8, $item[star].available_amount()) + "/8 stars");
            oh_my_stars_and_gauze_garters.listAppend(MIN(7, $item[line].available_amount()) + "/7 lines");
            low_key_entries.listAppend(ChecklistEntryMake("__item richard\'s star key", url, ChecklistSubentryMake("Richard\'s star key", "", oh_my_stars_and_gauze_garters.listJoinComponents(", ", "and"))));
        }

        // Sneaky Pete key
		string from_daily_dungeon_string = "From daily dungeon";
		if ($item[fat loot token].available_amount() > 0)
			from_daily_dungeon_string += "|" + pluralise($item[fat loot token]) + " available";
		if ($item[sneaky pete\'s key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["Sneaky Pete\'s key used"])
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			low_key_entries.listAppend(ChecklistEntryMake("__item Sneaky Pete\'s key", "da.php", ChecklistSubentryMake("Sneaky Pete\'s key", "", options)));
		}

        // Jarlsberg Key
		if ($item[jarlsberg\'s key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["Jarlsberg\'s key used"])
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			low_key_entries.listAppend(ChecklistEntryMake("__item jarlsberg's key", "da.php", ChecklistSubentryMake("Jarlsberg's key", "", options)));
		}

        // Boris Key
		if ($item[Boris\'s key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["Boris\'s key used"])
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			low_key_entries.listAppend(ChecklistEntryMake("__item Boris's key", "da.php", ChecklistSubentryMake("Boris's key", "", options)));
		}
	}
}
	