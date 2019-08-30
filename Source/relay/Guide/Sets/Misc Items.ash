void SMiscItemsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($item[the crown of ed the undying].equipped_amount() > 0 && get_property("edPiece").length() == 0)
    {
        string [int] description;
        
        if (__misc_state["need to level"])
        {
            if (my_primestat() == $stat[muscle])
                description.listAppend("Bear - +2 mainstat/fight");
            else if (my_primestat() == $stat[mysticality])
                description.listAppend("Owl - +2 mainstat/fight");
            else if (my_primestat() == $stat[moxie])
                description.listAppend("Puma - +2 mainstat/fight");
            description.listAppend("Hyena - +20 ML");
        }
        description.listAppend("Mouse - +10% item, +20% meat");
        description.listAppend("Weasel - survive first hit, regenerate HP");
        optional_task_entries.listAppend(ChecklistEntryMake("__item the crown of ed the undying", "inventory.php?action=activateedhat", ChecklistSubentryMake("Configure the Crown of Ed the Undying", "", description), 5));
    }
    
    if (__misc_state["in run"])
    {
        //Suggest acquiring a stasis source:
        //If you're not in ronin, you should acquire a source from hangk's.
        //If you are: suckerpunch as DB -> dictionary -> facsimile dictionary -> seal tooth
        
        boolean currently_have_source = false;
        if (my_class() == $class[disco bandit])
            currently_have_source = true;
        else if ($items[dictionary,facsimile dictionary,seal tooth].item_amount() > 0)
            currently_have_source = true;
        
        boolean have_reason = false;
        //Try not to annoy anyone that doesn't currently have a reason to stasis:
        if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING) //to always trigger the underworld
            have_reason = true;
        if ($effect[everything looks yellow].have_effect() == 0 && $familiar[he-boulder].familiar_is_usable()) //to reach the correct eye
            have_reason = true;
        if ($familiars[stocking mimic,cocoabo,star starfish,Animated Macaroni Duck,Midget Clownfish,Rock Lobster,Snow Angel,Twitching Space Critter,slimeling,mini-hipster] contains my_familiar()) //MP delaying. grill intentionally left off, because it doesn't act as often in later rounds(?)
            have_reason = true;
        if (__quest_state["Level 12"].state_boolean["War started"] && __quest_state["Level 12"].in_progress && !__quest_state["Level 12"].state_boolean["Junkyard Finished"])
            have_reason = true;
        
        if (!currently_have_source && have_reason)
        {
            boolean try_for_seal_tooth = false;
            if (in_ronin())
            {
                item pull_item = $item[none];
                foreach it in $items[dictionary,facsimile dictionary,seal tooth]
                {
                    if (it.available_amount() > 0)
                    {
                        pull_item = it;
                        break;
                    }
                }
                if (pull_item != $item[none])
                {
                    string [int] description;
                    description.listAppend("Useful for delaying in-fight.");
                    optional_task_entries.listAppend(ChecklistEntryMake("__item " + pull_item, "storage.php?which=3", ChecklistSubentryMake("Pull a " + pull_item, "", description), 5));
                }
                else
                    try_for_seal_tooth = true;
            }
            else
            {
                try_for_seal_tooth = true;
            }
            if (my_path_id() == PATH_NUCLEAR_AUTUMN)
                try_for_seal_tooth = false;
            
            if (try_for_seal_tooth)
            {
                string url = "";
                string [int] description;
                if ($items[worthless trinket,worthless gewgaw,worthless knick-knack].available_amount() == 0)
                {
                    url = "shop.php?whichshop=generalstore";
                    description.listAppend("Use chewing gum on a string.");
                }
                else
                {
                    url = "hermit.php";
                    description.listAppend("From the hermit.");
                }
                
                description.listAppend("Useful for delaying in-fight.");
                optional_task_entries.listAppend(ChecklistEntryMake("__item seal tooth", url, ChecklistSubentryMake("Acquire a seal tooth", "", description), 5));
            }
        }
    }
}

