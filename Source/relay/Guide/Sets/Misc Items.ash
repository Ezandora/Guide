void SMiscItemsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	int importance_level_item = 7;
	int importance_level_unimportant_item = 8;
    
    boolean in_run = __misc_state["In run"];
    
	int navel_percent_chance_of_runaway = 20;
	if (true)
	{
        //Look up navel ring chances:
		int [int] navel_ring_runaway_chance;
		navel_ring_runaway_chance[0] = 100;
		navel_ring_runaway_chance[1] = 100;
		navel_ring_runaway_chance[2] = 100;
		navel_ring_runaway_chance[3] = 80;
		navel_ring_runaway_chance[4] = 80;
		navel_ring_runaway_chance[5] = 80;
		navel_ring_runaway_chance[6] = 50;
		navel_ring_runaway_chance[7] = 50;
		navel_ring_runaway_chance[8] = 50;
		navel_ring_runaway_chance[9] = 20;
		int navel_runaway_progress = get_property_int("_navelRunaways");
        
		if (navel_ring_runaway_chance contains navel_runaway_progress)
            navel_percent_chance_of_runaway = navel_ring_runaway_chance[navel_runaway_progress];
	}
	
	if ($item[navel ring of navel gazing].available_amount() > 0)
	{
		string name = "Navel Ring runaways";
        
        string url = "";
        if ($item[navel ring of navel gazing].equipped_amount() == 0)
            url = "inventory.php?which=2";
		
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item navel ring of navel gazing", url, ChecklistSubentryMake(name, "", description)));
	}
	
	if ($item[greatest american pants].available_amount() > 0)
	{
		string name = "Greatest American Pants";
		
        string url = "";
        if ($item[greatest american pants].equipped_amount() == 0)
            url = "inventory.php?which=2";
        
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
        
        int buffs_remaining = 5 - get_property_int("_gapBuffs");
        if (buffs_remaining > 0)
            description.listAppend(pluralize(buffs_remaining, "buff", "buffs") + " remaining.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item greatest american pants", url, ChecklistSubentryMake(name, "", description)));
	}
	if ($item[peppermint parasol].available_amount() > 0 && in_run) //don't think we want to use the parasol in aftercore, it's expensive
	{
		int parasol_progress = get_property_int("parasolUsed");
		string name = "";
		
		name = parasol_progress + "/10 peppermint parasol uses";
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
		available_resources_entries.listAppend(ChecklistEntryMake("__item peppermint parasol", "", ChecklistSubentryMake(name, "", description)));
	}
	if ($item[pantsgiving].available_amount() > 0)
	{
		ChecklistSubentry subentry = ChecklistSubentryMake("Pantsgiving", "", "");
        
        string url = "";
        
        if ($item[pantsgiving].equipped_amount() == 0)
            url = "inventory.php?which=2";
		
		
		int banishes_available = 5 - get_property_int("_pantsgivingBanish");
		if (banishes_available > 0)
        subentry.entries.listAppend(pluralize(banishes_available, "banish", "banishes") + " available.");
        
		int pantsgiving_fullness_used = get_property_int("_pantsgivingFullness");
		int pantsgiving_adventures_used = get_property_int("_pantsgivingCount");
		int pantsgiving_pocket_crumbs_found = get_property_int("_pantsgivingCrumbs");
		int pantsgiving_potential_crumbs_remaining = 10 - pantsgiving_pocket_crumbs_found;
		
		int adventures_needed_for_fullness_boost = 5 * powi(10, pantsgiving_fullness_used);
		int adventures_needed_for_fullness_boost_x2 = 5 * powi(10, 1 + pantsgiving_fullness_used);
		int adventures_needed_for_fullness_boost_x3 = 5 * powi(10, 2 + pantsgiving_fullness_used);
		int adventures_needed_for_fullness_boost_x4 = 5 * powi(10, 3 + pantsgiving_fullness_used);
		
		if (adventures_needed_for_fullness_boost > pantsgiving_adventures_used)
		{
			int number_left = adventures_needed_for_fullness_boost - pantsgiving_adventures_used;
			subentry.entries.listAppend(pluralize(number_left, "adventure", "adventures") + " until next fullness.");
		}
		else //already there
		{
			string extra_fullness_available = "Fullness";
			if (pantsgiving_adventures_used > adventures_needed_for_fullness_boost_x2)
                extra_fullness_available = "2x fullness";
			if (pantsgiving_adventures_used > adventures_needed_for_fullness_boost_x3)
                extra_fullness_available = "3x fullness";
			if (pantsgiving_adventures_used > adventures_needed_for_fullness_boost_x4)
                extra_fullness_available = "4x fullness (wh.. what?)";
			if (availableFullness() == 0)
			{
				subentry.entries.listAppend(extra_fullness_available + " available next adventure.");
			}
			else
                subentry.entries.listAppend(extra_fullness_available + " available when you're full.");
		}
		
		if (pantsgiving_potential_crumbs_remaining > 0)
			subentry.entries.listAppend(pluralize(pantsgiving_potential_crumbs_remaining, " pocket crumb item", " pocket crumb items") + " left.");
		
		if (subentry.entries.count() > 0)
		{
			ChecklistEntry entry = ChecklistEntryMake("__item pantsgiving", url, subentry);
			entry.should_indent_after_first_subentry = true;
			available_resources_entries.listAppend(entry);
		}
	}
    
    
    
    if (__misc_state["free runs usable"] && in_run && $item[bottle of blank-out].available_amount() > 0)
	{
		string [int] description;
		string name;
		int blankout_count = $item[bottle of blank-out].available_amount();
		name += pluralize(blankout_count, "blank-out", "blank-out");
        
		if ($item[glob of blank-out].available_amount() == 0)
            description.listAppend("Use blank-out for glob.");
        if (get_property_boolean("_blankOutUsed"))
            description.listAppend("Will have to wait until tomorrow to open.");
        
		available_resources_entries.listAppend(ChecklistEntryMake("__item Bottle of Blank-Out", "inventory.php?which=3", ChecklistSubentryMake(name, "", description)));
	}
    if (__misc_state["free runs usable"] && $item[glob of blank-out].available_amount() > 0)
    {
		int uses_remaining = 5 - get_property_int("blankOutUsed");
		string [int] description;
		string name;
        description.listAppend("Use glob of blank-out in combat.");
        if (!in_run)
            description.listAppend("Will disappear when you ascend.");
        
        name = pluralize(uses_remaining, "blank-out runaway", "blank-out runaways");
		available_resources_entries.listAppend(ChecklistEntryMake("__item glob of blank-out", "", ChecklistSubentryMake(name, "", description)));
    }

	if ($item[BitterSweetTarts].available_amount() > 0 && __misc_state["need to level"])
	{
		int modifier = min(11, my_level());
		string [int] description;
		description.listAppend("+" + modifier + " stats/fight, 10 turns");
		if (my_level() < 11)
		{
			description.listAppend("Wait until level 11 for full effectiveness");
		}
		available_resources_entries.listAppend(ChecklistEntryMake("__item BitterSweetTarts", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[BitterSweetTarts]), "", description), importance_level_item));
	}
	if ($item[polka pop].available_amount() > 0 && in_run)
	{
		int modifier = 5 * min(11, my_level());
		string [int] description;
        description.listAppend("+" + modifier + "% item, " + "+" + modifier + "% meat");
		if (my_level() < 11)
		{
			description.listAppend("Wait until level 11 for full effectiveness");
		}
		available_resources_entries.listAppend(ChecklistEntryMake("__item polka pop", "", ChecklistSubentryMake(pluralize($item[polka pop]), "10 turns", description), importance_level_item));
	}
        
    if ($item[frost flower].available_amount() > 0 && in_run)
    {
        string [int] description;
        description.listAppend("+100% item, +200% meat, +25 ML, +100% init");
        available_resources_entries.listAppend(ChecklistEntryMake("__item frost flower", "inventory.php?which=3", ChecklistSubentryMake($item[frost flower].pluralize(), "50 turns", description), importance_level_item));
    }
	if (in_run)
	{
		string [item] resolution_descriptions;
		resolution_descriptions[$item[resolution: be happier]] = "+15% item (20 turns)";
		//resolution_descriptions[$item[resolution:be feistier]] = "+20 spell damage"; //information overload?
		if (__misc_state["need to level"])
		{
			resolution_descriptions[$item[resolution: be stronger]] = "+2 muscle stats/combat (20 turns)";
			resolution_descriptions[$item[resolution: be smarter]] = "+2 mysticality stats/combat (20 turns)";
			resolution_descriptions[$item[resolution: be sexier]] = "+2 moxie stats/combat (20 turns)";
		}
		resolution_descriptions[$item[resolution: be kinder]] = "+5 familiar weight (20 turns)";
		resolution_descriptions[$item[resolution: be luckier]] = "+5% item, +5% meat, +10% init, others (20 turns)"; //???
        if (my_path_id() != PATH_SLOW_AND_STEADY)
            resolution_descriptions[$item[resolution: be more adventurous]] = "+2 adventures at rollover";
		resolution_descriptions[$item[resolution: be wealthier]] = "+30% meat";
        
        
	
		ChecklistSubentry [int] resolution_lines;
		foreach it in resolution_descriptions
		{
			if (it.available_amount() == 0)
				continue;
			string description = resolution_descriptions[it];
			
			resolution_lines.listAppend(ChecklistSubentryMake(pluralize(it), "",  description));
		}
		if (resolution_lines.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item resolution: be luckier", "inventory.php?which=3", resolution_lines, importance_level_item));
			
	}
	if (in_run)
	{
        //doesn't show how much, because wahh I don't wanna write taffy code
		string [item] taffy_descriptions;
		taffy_descriptions[$item[pulled yellow taffy]] = "+meat, +item";
		if (__misc_state["need to level"])
		{
            taffy_descriptions[$item[pulled red taffy]] = "+moxie stats/fight";
            taffy_descriptions[$item[pulled orange taffy]] = "+muscle stats/fight";
            taffy_descriptions[$item[pulled violet taffy]] = "+mysticality stats/fight";
		}
		taffy_descriptions[$item[pulled blue taffy]] = "+familiar weight, +familiar experience";
        string image_name = "";
		ChecklistSubentry [int] taffy_lines;
		foreach it in taffy_descriptions
		{
			if (it.available_amount() == 0)
				continue;
			string description = taffy_descriptions[it];
			if (image_name == "")
                image_name = "__item " + it;
			taffy_lines.listAppend(ChecklistSubentryMake(pluralize(it), "",  description));
		}
		if (taffy_lines.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake(image_name, "", taffy_lines, importance_level_item));
			
	}
	
	
	
	if (in_run)
	{
		if (7014.to_item().available_amount() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item " + 7014.to_item().to_string(), "", ChecklistSubentryMake(pluralize(7014.to_item()), "", "Free run, banish for 20 turns"), importance_level_item));
		if ($item[crystal skull].available_amount() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item crystal skull", "", ChecklistSubentryMake(pluralize($item[crystal skull]), "", "Turn-costing banishing"), importance_level_item));
            
		if ($item[harold's bell].available_amount() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item harold's bell", "", ChecklistSubentryMake(pluralize($item[harold's bell]), "", "Turn-costing banishing"), importance_level_item));
        
		if ($item[lost key].available_amount() > 0)
        {
            string [int] details;
            details.listAppend("Lost pill bottle is mini-fridge, take a nap, open the pill bottle.");
            //FIXME does stunning work on tower monsters?
            //if (!__quest_state["Level 13"].state_boolean["past tower monsters"] && (!$item[munchies pill].is_unrestricted() || !__misc_state["can eat just about anything"]))
                //details.listAppend("The lost comb is turn on the TV, take a nap, pick up the comb. (towerkilling)");
            if ($classes[pastamancer,sauceror] contains my_class() && $skill[Transcendental Noodlecraft].skill_is_usable() && $skill[The Way of Sauce].skill_is_usable() && $skill[pulverize].skill_is_usable())
                details.listAppend("The lost glasses is mini-fridge, TV, glasses.|Smash for elemental nuggets for hi meins.");
			available_resources_entries.listAppend(ChecklistEntryMake("__item lost key", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[lost key]), "", details), importance_level_item));
        }
			
		if ($item[soft green echo eyedrop antidote].available_amount() > 0 && $skill[Transcendent Olfaction].skill_is_usable())
			available_resources_entries.listAppend(ChecklistEntryMake("__item soft green echo eyedrop antidote", "", ChecklistSubentryMake(pluralize($item[soft green echo eyedrop antidote]), "", "Removes on the trail, teleportitis"), importance_level_unimportant_item));
			
		if ($item[sack lunch].available_amount() > 0)
		{
			string [int] description;
			int importance = importance_level_item;
			if (my_level() < 11)
			{
				description.listAppend("Wait until level 11+ to open for best food.");
				importance = importance_level_unimportant_item;
			}
			else
			{
				description.listAppend("Safe to open.");
			}
			available_resources_entries.listAppend(ChecklistEntryMake("__item sack lunch", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[sack lunch]), "", description), importance));
		}
        
        if (true)
        {
			ChecklistSubentry [int] subentries;
            string image_name = "";
            
            string [item] descriptions;
            descriptions[$item[NPZR chemistry set]] = "Open for 20 invisibility/irresistibility/irritability potions.";
            descriptions[$item[invisibility potion]] = "-5% combat (20 turns)";
            descriptions[$item[irresistibility potion]] = "+5% combat (20 turns)";
            descriptions[$item[irritability potion]] = "+15 ML (20 turns)";
            
            foreach it in $items[NPZR chemistry set,invisibility potion,irresistibility potion,irritability potion]
            {
                if (it.available_amount() == 0)
                    continue;
                if (image_name.length() == 0)
                    image_name = "__item " + it;
                    
                subentries.listAppend(ChecklistSubentryMake(pluralize(it), "", descriptions[it]));
            }
            
            if (subentries.count() > 0)
                available_resources_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=3", subentries, importance_level_item));
        }
	}
	if ($item[smut orc keepsake box].available_amount() > 0 && !__quest_state["Level 9"].state_boolean["bridge complete"] && __misc_state["In run"])
		available_resources_entries.listAppend(ChecklistEntryMake("__item smut orc keepsake box", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[smut orc keepsake box]), "", "Open for bridge building."), 0));
		
		
	int clovers_available = $items[disassembled clover,ten-leaf clover].available_amount();
	if (clovers_available > 0 && in_run)
	{
		ChecklistSubentry subentry;
		subentry.header = pluralize(clovers_available, "clover", "clovers") + " available";
        
		
		if (!__quest_state["Level 9"].state_boolean["bridge complete"])
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Orc logging camp, for bridge building", $location[the smut orc logging camp]));
		if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0 || !__quest_state["Level 9"].state_boolean["bridge complete"])
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("A-Boo clues", $location[a-boo peak]));
		if (__misc_state["wand of nagamar needed"] && $item[wand of nagamar].creatable_amount() == 0)
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Wand of nagamar components (castle basement)", $location[the castle in the clouds in the sky (basement)]));
		boolean have_all_gum = $item[pack of chewing gum].available_amount() > 0 || ($item[jaba&ntilde;ero-flavored chewing gum].available_amount() > 0 && $item[lime-and-chile-flavored chewing gum].available_amount() > 0 && $item[pickle-flavored chewing gum].available_amount() > 0 && $item[tamarind-flavored chewing gum].available_amount() > 0);
		if (__quest_state["Level 4"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() < 2)
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("2 sonar-in-a-biscuit (Guano Junction)", $location[guano junction]));
		if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && !(get_property_boolean("lovebugsUnlocked") && lookupItem("bottle of lovebug pheromones").is_unrestricted())) //taking a gamble here - I'm assuming you'd never clover for ultrahydrated if you have lovebugs. even if you run out of ultrahydrated, you'll likely get it again in a hurry
        {
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Ultrahydrated (Oasis)", $location[the oasis]));
        }
		if (__misc_state["need to level"] && !__misc_state["Stat gain from NCs reduced"])
        {
            location l = $location[none];
            if (my_primestat() == $stat[moxie])
                l = $location[the haunted ballroom];
            else if (my_primestat() == $stat[mysticality])
                l = $location[the haunted bathroom];
            else if (my_primestat() == $stat[muscle])
                l = $location[the haunted gallery];
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Powerlevelling (" + l + ")", l));
        }
		//put relevant tower items here
		
		available_resources_entries.listAppend(ChecklistEntryMake("clover", "", subentry, 7));
	}
	if (in_run)
	{
		if ($item[gameinformpowerdailypro magazine].available_amount() > 0)
		{
			string [int] description;
			description.listAppend("Zero-turn free SGEAA and scrolls");
			available_resources_entries.listAppend(ChecklistEntryMake("__item gameinformpowerdailypro magazine", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[gameinformpowerdailypro magazine]), "", description), importance_level_unimportant_item));
		}
	}
    if ($item[divine champagne popper].available_amount() > 0 && in_run)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item divine champagne popper", "", ChecklistSubentryMake(pluralize($item[divine champagne popper]), "", "Free run and five-turn banish."), importance_level_unimportant_item));
    }
    if (__misc_state["need to level"])
    {
		if ($item[dance card].available_amount() > 0 && my_primestat() == $stat[moxie])
        {
			string [int] description;
			description.listAppend("Gain ~" + round(__misc_state_float["dance card average stats"]) + " mainstat from delayed adventure in the haunted ballroom.");
			available_resources_entries.listAppend(ChecklistEntryMake("__item dance card", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[dance card]), "", description), importance_level_unimportant_item));
        }
    }
	if ($item[stone wool].available_amount() > 0)
	{
		string [int] description;
		
		int quest_needed = 2;
		if ($item[the nostril of the serpent].available_amount() > 0)
			quest_needed -= 1;
		if (locationAvailable($location[the hidden park]))
			quest_needed = 0;
		
		if (quest_needed > 0)
			description.listAppend(quest_needed + " to unlock hidden city");
		if (__misc_state["need to level"])
			description.listAppend("Cave bar");
		if (get_property_int("lastTempleAdventures") != my_ascensions())
        {
            string line = "+3 adventures, +3 duration to ten effects. (once/ascension)";
            if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
                line += "|Can use to extend effects at nuns.";
			description.listAppend(line);
        }
		if (description.count() > 0)
			available_resources_entries.listAppend(ChecklistEntryMake("__item stone wool", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[stone wool]), "", description), importance_level_unimportant_item));
	}
    if ($item[the legendary beat].available_amount() > 0 && !get_property_boolean("_legendaryBeat"))
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item The Legendary Beat", "inventory.php?which=3", ChecklistSubentryMake("The Legendary Beat", "", "+50% item. (20 turns)"), importance_level_item));
        
    }
    item zap_wand_owned;
	if (true)
	{
		zap_wand_owned = $item[none];
		foreach wand in $items[aluminum wand,ebony wand,hexagonal wand,marble wand,pine wand]
		{
			if (wand.available_amount() > 0)
			{
				zap_wand_owned = wand;
				break;
			}
		}
		if (zap_wand_owned != $item[none])
		{
            string url = "wand.php?whichwand=" + zap_wand_owned.to_int();
			int zaps_used = get_property_int("_zapCount");
			string [int] details;
			if (zaps_used == 0)
				details.listAppend("Can zap safely.");
			else
            {
                float [int] chances;
                chances[1] = 75.0;
                chances[2] = 18.75;
                chances[3] = 1.5625;
                float chance = chances[zaps_used];
                
                if (zaps_used >= 4)
                    details.listAppend("Warning: Cannot zap.");
                else
					details.listAppend("Warning: " + roundForOutput(100.0 - chance, 1) + "% chance of explosion.");
				if ($item[Platinum Yendorian Express Card].available_amount() > 0 && !get_property_boolean("expressCardUsed"))
					details.listAppend("Platinum Yendorian Express Card usable.");
            }
			available_resources_entries.listAppend(ChecklistEntryMake(zap_wand_owned, url, ChecklistSubentryMake(pluralize(zaps_used, "zap", "zaps") + " used with " + zap_wand_owned, "", details), 10));
		}
	}
    
    if (!get_property_boolean("_defectiveTokenChecked") && get_property_int("lastArcadeAscension") == my_ascensions())
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item jackass plumber home game", "place.php?whichplace=arcade", ChecklistSubentryMake("Broken arcade game", "", "May find a defective game grid token."), importance_level_item));
    }
    if (lookupItem("picky tweezers").available_amount() > 0 && !get_property_boolean("_pickyTweezersUsed"))
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item picky tweezers", "inventory.php?which=3", ChecklistSubentryMake("Picky tweezers", "", "Acquire a single atom."), importance_level_unimportant_item));
    }
    if ($item[defective Game Grid token].available_amount() > 0 && !get_property_boolean("_defectiveTokenUsed"))
    {
        string [int] description;
        description.listAppend("+5 to everything. (5 turns)");
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item defective Game Grid token", "inventory.php?which=3", ChecklistSubentryMake("Defective Game Grid Token", "", description), importance_level_item));
    }
    if ($item[Platinum Yendorian Express Card].available_amount() > 0 && !get_property_boolean("expressCardUsed"))
    {
        string [int] description;
        string line = "Extends buffs, restores HP";
        if (get_property_int("_zapCount") > 0 && zap_wand_owned != $item[none] && zap_wand_owned.available_amount() > 0)
            line += ", cools down " + zap_wand_owned;
        line += ".";
        description.listAppend(line);
        available_resources_entries.listAppend(ChecklistEntryMake("__item Platinum Yendorian Express Card", "", ChecklistSubentryMake("Platinum Yendorian Express Card", "", description), importance_level_item));
    }
    
    
    if ($item[mojo filter].available_amount() > 0 && get_property_int("currentMojoFilters") <3 && in_run)
    {
        int mojo_filters_usable = MIN(my_spleen_use(), MIN(3 - get_property_int("currentMojoFilters"), $item[mojo filter].available_amount()));
        string line = "Removes one spleen each.";
        if (mojo_filters_usable != $item[mojo filter].available_amount())
            line += "|" + pluralize(mojo_filters_usable, "filter", "filters") + " usable.";
        
        if (mojo_filters_usable > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__item mojo filter", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[mojo filter]), "", line), importance_level_unimportant_item));
    }
    if ($item[distention pill].available_amount() > 0 && !get_property_boolean("_distentionPillUsed") && in_run)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item distention pill", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[distention pill]), "", "Adds one extra fullness.|Once/day."), importance_level_unimportant_item));
    }
    if ($item[synthetic dog hair pill].available_amount() > 0 && !get_property_boolean("_syntheticDogHairPillUsed") && in_run)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item synthetic dog hair pill", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[synthetic dog hair pill]), "", "Adds one extra drunkenness.|Once/day."), importance_level_unimportant_item));
    }
    if ($item[the lost pill bottle].available_amount() > 0 && in_run)
    {
        string header = pluralize($item[the lost pill bottle]);
        if ($item[the lost pill bottle].available_amount() == 1)
            header = $item[the lost pill bottle];
        available_resources_entries.listAppend(ChecklistEntryMake("__item the lost pill bottle", "inventory.php?which=3", ChecklistSubentryMake(header, "", "Open it."), importance_level_unimportant_item));
    }
    if (__misc_state["need to level"])
    {
        if ($item[Marvin's marvelous pill].available_amount() > 0 && __misc_state["need to level moxie"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item Marvin's marvelous pill", "", ChecklistSubentryMake(pluralize($item[Marvin's marvelous pill]), "", "+20% to moxie gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[drum of pomade].available_amount() > 0 && __misc_state["need to level moxie"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item drum of pomade", "", ChecklistSubentryMake(pluralize($item[drum of pomade]), "", "+15% to moxie gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[baobab sap].available_amount() > 0 && __misc_state["need to level muscle"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item baobab sap", "", ChecklistSubentryMake(pluralize($item[baobab sap]), "", "+20% to muscle gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[desktop zen garden].available_amount() > 0 && __misc_state["need to level mysticality"])
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item desktop zen garden", "", ChecklistSubentryMake(pluralize($item[desktop zen garden]), "", "+20% to mysticality gains. (10 turns)"), importance_level_unimportant_item));
        }
    }
    if ($item[munchies pill].available_amount() > 0 && fullness_limit() > 0 && in_run && my_path_id() != PATH_SLOW_AND_STEADY)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item munchies pill", "", ChecklistSubentryMake(pluralize($item[munchies pill]), "", "+3 turns from fortune cookies and other low-fullness foods."), importance_level_unimportant_item));
    }
    if ($item[snow cleats].available_amount() > 0 && in_run)
        available_resources_entries.listAppend(ChecklistEntryMake("__item snow cleats", "", ChecklistSubentryMake(pluralize($item[snow cleats]), "", "-5% combat, 30 turns."), importance_level_item));
        
    if ($item[vitachoconutriment capsule].available_amount() > 0 && get_property_int("_vitachocCapsulesUsed") <3 && in_run)
    {
        string [int] adventures_remaining;
        int capsules_remaining = $item[vitachoconutriment capsule].available_amount();
        int vita_used = get_property_int("_vitachocCapsulesUsed");
        if (vita_used < 1)
        {
            adventures_remaining.listAppend("+5");
            vita_used += 1;
            capsules_remaining -= 1;
        }
        if (vita_used < 2 && capsules_remaining > 0)
        {
            adventures_remaining.listAppend("+3");
            vita_used += 1;
            capsules_remaining -= 1;
        }
        if (vita_used < 3 && capsules_remaining > 0)
        {
            adventures_remaining.listAppend("+1");
        }
        string line;
        line = adventures_remaining.listJoinComponents("/") + " adventures";
        if (adventures_remaining.count() == 1) //hacky
        {
            if (adventures_remaining[0] == "+1")
                line = "+1 adventure";
        }
        line += ".";
        available_resources_entries.listAppend(ChecklistEntryMake("__item vitachoconutriment capsule", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[vitachoconutriment capsule]), "", line), importance_level_unimportant_item));
    }
    
    if ($item[drum machine].available_amount() > 0 && in_run && (my_adventures() <= 1 || (availableDrunkenness() < 0 && availableDrunkenness() > -4 && my_adventures() >= 1)) && __quest_state["Level 11 Desert"].state_boolean["Desert Explored"])
    {
        //Daycount strategy that never works, suggest:
        string line = (100.0 * ((item_drop_modifier_ignoring_plants() / 100.0 + 1.0) * (1.0 / 1000.0))).roundForOutput(2) + "% chance of spice melange.";
        if (my_adventures() == 0)
            line += "|Need one adventure.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item drum machine", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[drum machine]), "", line), importance_level_unimportant_item));
    }
    
    
    
    if (in_run)
    {
		if ($item[tattered scrap of paper].available_amount() > 0 && __misc_state["free runs usable"])
		{
			string [int] description;
			description.listAppend(($item[tattered scrap of paper].available_amount() / 2.0).roundForOutput(1) + " free runs.");
			available_resources_entries.listAppend(ChecklistEntryMake("__item tattered scrap of paper", "", ChecklistSubentryMake(pluralize($item[tattered scrap of paper]), "", description), importance_level_unimportant_item));
		}
		if (2371.to_item().available_amount() > 0 && __misc_state["free runs usable"])
		{
            item it = 2371.to_item();
			string [int] description;
			description.listAppend((it.available_amount() * 0.9).roundForOutput(1) + " free runs.");
			available_resources_entries.listAppend(ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake(pluralize(it), "", description), importance_level_unimportant_item));
		}
		if ($item[dungeoneering kit].available_amount() > 0)
		{
			string line = "Open it.";
			if ($item[dungeoneering kit].available_amount() > 1)
				line = "Open them.";
			available_resources_entries.listAppend(ChecklistEntryMake("__item dungeoneering kit", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[dungeoneering kit]), "", line), importance_level_unimportant_item));
		}
        if ($item[Box of familiar jacks].available_amount() > 0)
            available_resources_entries.listAppend(ChecklistEntryMake("__item box of familiar jacks", "", ChecklistSubentryMake(pluralize($item[Box of familiar jacks]), "", "Gives current familiar equipment."), importance_level_unimportant_item));
        if ($item[csa fire-starting kit].available_amount() > 0 && !get_property_boolean("_fireStartingKitUsed"))
        {
            string [int] description;
            description.listAppend("All-day 4 HP/MP regeneration.");
            if (hippy_stone_broken())
                description.listAppend("3 PVP fights.");
            available_resources_entries.listAppend(ChecklistEntryMake("__item csa fire-starting kit", "inventory.php?which=3", ChecklistSubentryMake($item[csa fire-starting kit], "", description), importance_level_unimportant_item));
        }
        
        if ($item[transporter transponder].available_amount() > 0)
        {
            string [int] options;
            if (__misc_state["need to level"])
                options.listAppend("powerleveling");
            if (fullness_limit() > 0 || inebriety_limit() > 0)
                options.listAppend("yellow ray in grimace for synthetic dog hair/distention pill");
            
            string description = "Spaaaaace access.";
            if (options.count() > 0)
                description += "|" + options.listJoinComponents(", ", "and").capitalizeFirstLetter();
            available_resources_entries.listAppend(ChecklistEntryMake("__item transporter transponder", "", ChecklistSubentryMake(pluralize($item[transporter transponder]), "", description), importance_level_unimportant_item));
        }
    }
    
    foreach it in $items[carton of astral energy drinks,astral hot dog dinner,astral six-pack]
    {
        if (it.available_amount() == 0)
            continue;
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + it, "inventory.php?which=3", ChecklistSubentryMake(pluralize(it), "", "Open for astral consumables."), importance_level_unimportant_item));
    }
    
    if ($item[map to safety shelter grimace prime].available_amount() > 0)
    {
        string line = "Use for synthetic dog hair or distention pill.";
        if (__misc_state["In aftercore"])
            line += "|Will disappear when you ascend.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + $item[map to safety shelter grimace prime], "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[map to safety shelter grimace prime]), "", line), importance_level_unimportant_item));
    }
    if ($item[rusty hedge trimmers].available_amount() > 0 && __quest_state["Level 9"].state_int["twin peak progress"] != 15)
    {
        string line = "Use to visit the Twin Peak non-combat.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + $item[rusty hedge trimmers], "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[rusty hedge trimmers]), "", line), importance_level_unimportant_item));
    }
    
    if (in_run && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
    {
        string image_name = "";
        string [int] autosell_list;
        foreach it in $items[meat stack, dense meat stack, really dense meat stack, solid gold bowling ball, fancy seashell necklace, commemorative war stein,huge gold coin]
        {
            if (it.available_amount() == 0)
                continue;
            autosell_list.listAppend(it.pluralize());
            
            if (image_name.length() == 0)
                image_name = "__item " + it;
        }
        string [int] open_list;
        foreach it in $items[old coin purse, old leather wallet, black pension check, ancient vinyl coin purse, warm subject gift certificate,shiny stones]
        {
            if (it.available_amount() == 0)
                continue;
            open_list.listAppend(it.pluralize());
            
            if (image_name.length() == 0)
                image_name = "__item " + it;
        }
        
        string url = "";
        string [int] description;
        if (autosell_list.count() > 0)
        {
            url = "sellstuff_ugly.php";
            description.listAppend("Autosell " + autosell_list.listJoinComponents(", ", "and") + ".");
        }
        if (open_list.count() > 0)
        {
            url = "inventory.php?which=3";
            description.listAppend("Open " + open_list.listJoinComponents(", ", "and") + ".");
        }
        
        if (description.count() > 0)
        {
            available_resources_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake("Meat", "", description), importance_level_unimportant_item));
        }
    }
    //Penultimate Fantasy chest?
    
    item odd_silver_coin = $item[odd silver coin];
    if (odd_silver_coin.available_amount() > 0 && in_run)
    {
        string [int] description;
        string [int][int] table;
        //cinnamon cannoli - 2 - 1 fullness awesome food. not worthwhile?
        //expensive champagne - 3 - 1-drunkness epic drink. not worthwhile?
        //polo trophy - 3 - +50ML for 15 turns
        //table.listAppend(listMake("polo trophy", "+50ML for 15 turns, marginal?", "3 coins")); //costs three adventures to find. I guess it'd only be relevant for cave bars? even then...
        //fancy oil painting - 4 - bridge building. 10 progress
        if (!__quest_state["Level 9"].state_boolean["bridge complete"] && (__quest_state["Level 9"].state_int["bridge fasteners needed"] > 0 || __quest_state["Level 9"].state_int["bridge lumber needed"] > 0))
            table.listAppend(listMake("fancy oil painting", "10 fasteners, 10 lumber", "4 coins"));
        //solid gold rosary - 5 - better cyrpt progression. need details (-4.5 evil?)
        if (!__quest_state["Level 7"].state_boolean["alcove finished"] || !__quest_state["Level 7"].state_boolean["cranny finished"] || !__quest_state["Level 7"].state_boolean["niche finished"] || !__quest_state["Level 7"].state_boolean["nook finished"])
            table.listAppend(listMake("solid gold rosary", "-4.5? evilness from cyrpt", "5 coins"));
        //ornate dowsing rod - 5 - better desert exploration (+2%)
        
        if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && $item[ornate dowsing rod].available_amount() == 0)
            table.listAppend(listMake("ornate dowsing rod", "+2% desert exploration", "5 coins"));
        description.listAppend(HTMLGenerateSimpleTableLines(table));
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + odd_silver_coin, "shop.php?whichshop=cindy", ChecklistSubentryMake(odd_silver_coin.pluralize(), "", description), importance_level_item));
    }
    item grimstone_mask = $item[grimstone mask];
    if (grimstone_mask.available_amount() > 0 && in_run)
    {
        string [int] description;
        
        description.listAppend("Wear to take you places.");
        description.listAppend("The prince's ball (stepmother) lets you find odd silver coins.|Up to six, one adventure each.");
        //description.listAppend("Rumpelstiltskin's for towerkilling with small golem.|Small golem is a 5k/round combat item.|Involves the semi-rare in village. Don't know the details, sorry."); //only somewhat relevant in obscure edge cases
        if (lookupEffect("Human-Fish Hybrid").have_effect() == 0 && get_campground()[$item[Little Geneticist DNA-Splicing Lab]] > 0 && !__misc_state["familiars temporarily blocked"])
            description.listAppend("Candy witch for human-fish hybrid. (+10 familiar weight)");
        if (get_property("grimstoneMaskPath").length() > 0)
            description.listAppend("Currently on the path of " + get_property("grimstoneMaskPath") + ".");
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + grimstone_mask, "inventory.php?which=3", ChecklistSubentryMake(grimstone_mask.pluralize(), "", description), importance_level_item));
    }
    
    if ($item[very overdue library book].available_amount() > 0 && in_run && __misc_state["Need to level"])
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item very overdue library book", "inventory.php?which=3", ChecklistSubentryMake("Very overdue library book", "", "Open for 63 moxie/mysticality/muscle."), importance_level_unimportant_item));
    }
    
    if ($item[chest of the Bonerdagon].available_amount() > 0 && in_run)
    {
        string description = "Open for 150 muscle/mysticality/moxie and 3k meat.";
        if (!$familiar[ninja pirate zombie robot].have_familiar())
            description += "|Unless you want to make an NPZR this ascension.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item chest of the Bonerdagon", "inventory.php?which=3", ChecklistSubentryMake("chest of the Bonerdagon", "", description), importance_level_unimportant_item));
    }
    
    if ($item[smoke grenade].available_amount() > 0 && in_run)
    {
        string description = "Turn-costing banish. (lasts 20 turns, no stats, no items, no meat)";
        available_resources_entries.listAppend(ChecklistEntryMake("__item smoke grenade", "", ChecklistSubentryMake(pluralize($item[Smoke grenade]), "", description), importance_level_unimportant_item));
    }
    
    if ($item[pile of ashes].available_amount() > 0 && in_run)
    {
        string description = "-10% combat. (20 turns)";
        available_resources_entries.listAppend(ChecklistEntryMake("__item pile of ashes", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[pile of ashes]), "", description), importance_level_unimportant_item));
    }
    if (lookupItem("7259").available_amount() > 0 && in_run)
    {
        string description = "Open for elemental damage combat items.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + lookupItem("7259"), "inventory.php?which=3", ChecklistSubentryMake(pluralize(lookupItem("7259")), "", description), importance_level_unimportant_item));
    }
    
    if ($item[gym membership card].available_amount() > 0 && in_run && __misc_state["need to level"])
    {
        int importance = importance_level_item;
        string description = "Gives 30 muscle/mysticality/moxie stats.|Once per day.";
        if (my_level() < 4)
        {
            description += "|Not usable until level 4.";
            importance = importance_level_unimportant_item;
        }
        available_resources_entries.listAppend(ChecklistEntryMake("__item gym membership card", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[gym membership card]), "", description), importance_level_item));
    }
    
    if (!get_property_boolean("_warbearGyrocopterUsed"))
    {
        if ($item[warbear gyrocopter].available_amount() > 0)
        {
            string [int] description;
            description.listAppend("Usable once/day for a gyro. Only breaks a quarter of the time.");
            if (!in_ronin())
                description.listAppend("Could always send it to yourself.");
            available_resources_entries.listAppend(ChecklistEntryMake("__item warbear gyrocopter", "curse.php?whichitem=7038", ChecklistSubentryMake(pluralize($item[warbear gyrocopter]), "", description), importance_level_unimportant_item));
            
        }
        else if ($item[broken warbear gyrocopter].available_amount() > 0)
        {
            available_resources_entries.listAppend(ChecklistEntryMake("__item broken warbear gyrocopter", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[broken warbear gyrocopter]), "", "Gyrocopters dream of the sky. Set one free!"), importance_level_unimportant_item));
            
        }
    }
    if ($item[burned government manual fragment].available_amount() > 0)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item burned government manual fragment", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[burned government manual fragment]), "", "Foreign language study.|Will disappear on ascension."), importance_level_unimportant_item));
    }
    if ($item[lynyrd snare].available_amount() > 0 && in_run && __misc_state["need to level"]) //FIXME tracking number used today
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item lynyrd snare", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[lynyrd snare]), "", "Free fight when used."), importance_level_unimportant_item));
    }
    if (in_run && $item[red box].available_amount() > 0)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item red box", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[red box]), "", "Open for stuff."), importance_level_unimportant_item));
    }
    
    if (in_run && $item[llama lama gong].available_amount() > 0)
    {
        //fiddle fiddle fiddle
        //I'm not sure anyone should actually do this, so fiddly!
        boolean need_pickpocket = true;
        if (my_primestat() == $stat[moxie])
            need_pickpocket = false;
            
        string [int] description;
        string [int] birdform_description;
        
        //options:
        
        string [int] possible_pickpocket_locations;
        
        if (need_pickpocket)
        {
            //bird form for pickpocket in crypt, filthworms, golems
            
            if (__quest_state["Level 7"].state_boolean["nook needs speed tricks"])
                possible_pickpocket_locations.listAppend("Cyrpt Nook");
            if (!__quest_state["Level 12"].state_boolean["Orchard Finished"])
                possible_pickpocket_locations.listAppend("filthworms");
                
            if (possible_pickpocket_locations.count() == 0)
                birdform_description.listAppend("Gives pickpocketing ability.");
            else
                birdform_description.listAppend("Gives pickpocketing ability for stealing from the " + possible_pickpocket_locations.listJoinComponents(", ", "and") + ".");
        }
        
        string [element][int] element_options;
        
        foreach e in $elements[]
            element_options[e] = listMakeBlankString();
        if (!__quest_state["Level 6"].finished)
            element_options[$element[hot]].listAppend("friars quest");
        
        if (__quest_state["Level 9"].state_float["oil peak pressure"] > 0.0)
            element_options[$element[sleaze]].listAppend("oil peak");
            
        if (!__quest_state["Level 12"].finished && __quest_state["Level 12"].state_string["Side seemingly fighting for"] == "hippy")
            element_options[$element[sleaze]].listAppend("frat boys");
            
        
        if (!__quest_state["Level 7"].finished)
            element_options[$element[spooky]].listAppend("cyrpt");
        
        
        if (!__quest_state["Level 12"].state_boolean["War started"])
            element_options[$element[stench]].listAppend("starting war against hippies");
        if (!__quest_state["Level 12"].state_boolean["Orchard Finished"])
            element_options[$element[stench]].listAppend("filthworms");
        
        if (__quest_state["Level 11 Manor"].mafia_internal_step < 2)
            element_options[$element[spooky]].listAppend("spookyraven ballroom");
        if (get_property("questM20Necklace") != "finished" && $item[Lady Spookyraven's powder puff].available_amount() == 0)
            element_options[$element[spooky]].listAppend("spookyraven bathroom");
            
            
            
        string [element] element_to_potion;
        
        if (__misc_state["need to level"])
            element_to_potion[$element[hot]] = "+6 stats/fight";
        element_to_potion[$element[sleaze]] = "+20 ML";
        element_to_potion[$element[spooky]] = "+60% item";
        
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"] && $item[glimmering raven feather].available_amount() == 0 && $effect[Melancholy Burden].have_effect() == 0)
            element_to_potion[$element[stench]] = "+60% meat";
        
        
        //string [int][int] monster_fight_table;
        //monster_fight_table.listAppend(listMake(HTMLGenerateSpanOfClass("Monster element", "r_bold"), HTMLGenerateSpanOfClass("Areas", "r_bold"), HTMLGenerateSpanOfClass("Gives potion", "r_bold")));
        foreach e in element_options
        {
            if (element_options[e].count() == 0)
                continue;
            if (!(element_to_potion contains e))
                continue;
                
            //monster_fight_table.listAppend(listMake(e.to_string(), element_options[e].listJoinComponents("<br>"), element_to_potion[e]));
            birdform_description.listAppend("Fight " + e + " monsters (" + element_options[e].listJoinComponents(", ", "and") + ") for " + element_to_potion[e] + " spleen potion.");
        }
        
        //if (monster_fight_table.count() > 1)
            //birdform_description.listAppend(HTMLGenerateSimpleTableLines(monster_fight_table));
        
        //√against hot (friars) for +6 stats/fight potion
        //against sleaze (oil peak) for +ML potion
        //against spooky (cyrpt, spookyraven ballroom/bathroom) for +60% items from monsters potion
        //against stench (filthworms, starting war against hippy) for +60% meat potion
        
        //cast boner battalion to handle birdform?
        //can only cast vicious talon slash/All-You-Can-Beat Wing Buffet 14 times, 15 leads to the feather you don't want (property birdformRoc maybe?)
        
        //FIXME implement birdform reminders? (like AVOID CASTING X)
        
        if (my_maxmp() >= 200 && $skill[Summon &quot;Boner Battalion&quot;].skill_is_usable() && !get_property_boolean("_bonersSummoned"))
            description.listAppend("Possibly cast the battalion to handle birdform."); //yojimbos_law wants this here, so..
        
        if (birdform_description.count() > 0)
            description.listAppend(HTMLGenerateSpanOfClass("Birdform", "r_bold") + "|*" + birdform_description.listJoinComponents("|*<hr>"));
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item llama lama gong", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[llama lama gong]), "", description), importance_level_item));
        
    }
    
    if (!in_run && get_property("_bittycar").length() == 0 && $items[BittyCar HotCar, BittyCar MeatCar,BittyCar SoulCar].available_amount() > 0 && mafiaIsPastRevision(15028))
    {
        string [int] available_items;
        string [int] available_descriptions;
        string [item] item_descriptions;
        item_descriptions[$item[BittyCar HotCar]] = "hot damage";
        item_descriptions[$item[BittyCar MeatCar]] = "extra meat";
        item_descriptions[$item[BittyCar SoulCar]] = "HP/MP";
        
        
        foreach it in $items[BittyCar MeatCar,BittyCar SoulCar,BittyCar HotCar]
        {
            if (it.available_amount() > 0)
            {
                available_items.listAppend(it.to_string().replace_string("BittyCar ", ""));
                available_descriptions.listAppend(item_descriptions[it]);
            }
        }
        string description = "Reusable once/day for occasional " + available_descriptions.listJoinComponents(", ", "or") + " in combat.";
        available_resources_entries.listAppend(ChecklistEntryMake("__item BittyCar MeatCar", "inventory.php?which=3", ChecklistSubentryMake("BittyCar " + available_items.listJoinComponents(", ", "or") + " usable", "", description), importance_level_unimportant_item));
    }
    
    if (in_run && !__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"] != "mysticality" && get_property_int("lastGoofballBuy") != my_ascensions() && __quest_state["Level 3"].started)
    {
        available_resources_entries.listAppend(ChecklistEntryMake("__item bottle of goofballs", "tavern.php?place=susguy", ChecklistSubentryMake("Bottle of goofballs obtainable", "", "For the lair stat test.|Costs nothing, but be careful..."), importance_level_unimportant_item));
    }
    
    if ($item[tonic djinn].available_amount() > 0 && !can_interact() && in_run)
    {
        string [int] possibilities;
        possibilities.listAppend("~450 meat (Wealth!)");
        if (__misc_state["need to level"])
        {
            string mainstat_choice;
            if (my_primestat() == $stat[muscle])
                mainstat_choice = "Strength!";
            else if (my_primestat() == $stat[mysticality])
                mainstat_choice = "Wisdom!";
            else if (my_primestat() == $stat[moxie])
                mainstat_choice = "Panache!";
            
            if (mainstat_choice.length() != 0)
                possibilities.listAppend("~60 mainstats (" + mainstat_choice + ")");
        }
        
        string [int] description;
        description.listAppend("Use for " + possibilities.listJoinComponents(", ", "or"));
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item tonic djinn", "inventory.php?which=3", ChecklistSubentryMake("Tonic djinn", "", description), importance_level_unimportant_item));
    }
    
    if ($item[cosmic calorie].available_amount() > 0 && in_run)
    {
        string [int][int] table;
        table.listAppend(listMake("Cost", "Item", "Effect"));
        
        string [item] celestial_descriptions;
        celestial_descriptions[$item[celestial olive oil]] = "+1 all res";
        celestial_descriptions[$item[celestial carrot juice]] = "+30% item";
        celestial_descriptions[$item[celestial au jus]] = "+5% combat";
        celestial_descriptions[$item[celestial squid ink]] = "-5% combat";
        int [item] calories_required;
        calories_required[$item[celestial olive oil]] = 20;
        calories_required[$item[celestial carrot juice]] = 30;
        calories_required[$item[celestial au jus]] = 50;
        calories_required[$item[celestial squid ink]] = 60;
        foreach it in $items[celestial olive oil,celestial carrot juice,celestial au jus,celestial squid ink]
        {
            int amount = it.creatable_amount() + it.available_amount();
                
            string [int] line;
            line = listMake(calories_required[it], it, celestial_descriptions[it]);
            if (amount == 0)
            {
                foreach key, s in line
                {
                    line[key] = HTMLGenerateSpanFont(s, "grey", "");
                }
            }
            table.listAppend(line);
        }
        string [int] description;
        description.listAppend(HTMLGenerateSimpleTableLines(table));
        available_resources_entries.listAppend(ChecklistEntryMake("__item cosmic calorie", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[cosmic calorie]), "", description), importance_level_item));
        
    }
}