void SMiscItemsGenerateResource(ChecklistEntry [int] resource_entries)
{
	int importance_level_item = 7;
	int importance_level_unimportant_item = 8;
    
    boolean in_run = __misc_state["in run"] && in_ronin();
    
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
	boolean have_navel_type_equipment = false;
	if ($item[navel ring of navel gazing].available_amount() > 0 && $item[navel ring of navel gazing].is_unrestricted())
	{
        have_navel_type_equipment = true;
		string name = "Navel Ring runaways";
        
        string url = "";
        if ($item[navel ring of navel gazing].equipped_amount() == 0)
            url = "inventory.php?which=2"; //&ftext=navel+ring+of+navel+gazing
		
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
		resource_entries.listAppend(ChecklistEntryMake("__item navel ring of navel gazing", url, ChecklistSubentryMake(name, "", description)));
	}
	if ($item[greatest american pants].available_amount() > 0 && $item[greatest american pants].is_unrestricted())
	{
        have_navel_type_equipment = true;
		string name = "Greatest American Pants";
		
        string url = "";
        if ($item[greatest american pants].equipped_amount() == 0)
            url = "inventory.php?which=2"; //&ftext=greatest+american+pants
        
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
        
        int buffs_remaining = 5 - get_property_int("_gapBuffs");
        if (buffs_remaining > 0)
            description.listAppend(pluralise(buffs_remaining, "buff", "buffs") + " remaining.");
		resource_entries.listAppend(ChecklistEntryMake("__item greatest american pants", url, ChecklistSubentryMake(name, "", description)));
	}
    if ($item[peppermint parasol].available_amount() > 0 && in_run && !have_navel_type_equipment)
	{
		int parasol_progress = get_property_int("parasolUsed");
		string name = "";
		
		name = parasol_progress + "/10 peppermint parasol uses";
		string [int] description;
		description.listAppend(navel_percent_chance_of_runaway + "% chance of free runaway.");
		resource_entries.listAppend(ChecklistEntryMake("__item peppermint parasol", "", ChecklistSubentryMake(name, "", description)));
	}
	if ($item[pantsgiving].available_amount() > 0)
	{
		ChecklistSubentry subentry = ChecklistSubentryMake("Pantsgiving", "", "");
        
        string url = "";
        
        if ($item[pantsgiving].equipped_amount() == 0)
            url = "inventory.php?which=2"; //&ftext=pantsgiving
		
		
		int banishes_available = 5 - get_property_int("_pantsgivingBanish");
		if (banishes_available > 0)
        {
        	//subentry.entries.listAppend(pluralise(banishes_available, "banish", "banishes") + " available.");
            string [int] tasks;
            if ($item[pantsgiving].equipped_amount() == 0)
            	tasks.listAppend("equip pantsgiving");
            tasks.listAppend("cast talk about politics");
            resource_entries.listAppend(ChecklistEntryMake("__item pantsgiving", url, ChecklistSubentryMake(pluralise(banishes_available, "Pantsgiving banish", "Pantsgiving banishes"), "", tasks.listJoinComponents(", ").capitaliseFirstLetter() + ".")).ChecklistEntryTagEntry("banish"));
            
        }
        
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
			subentry.entries.listAppend(pluralise(number_left, "adventure", "adventures") + " until next fullness.");
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
			subentry.entries.listAppend(pluralise(pantsgiving_potential_crumbs_remaining, " pocket crumb item", " pocket crumb items") + " left.");
		
		if (subentry.entries.count() > 0)
		{
			ChecklistEntry entry = ChecklistEntryMake("__item pantsgiving", url, subentry);
			entry.should_indent_after_first_subentry = true;
			resource_entries.listAppend(entry);
		}
	}
    
    
    
    if (__misc_state["free runs usable"] && in_run && $item[bottle of blank-out].available_amount() > 0)
	{
		string [int] description;
		string name;
		int blankout_count = $item[bottle of blank-out].available_amount();
		name += pluralise(blankout_count, "blank-out", "blank-out");
        
		if ($item[glob of blank-out].available_amount() == 0)
            description.listAppend("Use blank-out for glob.");
        if (get_property_boolean("_blankoutUsed"))
            description.listAppend("Will have to wait until tomorrow to open.");
        
		resource_entries.listAppend(ChecklistEntryMake("__item Bottle of Blank-Out", "inventory.php?which=3&ftext=bottle+of+blank-out", ChecklistSubentryMake(name, "", description)));
	}
    if (__misc_state["free runs usable"] && $item[glob of blank-out].available_amount() > 0)
    {
		int uses_remaining = 5 - get_property_int("blankOutUsed");
		string [int] description;
		string name;
        description.listAppend("Use glob of blank-out in combat.");
        if (!in_run)
            description.listAppend("Will disappear when you ascend.");
        
        name = pluralise(uses_remaining, "blank-out runaway", "blank-out runaways");
		resource_entries.listAppend(ChecklistEntryMake("__item glob of blank-out", "", ChecklistSubentryMake(name, "", description)));
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
		resource_entries.listAppend(ChecklistEntryMake("__item BitterSweetTarts", "inventory.php?which=3&ftext=bittersweettarts", ChecklistSubentryMake(pluralise($item[BitterSweetTarts]), "", description), importance_level_item));
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
		resource_entries.listAppend(ChecklistEntryMake("__item polka pop", "", ChecklistSubentryMake(pluralise($item[polka pop]), "10 turns", description), importance_level_item));
	}
        
    if ($item[frost flower].available_amount() > 0 && in_run)
    {
        string [int] description;
        description.listAppend("+100% item, +200% meat, +25 ML, +100% init");
        resource_entries.listAppend(ChecklistEntryMake("__item frost flower", "inventory.php?which=3&ftext=frost+flower", ChecklistSubentryMake($item[frost flower].pluralise(), "50 turns", description), importance_level_item));
    }
	if (in_run)
	{
		//Resolutions:
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
			
			resolution_lines.listAppend(ChecklistSubentryMake(pluralise(it), "",  description));
		}
		if (resolution_lines.count() > 0)
			resource_entries.listAppend(ChecklistEntryMake("__item resolution: be luckier", "inventory.php?which=3&ftext=resolution:+be", resolution_lines, importance_level_item));
			
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
			taffy_lines.listAppend(ChecklistSubentryMake(pluralise(it), "",  description));
		}
		if (taffy_lines.count() > 0)
			resource_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=3&ftext=pulled", taffy_lines, importance_level_item));
			
	}
	
	
	
	if (in_run)
	{
		if (7014.to_item().available_amount() > 0)
			resource_entries.listAppend(ChecklistEntryMake("__item " + 7014.to_item().to_string(), "", ChecklistSubentryMake(pluralise(7014.to_item()), "", "Free run, banish for 20 turns"), importance_level_item).ChecklistEntryTagEntry("banish"));
		if ($item[crystal skull].available_amount() > 0)
			resource_entries.listAppend(ChecklistEntryMake("__item crystal skull", "", ChecklistSubentryMake(pluralise($item[crystal skull]), "", "Turn-costing banishing"), importance_level_item).ChecklistEntryTagEntry("banish"));
            
		if ($item[harold's bell].available_amount() > 0)
			resource_entries.listAppend(ChecklistEntryMake("__item harold's bell", "", ChecklistSubentryMake(pluralise($item[harold's bell]), "", "Turn-costing banishing"), importance_level_item).ChecklistEntryTagEntry("banish"));
        
		if ($item[lost key].available_amount() > 0)
        {
            string [int] details;
            details.listAppend("Lost pill bottle is mini-fridge, take a nap, open the pill bottle.");
            //FIXME does stunning work on tower monsters?
            //if (!__quest_state["Level 13"].state_boolean["past tower monsters"] && (!$item[munchies pill].is_unrestricted() || !__misc_state["can eat just about anything"]))
                //details.listAppend("The lost comb is turn on the TV, take a nap, pick up the comb. (towerkilling)");
            if ($classes[pastamancer,sauceror] contains my_class() && $skill[Transcendental Noodlecraft].skill_is_usable() && $skill[The Way of Sauce].skill_is_usable() && $skill[pulverize].skill_is_usable())
                details.listAppend("The lost glasses is mini-fridge, TV, glasses.");
			resource_entries.listAppend(ChecklistEntryMake("__item lost key", "inventory.php?which=3&ftext=lost+key", ChecklistSubentryMake(pluralise($item[lost key]), "", details), importance_level_item));
        }
			
		if ($item[soft green echo eyedrop antidote].available_amount() > 0 && $skill[Transcendent Olfaction].skill_is_usable())
			resource_entries.listAppend(ChecklistEntryMake("__item soft green echo eyedrop antidote", "", ChecklistSubentryMake(pluralise($item[soft green echo eyedrop antidote]), "", "Removes on the trail, teleportitis"), importance_level_unimportant_item));
			
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
			resource_entries.listAppend(ChecklistEntryMake("__item sack lunch", "inventory.php?which=3&ftext=sack+lunch", ChecklistSubentryMake(pluralise($item[sack lunch]), "", description), importance));
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
                    
                subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", descriptions[it]));
            }
            
            if (subentries.count() > 0)
                resource_entries.listAppend(ChecklistEntryMake(image_name, "inventory.php?which=3", subentries, importance_level_item));
        }
	}
	if ($item[smut orc keepsake box].available_amount() > 0 && !__quest_state["Level 9"].state_boolean["bridge complete"] && __misc_state["in run"])
		resource_entries.listAppend(ChecklistEntryMake("__item smut orc keepsake box", "inventory.php?which=3&ftext=smut+orc+keepsake+box", ChecklistSubentryMake(pluralise($item[smut orc keepsake box]), "", "Open for bridge building."), 0));
		
    if ($item[wand of pigification].available_amount() > 0 && in_bad_moon() && __misc_state["in run"])
    {
		resource_entries.listAppend(ChecklistEntryMake("__item wand of pigification", "", ChecklistSubentryMake("Wand of pigification", "", "Use twice a day on monsters for good-level food."), 6));
    }
		
	int clovers_available = $items[disassembled clover,ten-leaf clover].available_amount() + $item[disassembled clover].closet_amount() + $item[ten-leaf clover].closet_amount();
	if (my_path_id() == PATH_BEES_HATE_YOU || my_path_id() == PATH_G_LOVER)
		clovers_available = $item[ten-leaf clover].item_amount() + $item[ten-leaf clover].closet_amount();
	if (clovers_available > 0 && in_run)
	{
		ChecklistSubentry subentry;
		subentry.header = pluralise(clovers_available, "clover", "clovers") + " available";
        
		
		if (!__quest_state["Level 9"].state_boolean["bridge complete"])
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Orc logging camp, for bridge building. (3/3)", $location[the smut orc logging camp]));
		if ($item[a-boo clue].available_amount() < 4 && (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0 || !__quest_state["Level 9"].state_boolean["bridge complete"]) && my_path_id() != PATH_G_LOVER)
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("A-Boo clues. (2)", $location[a-boo peak]));
		if (__misc_state["wand of nagamar needed"] && $item[wand of nagamar].creatable_amount() == 0)
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Wand of nagamar components (castle basement)", $location[the castle in the clouds in the sky (basement)]));
		boolean have_all_gum = $item[pack of chewing gum].available_amount() > 0 || ($item[jaba&ntilde;ero-flavored chewing gum].available_amount() > 0 && $item[lime-and-chile-flavored chewing gum].available_amount() > 0 && $item[pickle-flavored chewing gum].available_amount() > 0 && $item[tamarind-flavored chewing gum].available_amount() > 0);
		if (__quest_state["Level 4"].state_int["areas unlocked"] + $item[sonar-in-a-biscuit].available_amount() < 2)
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("2 sonar-in-a-biscuit (Guano Junction)", $location[guano junction]));
   
   		if (__quest_state["Level 11 Ron"].mafia_internal_step <= 2 && __quest_state["Level 11 Ron"].state_int["protestors remaining"] > 1)
            subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Mob of zeppelin protestors NC", $location[A Mob of Zeppelin Protesters]));         
		if (!__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && !(get_property_boolean("lovebugsUnlocked") && $item[bottle of lovebug pheromones].is_unrestricted())) //taking a gamble here - I'm assuming you'd never clover for ultrahydrated if you have lovebugs. even if you run out of ultrahydrated, you'll likely get it again in a hurry
        {
			subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Ultrahydrated (Oasis)", $location[the oasis]));
        }
        if (!__quest_state["Level 8"].state_boolean["Past mine"])
        {
            item ore_needed = __quest_state["Level 8"].state_string["ore needed"].to_item();
            if (ore_needed == $item[none])
                subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability("Mining ore. (1)", $location[itznotyerzitz mine]));
            else
                subentry.entries.listAppend(HTMLGenerateFutureTextByLocationAvailability(ore_needed.capitaliseFirstLetter() + ". (1)", $location[itznotyerzitz mine]));
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
		
		resource_entries.listAppend(ChecklistEntryMake("clover", "", subentry, 7).ChecklistEntryTagEntry("clovers"));
	}
	if (in_run && $item[lucky pill].have() && availableSpleen() > 0)
	{
		string [int] description;
        description.listAppend("Chew for clovers.");
        resource_entries.listAppend(ChecklistEntryMake("__item lucky pill", "inventory.php?which=3&ftext=lucky+pill", ChecklistSubentryMake(pluralise($item[lucky pill]), "", description), importance_level_unimportant_item).ChecklistEntryTagEntry("clovers"));
	}
	if (in_run)
	{
		if ($item[gameinformpowerdailypro magazine].available_amount() > 0)
		{
			string [int] description;
			description.listAppend("Zero-turn free SGEAA and scrolls");
			resource_entries.listAppend(ChecklistEntryMake("__item gameinformpowerdailypro magazine", "inventory.php?which=3&ftext=gameinformpowerdailypro+magazine", ChecklistSubentryMake(pluralise($item[gameinformpowerdailypro magazine]), "", description), importance_level_unimportant_item));
		}
	}
    if ($item[divine champagne popper].available_amount() > 0 && in_run)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item divine champagne popper", "", ChecklistSubentryMake(pluralise($item[divine champagne popper]), "", "Free run and five-turn banish."), importance_level_unimportant_item).ChecklistEntryTagEntry("banish"));
    }
    if (__misc_state["need to level"])
    {
		if ($item[dance card].available_amount() > 0 && my_primestat() == $stat[moxie] && in_ronin())
        {
			string [int] description;
			description.listAppend("Gain ~" + round(__misc_state_float["dance card average stats"]) + " mainstat from delayed adventure in the haunted ballroom.");
			resource_entries.listAppend(ChecklistEntryMake("__item dance card", "inventory.php?which=3&ftext=dance+card", ChecklistSubentryMake(pluralise($item[dance card]), "", description), importance_level_unimportant_item));
        }
    }
	if ($item[stone wool].available_amount() > 0 && in_ronin() && $item[stone wool].item_is_usable())
	{
		string [int] description;
		string url = "inventory.php?which=3&ftext=stone+wool";
		int quest_needed = 2;
		if ($item[the nostril of the serpent].available_amount() > 0)
			quest_needed -= 1;
		if (locationAvailable($location[the hidden park]) || !in_run)
			quest_needed = 0;
		
		if (quest_needed > 0)
			description.listAppend(quest_needed + " to unlock hidden city.");
		if (__misc_state["need to level"])
			description.listAppend("Cave bar.");
		if (!get_property_ascension("lastTempleAdventures") && my_path_id() != PATH_SLOW_AND_STEADY)
        {
            string line = "+3 adventures, +3 duration to ten effects. (once/ascension)";
            if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
                line += "|Can use to extend effects at nuns.";
			description.listAppend(line);
        }
        if (!__misc_state["in run"] && $effect[stone-faced].have_effect() > 0)
            url = $location[the hidden temple].getClickableURLForLocation();
		if (description.count() > 0)
			resource_entries.listAppend(ChecklistEntryMake("__item stone wool", url, ChecklistSubentryMake(pluralise($item[stone wool]), "", description), importance_level_unimportant_item));
	}
    if ($item[the legendary beat].available_amount() > 0 && !get_property_boolean("_legendaryBeat"))
    {
        resource_entries.listAppend(ChecklistEntryMake("__item The Legendary Beat", "inventory.php?which=3&ftext=the+legendary+beat", ChecklistSubentryMake("The Legendary Beat", "", "+50% item. (20 turns)"), importance_level_item));
        
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
			resource_entries.listAppend(ChecklistEntryMake(zap_wand_owned, url, ChecklistSubentryMake(pluralise(zaps_used, "zap", "zaps") + " used with " + zap_wand_owned, "", details), 10));
		}
	}
    
    if (!get_property_boolean("_defectiveTokenChecked") && get_property_ascension("lastArcadeAscension"))
    {
        resource_entries.listAppend(ChecklistEntryMake("__item jackass plumber home game", "place.php?whichplace=arcade", ChecklistSubentryMake("Broken arcade game", "", "May find a defective game grid token."), importance_level_item));
    }
    if ($item[picky tweezers].available_amount() > 0 && !get_property_boolean("_pickyTweezersUsed"))
    {
        resource_entries.listAppend(ChecklistEntryMake("__item picky tweezers", "inventory.php?which=3&ftext=picky+tweezers", ChecklistSubentryMake("Picky tweezers", "", "Acquire a single atom."), importance_level_unimportant_item));
    }
    if ($item[defective Game Grid token].available_amount() > 0 && !get_property_boolean("_defectiveTokenUsed"))
    {
        string [int] description;
        description.listAppend("+5 to everything. (5 turns)");
        
        resource_entries.listAppend(ChecklistEntryMake("__item defective Game Grid token", "inventory.php?which=3&ftext=defective+game+grid+token", ChecklistSubentryMake("Defective Game Grid Token", "", description), importance_level_item));
    }
    if ($item[Platinum Yendorian Express Card].available_amount() > 0 && !get_property_boolean("expressCardUsed"))
    {
        string [int] description;
        string line = "Extends buffs, restores MP";
        if (get_property_int("_zapCount") > 0 && zap_wand_owned != $item[none] && zap_wand_owned.available_amount() > 0)
            line += ", cools down " + zap_wand_owned;
        line += ".";
        description.listAppend(line);
        resource_entries.listAppend(ChecklistEntryMake("__item Platinum Yendorian Express Card", "", ChecklistSubentryMake("Platinum Yendorian Express Card", "", description), importance_level_item));
    }
    
    
    if ($item[mojo filter].available_amount() > 0 && get_property_int("currentMojoFilters") <3 && in_run)
    {
        int mojo_filters_usable = MIN(my_spleen_use(), MIN(3 - get_property_int("currentMojoFilters"), $item[mojo filter].available_amount()));
        string line = "Removes one spleen each.";
        if (mojo_filters_usable != $item[mojo filter].available_amount())
            line += "|" + pluralise(mojo_filters_usable, "filter", "filters") + " usable.";
        
        if (mojo_filters_usable > 0)
            resource_entries.listAppend(ChecklistEntryMake("__item mojo filter", "inventory.php?which=3&ftext=mojo+filter", ChecklistSubentryMake(pluralise($item[mojo filter]), "", line), importance_level_unimportant_item));
    }
    if ($item[distention pill].available_amount() > 0 && !get_property_boolean("_distentionPillUsed") && in_run)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item distention pill", "inventory.php?which=3&ftext=distention+pill", ChecklistSubentryMake(pluralise($item[distention pill]), "", "Adds one extra fullness.|Once/day."), importance_level_unimportant_item));
    }
    if ($item[synthetic dog hair pill].available_amount() > 0 && !get_property_boolean("_syntheticDogHairPillUsed") && in_run)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item synthetic dog hair pill", "inventory.php?which=3&ftext=synthetic+dog+hair+pill", ChecklistSubentryMake(pluralise($item[synthetic dog hair pill]), "", "Adds one extra drunkenness.|Once/day."), importance_level_unimportant_item));
    }
    if ($item[the lost pill bottle].available_amount() > 0 && in_run && my_path_id() != PATH_BEES_HATE_YOU)
    {
        string header = pluralise($item[the lost pill bottle]);
        if ($item[the lost pill bottle].available_amount() == 1)
            header = $item[the lost pill bottle];
        resource_entries.listAppend(ChecklistEntryMake("__item the lost pill bottle", "inventory.php?which=3&ftext=the+lost+pill+bottle", ChecklistSubentryMake(header, "", "Open it."), importance_level_unimportant_item));
    }
    if (__misc_state["need to level"] && in_ronin())
    {
        if ($item[Marvin's marvelous pill].available_amount() > 0 && __misc_state["need to level moxie"])
        {
            resource_entries.listAppend(ChecklistEntryMake("__item Marvin's marvelous pill", "", ChecklistSubentryMake(pluralise($item[Marvin's marvelous pill]), "", "+20% to moxie gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[drum of pomade].available_amount() > 0 && __misc_state["need to level moxie"])
        {
            resource_entries.listAppend(ChecklistEntryMake("__item drum of pomade", "", ChecklistSubentryMake(pluralise($item[drum of pomade]), "", "+15% to moxie gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[baobab sap].available_amount() > 0 && __misc_state["need to level muscle"])
        {
            resource_entries.listAppend(ChecklistEntryMake("__item baobab sap", "", ChecklistSubentryMake(pluralise($item[baobab sap]), "", "+20% to muscle gains. (10 turns)"), importance_level_unimportant_item));
        }
        if ($item[desktop zen garden].available_amount() > 0 && __misc_state["need to level mysticality"])
        {
            resource_entries.listAppend(ChecklistEntryMake("__item desktop zen garden", "", ChecklistSubentryMake(pluralise($item[desktop zen garden]), "", "+20% to mysticality gains. (10 turns)"), importance_level_unimportant_item));
        }
    }
    if ($item[munchies pill].available_amount() > 0 && fullness_limit() > 0 && in_run && my_path_id() != PATH_SLOW_AND_STEADY)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item munchies pill", "", ChecklistSubentryMake(pluralise($item[munchies pill]), "", "+3 turns from fortune cookies and other low-fullness foods."), importance_level_unimportant_item));
    }
    if ($item[snow cleats].available_amount() > 0 && in_run)
        resource_entries.listAppend(ChecklistEntryMake("__item snow cleats", "", ChecklistSubentryMake(pluralise($item[snow cleats]), "", "-5% combat, 30 turns."), importance_level_item));
        
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
        resource_entries.listAppend(ChecklistEntryMake("__item vitachoconutriment capsule", "inventory.php?which=3&ftext=vitachoconutriment+capsule", ChecklistSubentryMake(pluralise($item[vitachoconutriment capsule]), "", line), importance_level_unimportant_item));
    }
    if (__misc_state["in run"] && lookupItem("tryptophan dart").available_amount() > 0 && in_ronin() && lookupItem("tryptophan dart").item_is_usable())
    {
        resource_entries.listAppend(ChecklistEntryMake("__item tryptophan dart", "", ChecklistSubentryMake(pluralise(lookupItem("tryptophan dart")), "", "Free run/banish."), 6).ChecklistEntryTagEntry("banish"));
    }
    
    if ($item[drum machine].available_amount() > 0 && in_run && (my_adventures() <= 1 || (availableDrunkenness() < 0 && availableDrunkenness() > -4 && my_adventures() >= 1)) && __quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && $item[drum machine].item_is_usable())
    {
        //Daycount strategy that never works, suggest:
        string line = (100.0 * ((item_drop_modifier_ignoring_plants() / 100.0 + 1.0) * (1.0 / 1000.0))).roundForOutput(2) + "% chance of spice melange.";
        if (my_adventures() == 0)
            line += "|Need one adventure.";
        resource_entries.listAppend(ChecklistEntryMake("__item drum machine", "inventory.php?which=3&ftext=drum+machine", ChecklistSubentryMake(pluralise($item[drum machine]), "", line), importance_level_unimportant_item));
    }
    
    
    if ($items[stinky cheese sword,stinky cheese diaper,stinky cheese wheel,stinky cheese eye,Staff of Queso Escusado].available_amount() > 0 && !get_property_boolean("_stinkyCheeseBanisherUsed"))
    {
        resource_entries.listAppend(ChecklistEntryMake("__item stinky cheese eye", "", ChecklistSubentryMake("Stinky cheese eye banish", "", "Free run.")).ChecklistEntryTagEntry("banish"));
    }
    
    if (in_run)
    {
		if ($item[tattered scrap of paper].available_amount() > 0 && __misc_state["free runs usable"] && $item[tattered scrap of paper].item_is_usable())
		{
			string [int] description;
			description.listAppend(($item[tattered scrap of paper].available_amount() / 2.0).roundForOutput(1) + " free runs.");
            if (in_bad_moon())
                description.listAppend("Or save for demon summoning.");
			resource_entries.listAppend(ChecklistEntryMake("__item tattered scrap of paper", "", ChecklistSubentryMake(pluralise($item[tattered scrap of paper]), "", description), importance_level_unimportant_item));
		}
		if (2371.to_item().available_amount() > 0 && __misc_state["free runs usable"])
		{
            item it = 2371.to_item();
			string [int] description;
			description.listAppend((it.available_amount() * 0.9).roundForOutput(1) + " free runs.");
			resource_entries.listAppend(ChecklistEntryMake("__item " + it, "", ChecklistSubentryMake(pluralise(it), "", description), importance_level_unimportant_item));
		}
		if ($item[dungeoneering kit].available_amount() > 0)
		{
			string line = "Open it.";
			if ($item[dungeoneering kit].available_amount() > 1)
				line = "Open them.";
			resource_entries.listAppend(ChecklistEntryMake("__item dungeoneering kit", "inventory.php?which=3&ftext=dungeoneering+kit", ChecklistSubentryMake(pluralise($item[dungeoneering kit]), "", line), importance_level_unimportant_item));
		}
        if ($item[Box of familiar jacks].available_amount() > 0)
            resource_entries.listAppend(ChecklistEntryMake("__item box of familiar jacks", "", ChecklistSubentryMake(pluralise($item[Box of familiar jacks]), "", "Gives current familiar equipment."), importance_level_unimportant_item));
        if ($item[csa fire-starting kit].available_amount() > 0 && !get_property_boolean("_fireStartingKitUsed"))
        {
            string [int] description;
            description.listAppend("All-day 4 HP/MP regeneration.");
            if (hippy_stone_broken())
                description.listAppend("3 PVP fights.");
            resource_entries.listAppend(ChecklistEntryMake("__item csa fire-starting kit", "inventory.php?which=3&ftext=csa+fire-starting+kit", ChecklistSubentryMake($item[csa fire-starting kit], "", description), importance_level_unimportant_item));
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
                description += "|" + options.listJoinComponents(", ", "and").capitaliseFirstLetter();
            resource_entries.listAppend(ChecklistEntryMake("__item transporter transponder", "", ChecklistSubentryMake(pluralise($item[transporter transponder]), "", description), importance_level_unimportant_item));
        }
    }
    
    foreach it in $items[carton of astral energy drinks,astral hot dog dinner,astral six-pack]
    {
        if (it.available_amount() == 0)
            continue;
        resource_entries.listAppend(ChecklistEntryMake("__item " + it, "inventory.php?which=3&ftext=" + it.replace_string(" ", "+"), ChecklistSubentryMake(pluralise(it), "", "Open for astral consumables."), importance_level_unimportant_item));
    }
    
    if ($item[map to safety shelter grimace prime].available_amount() > 0)
    {
        string line = "Use for synthetic dog hair or distention pill.";
        if (__misc_state["in aftercore"])
            line += "|Will disappear when you ascend.";
        resource_entries.listAppend(ChecklistEntryMake("__item " + $item[map to safety shelter grimace prime], "inventory.php?which=3&ftext=map+to+safety+shelter+grimace+prime", ChecklistSubentryMake(pluralise($item[map to safety shelter grimace prime]), "", line), importance_level_unimportant_item));
    }
    if ($item[rusty hedge trimmers].available_amount() > 0 && __quest_state["Level 9"].state_int["twin peak progress"] != 15 && in_run)
    {
        string [int] description;
        description.listAppend("Use to visit the Twin Peak non-combat.");
        resource_entries.listAppend(ChecklistEntryMake("__item " + $item[rusty hedge trimmers], "inventory.php?which=3&ftext=rusty+hedge+trimmers", ChecklistSubentryMake(pluralise($item[rusty hedge trimmers]), "", description), importance_level_unimportant_item));
    }
    
    if (in_run && my_path_id() != PATH_WAY_OF_THE_SURPRISING_FIST)
    {
        string image_name = "";
        string [int] autosell_list;
        boolean [item] autosellable_items = $items[meat stack, dense meat stack, really dense meat stack, solid gold bowling ball, fancy seashell necklace, commemorative war stein,huge gold coin].makeConstantItemArrayMutable();
        if ($item[pixel coin] != $item[none])
            autosellable_items[$item[pixel coin]] = true;
        foreach it in autosellable_items
        {
            if (it.available_amount() == 0)
                continue;
            autosell_list.listAppend(it.pluralise());
            
            if (image_name.length() == 0)
                image_name = "__item " + it;
        }
            
        string [int] open_list;
        foreach it in $items[old coin purse, old leather wallet, black pension check, ancient vinyl coin purse, warm subject gift certificate,shiny stones]
        {
            if (it.available_amount() == 0)
                continue;
            if (!it.item_is_usable()) continue;
            open_list.listAppend(it.pluralise());
            
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
            resource_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake("Meat", "", description), importance_level_unimportant_item));
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
        
        resource_entries.listAppend(ChecklistEntryMake("__item " + odd_silver_coin, "shop.php?whichshop=cindy", ChecklistSubentryMake(odd_silver_coin.pluralise(), "", description), importance_level_item));
    }
    item grimstone_mask = $item[grimstone mask];
    if (grimstone_mask.available_amount() > 0 && in_run)
    {
        string [int] description;
        
        description.listAppend("Wear to take you places.");
        description.listAppend("The prince's ball (stepmother) lets you find odd silver coins.|Up to six, one adventure each.");
        //description.listAppend("Rumpelstiltskin's for towerkilling with small golem.|Small golem is a 5k/round combat item.|Involves the semi-rare in village. Don't know the details, sorry."); //only somewhat relevant in obscure edge cases
        if ($effect[Human-Fish Hybrid].have_effect() == 0 && __iotms_usable[$item[Little Geneticist DNA-Splicing Lab]] && !__misc_state["familiars temporarily blocked"])
            description.listAppend("Candy witch for human-fish hybrid. (+10 familiar weight)");
        if (get_property("grimstoneMaskPath") != "")
            description.listAppend("Currently on the path of " + get_property("grimstoneMaskPath") + ".");
        
        resource_entries.listAppend(ChecklistEntryMake("__item " + grimstone_mask, "inventory.php?which=3&ftext=grimstone+mask", ChecklistSubentryMake(grimstone_mask.pluralise(), "", description), importance_level_item));
    }
    
    if (get_campground()[$item[spinning wheel]] > 0 && !get_property_boolean("_spinningWheel"))
    {
        string [int] description;
        int meat_gained = powi(MIN(30, my_level()), 3);
        description.listAppend("Will gain " + meat_gained + " meat.");
        if (availableDrunkenness() >= 0)
        {
            if (my_level() < 8)
                description.listAppend("Wait until you've leveled up more.");
            else if (my_level() < 13)
                description.listAppend("Possibly wait until you've leveled up more?");
        }
        resource_entries.listAppend(ChecklistEntryMake("__item spinning wheel", "campground.php?action=workshed", ChecklistSubentryMake("Spinning wheel meat", "", description), importance_level_unimportant_item));
    }
    
    if ($item[very overdue library book].available_amount() > 0 && in_run && __misc_state["need to level"] && $item[very overdue library book].item_is_usable())
    {
        resource_entries.listAppend(ChecklistEntryMake("__item very overdue library book", "inventory.php?which=3&ftext=very+overdue+library+book", ChecklistSubentryMake("Very overdue library book", "", "Open for 63 moxie/mysticality/muscle."), importance_level_unimportant_item));
    }
    
    if ($item[chest of the Bonerdagon].available_amount() > 0 && in_run)
    {
        string description = "Open for 150 muscle/mysticality/moxie and 3k meat.";
        if (!$familiar[ninja pirate zombie robot].have_familiar())
            description += "|Unless you want to make an NPZR this ascension.";
        resource_entries.listAppend(ChecklistEntryMake("__item chest of the Bonerdagon", "inventory.php?which=3&ftext=chest+of+the+Bonerdagon", ChecklistSubentryMake("chest of the Bonerdagon", "", description), importance_level_unimportant_item));
    }
    
    if ($item[smoke grenade].available_amount() > 0 && in_run)
    {
        string description = "Turn-costing banish. (lasts 20 turns, no stats, no items, no meat)";
        resource_entries.listAppend(ChecklistEntryMake("__item smoke grenade", "", ChecklistSubentryMake(pluralise($item[Smoke grenade]), "", description), importance_level_unimportant_item).ChecklistEntryTagEntry("banish"));
    }
    
    if ($item[pile of ashes].available_amount() > 0 && in_run)
    {
        string description = "-10% combat. (20 turns)";
        resource_entries.listAppend(ChecklistEntryMake("__item pile of ashes", "inventory.php?which=3&ftext=pile+of+ashes", ChecklistSubentryMake(pluralise($item[pile of ashes]), "", description), importance_level_unimportant_item));
    }
    if (to_item("7259").available_amount() > 0 && in_run)
    {
        string description = "Open for elemental damage combat items.";
        resource_entries.listAppend(ChecklistEntryMake("__item " + to_item("7259"), "inventory.php?which=3&ftext=" + to_item("7259").replace_string(" ", "+"), ChecklistSubentryMake(pluralise(to_item("7259")), "", description), importance_level_unimportant_item));
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
        resource_entries.listAppend(ChecklistEntryMake("__item gym membership card", "inventory.php?which=3&ftext=gym+membership+card", ChecklistSubentryMake(pluralise($item[gym membership card]), "", description), importance_level_item));
    }
    
    if (!get_property_boolean("_warbearGyrocopterUsed"))
    {
        if ($item[warbear gyrocopter].available_amount() > 0)
        {
            string [int] description;
            description.listAppend("Usable once/day for a gyro. Only breaks a quarter of the time.");
            if (!in_ronin())
                description.listAppend("Could always send it to yourself.");
            resource_entries.listAppend(ChecklistEntryMake("__item warbear gyrocopter", "curse.php?whichitem=7038", ChecklistSubentryMake(pluralise($item[warbear gyrocopter]), "", description), importance_level_unimportant_item));
            
        }
        else if ($item[broken warbear gyrocopter].available_amount() > 0)
        {
            resource_entries.listAppend(ChecklistEntryMake("__item broken warbear gyrocopter", "inventory.php?which=3&ftext=broken+warbear+gyrocopter", ChecklistSubentryMake(pluralise($item[broken warbear gyrocopter]), "", "Gyrocopters dream of the sky. Set one free!"), importance_level_unimportant_item));
            
        }
    }
    if ($item[burned government manual fragment].available_amount() > 0)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item burned government manual fragment", "inventory.php?which=3&ftext=burned+government+manual+fragment", ChecklistSubentryMake(pluralise($item[burned government manual fragment]), "", "Foreign language study.|Will disappear on ascension."), importance_level_unimportant_item));
    }
    if ($item[lynyrd snare].available_amount() > 0 && get_property_int("_lynyrdSnareUses") < 3 && my_path_id() != PATH_G_LOVER)// && in_run && __misc_state["need to level"])
    {
        int uses_remaining = MIN($item[lynyrd snare].available_amount(), clampi(3 - get_property_int("_lynyrdSnareUses"), 0, 3));
        resource_entries.listAppend(ChecklistEntryMake("__item lynyrd snare", "inventory.php?which=3&ftext=lynyrd+snare", ChecklistSubentryMake(pluralise(uses_remaining,$item[lynyrd snare]), "", "Free fight when used."), importance_level_unimportant_item).ChecklistEntryTagEntry("daily free fight"));
    }
    if (in_run && $item[red box].available_amount() > 0 && my_path_id() != PATH_G_LOVER)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item red box", "inventory.php?which=3&ftext=red+box", ChecklistSubentryMake(pluralise($item[red box]), "", "Open for stuff."), importance_level_unimportant_item));
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
        
        resource_entries.listAppend(ChecklistEntryMake("__item llama lama gong", "inventory.php?which=3&ftext=llama+lama+gong", ChecklistSubentryMake(pluralise($item[llama lama gong]), "", description), importance_level_item));
        
    }
    
    if (!in_run && get_property("_bittycar").length() == 0 && $items[BittyCar HotCar, BittyCar MeatCar,BittyCar SoulCar].available_amount() > 0)
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
        resource_entries.listAppend(ChecklistEntryMake("__item BittyCar MeatCar", "inventory.php?which=3&ftext=bittycar", ChecklistSubentryMake("BittyCar " + available_items.listJoinComponents(", ", "or") + " usable", "", description), importance_level_unimportant_item));
    }
    
    if (in_run && !__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"] != "mysticality" && !get_property_ascension("lastGoofballBuy") && __quest_state["Level 3"].started)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item bottle of goofballs", "tavern.php?place=susguy", ChecklistSubentryMake("Bottle of goofballs obtainable", "", "For the lair stat test.|Costs nothing, but be careful..."), importance_level_unimportant_item));
    }
    
    if ($item[tonic djinn].available_amount() > 0 && in_ronin() && in_run && !get_property_boolean("_tonicDjinn") && my_path_id() != PATH_G_LOVER)
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
        
        resource_entries.listAppend(ChecklistEntryMake("__item tonic djinn", "inventory.php?which=3&ftext=tonic+djinn", ChecklistSubentryMake("Tonic djinn", "", description), importance_level_unimportant_item));
    }
    
    if ($item[V for Vivala mask].have() && $item[V for Vivala mask].is_unrestricted() && !get_property_boolean("_vmaskBanisherUsed"))
    {
        string url;
        string [int] description;
        if (__misc_state["free runs usable"])
            description.listAppend("Once/day free run/banisher. (combat skill)");
        else
            description.listAppend("Once/day banisher. (combat skill)");
        
        if ($item[V for Vivala mask].equipped_amount() == 0)
        {
            description.listAppend("Equip V for Vivala mask first.");
            url = "inventory.php?which=2"; //&ftext=v+for+vivala
        }
        string line = "Costs ";
        if (my_mp() < 30)
            line += HTMLGenerateSpanFont("30 MP", "red");
        else
            line += "30 MP";
        line += ".";
        description.listAppend(line);
        resource_entries.listAppend(ChecklistEntryMake("__item V for Vivala mask", url, ChecklistSubentryMake("Creepy Grin usable", "", description), importance_level_item).ChecklistEntryTagEntry("banish"));
    }
    
    if ($item[moveable feast].available_amount() > 0 && $item[moveable feast].is_unrestricted() && get_property_int("_feastUsed") < 5)
    {
        string [int] description;
        string url = "inventory.php?which=2"; //&ftext=moveable+feast
        int feastings_left = clampi(5 - get_property_int("_feastUsed"), 0, 5);
        
        description.listAppend("Gives +10 familiar weight for twenty turns to a specific familiar.");
        string [int] familiars_used_on = get_property("_feastedFamiliars").split_string_alternate(";"); //separator: ";"
        if (in_run && __misc_state["free runs usable"])
        {
            string [int] familiars_could_imbue_for_del_shannon;
            boolean [familiar] familiars_used_on_inverse;
            foreach key, f_name in familiars_used_on
            {
                familiar f = f_name.to_familiar();
                if (f != $familiar[none])
                    familiars_used_on_inverse[f] = true;
            }
            foreach f in $familiars[pair of stomping boots,Frumious Bandersnatch]
            {
                if (f.familiar_is_usable() && !(familiars_used_on_inverse contains f))
                {
                    familiars_could_imbue_for_del_shannon.listAppend(f);
                }
            }
            if (familiars_could_imbue_for_del_shannon.count() > 0)
            {
                description.listAppend("Could feed " + familiars_could_imbue_for_del_shannon.listJoinComponents(", ", "or") + " for +2 free runs.");
            }
        }
        
        if (familiars_used_on.count() > 0)
            description.listAppend("Already used on " + familiars_used_on.listJoinComponents(", ", "and") + ".");
        resource_entries.listAppend(ChecklistEntryMake("__item moveable feast", url, ChecklistSubentryMake(pluralise(feastings_left, "moveable feasting", "moveable feastings"), "", description), importance_level_item));
        //_feastedFamiliars
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
                    line[key] = HTMLGenerateSpanFont(s, "grey");
                }
            }
            table.listAppend(line);
        }
        string [int] description;
        description.listAppend(HTMLGenerateSimpleTableLines(table));
        resource_entries.listAppend(ChecklistEntryMake("__item cosmic calorie", "inventory.php?which=3", ChecklistSubentryMake(pluralise($item[cosmic calorie]), "", description), importance_level_item));
        
    }
    
    if ($item[portable cassette player].available_amount() > 0 && (__misc_state["in run"] || $item[portable cassette player].equipped_amount() > 0) && $item[portable cassette player].is_unrestricted())
    {
        string [int] description;
        string url = "";
        int modulus = total_turns_played() % 40;
        
        string [effect] buff_descriptions;
        buff_descriptions[$effect[Dark Orchestral Song]] = "+5 moxie";
        buff_descriptions[$effect[Pet Shop Song]] = "+10% init";
        buff_descriptions[$effect[Dangerous Zone Song]] = "+25% meat";
        buff_descriptions[$effect[Flashy Dance Song]] = "+10% item";
        
        effect [int] buffs_activate_at; //NOT a linear list
        buffs_activate_at[0] = $effect[Dark Orchestral Song];
        buffs_activate_at[10] = $effect[Pet Shop Song];
        buffs_activate_at[20] = $effect[Dangerous Zone Song];
        buffs_activate_at[30] = $effect[Flashy Dance Song];
        
        boolean [effect] buffs_to_display_for_future = $effects[Dangerous Zone Song,Flashy Dance Song];
        
        boolean [effect] buffs_to_not_bother_display_current_for = $effects[Dark Orchestral Song,Pet Shop Song]; //+10% init is like +1% chance of extra modern zmobies, which saves an extremely small fraction of a turn. ignore, because cognitive load + you might run better accessories instead, like +ML. plus, you have to use that weird fiddly technique because of +combat
        string [int] future_buffs;
        foreach mod_value, buff in buffs_activate_at
        {
            string buff_description = buff_descriptions[buff];
            if (modulus >= mod_value && modulus < mod_value + 10)
            {
                if (buffs_to_not_bother_display_current_for contains buff)
                {
                    continue;
                }
                int turns_remaining = 10 - modulus % 10;
                string line = buff_description;
                if (buff.have_effect() == 0)
                    line += " obtainable";
                else
                {
                    if (turns_remaining < buff.have_effect())
                    {
                        turns_remaining = buff.have_effect();
                        line += " active";
                    }
                }
                line += " for " + pluralise(turns_remaining, " more turn", " more turns");
                boolean have_other_song_active = false;
                effect other_song = $effect[none];
                foreach e in $effects[Dark Orchestral Song,Pet Shop Song,Dangerous Zone Song,Flashy Dance Song]
                {
                    if (e != buff && e.have_effect() > 0)
                    {
                        other_song = e;
                        have_other_song_active = true;
                    }
                }
                if (have_other_song_active)
                {
                    line += " after losing current";
                    if (!(buffs_to_not_bother_display_current_for contains other_song))
                        line += " " + buff_descriptions[other_song];
                    line += " song. (unequip cassette for a turn)";
                }
                else
                    line += ".";
                if (buff.have_effect() == 0 && !have_other_song_active && $item[portable cassette player].equipped_amount() == 0)
                    line += " (equip player)";
                description.listAppend(line);
                continue;
            }
            if (buffs_to_display_for_future contains buff)
            {
                int turns_until = mod_value - modulus;
                if (turns_until < 0)
                    turns_until += 40;
                future_buffs.listAppend(pluralise(turns_until, "more turn", "more turns") + " until " + buff_description);
            }
        }
        if (future_buffs.count() > 0)
            description.listAppend(future_buffs.listJoinComponents(", ").capitaliseFirstLetter() + ".");
        
        //description.listAppend("Modulus " + modulus + ".");
        resource_entries.listAppend(ChecklistEntryMake("__item portable cassette player", url, ChecklistSubentryMake("Portable cassette player buffs", "", description), 10));
    }
    if (is_wearing_outfit("Hodgman's Regal Frippery"))
    {
        int underling_summons_remaining = clampi(5 - get_property_int("_hoboUnderlingSummons"), 0, 5);
        if (underling_summons_remaining > 0)
        {
            string [int] description;
            description.listAppend("Combat skill while wearing the frippery. For a single fight, adds +100% meat (joke) or +100% item (dance).");
            resource_entries.listAppend(ChecklistEntryMake("__skill Summon hobo underling", "", ChecklistSubentryMake(pluralise(underling_summons_remaining, "hobo underling summon", "hobo underling summons"), "", description), -1));
        }
    }
    if (lookupItem("license to chill").available_amount() > 0 && !get_property_boolean("_licenseToChillUsed") && mafiaIsPastRevision(18122))
    {
        resource_entries.listAppend(ChecklistEntryMake("__item License to Chill", "inventory.php?which=3&ftext=license+to+chill", ChecklistSubentryMake("License to Chill", "", "+5 adventures, extend effects by one turn, HP/MP restore, statgain."), 10));
        
    }
    if (lookupItem("etched hourglass").available_amount() > 0 && !get_property_boolean("_etchedHourglassUsed"))
    {
        resource_entries.listAppend(ChecklistEntryMake("__item etched hourglass", "inventory.php?which=3&ftext=etched+hourglass", ChecklistSubentryMake("Etched Hourglass", "", "+5 adventures."), 10));
        
    }
    if ($item[mafia middle finger ring].available_amount() > 0 && !get_property_boolean("_mafiaMiddleFingerRingUsed"))
    {
        resource_entries.listAppend(ChecklistEntryMake("__item mafia middle finger ring", ($item[mafia middle finger ring].equipped_amount() == 0 ? "inventory.php?which=2" : ""), ChecklistSubentryMake("Mafia middle finger ring banish/free run", "", "Once/day, 60 turn duration." + ($item[mafia middle finger ring].equipped_amount() == 0 ? " Equip first." : "")), 10).ChecklistEntryTagEntry("banish")); //&ftext=mafia+middle+finger+ring
    	
    }
}
