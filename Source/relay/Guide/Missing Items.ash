import "relay/Guide/Support/Checklist.ash";
import "relay/Guide/QuestState.ash";
import "relay/Guide/Sets.ash";

void generateMissingItems(Checklist [int] checklists)
{
	ChecklistEntry [int] items_needed_entries;
	
	if (!__misc_state["In run"])
		return;
	
    //thought about using getClickableURLForLocationIfAvailable for these, but our location detection is very poor, and there are corner cases regardless
	
	if (__misc_state["wand of nagamar needed"])
	{
		ChecklistSubentry [int] subentries;
		
		subentries[subentries.count()] = ChecklistSubentryMake("Wand of Nagamar", "", "");
		
		if (__misc_state_int["ruby w needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("ruby W", "Clover or +234% item", listMake("Clover the castle basement", "W Imp - Dark Neck of the Woods/Pandamonium Slums - 30% drop"));
		if (__misc_state_int["metallic a needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("metallic A", "Clover or +234% item", listMake("Clover the castle basement", "MagiMechTech MechaMech - Penultimate Fantasy Airship - 30% drop"));
		if (__misc_state_int["lowercase n needed"] > 0 && __misc_state_int["lowercase n available"] == 0)
		{
			string name = "lowercase N";
			subentries[subentries.count()] = ChecklistSubentryMake(name, "Clover or +234% item", listMake("Clover the castle basement", "XXX pr0n - Valley of Rof L'm Fao - 30% drop"));
		}
		if (__misc_state_int["heavy d needed"] > 0)
			subentries[subentries.count()] = ChecklistSubentryMake("heavy D", "Clover or +150% item", listMake("Clover the castle basement", "Alphabet Giant - Castle Basement - 40% drop"));
			
		ChecklistEntry entry = ChecklistEntryMake("__item wand of nagamar", $location[the castle in the clouds in the sky (basement)].getClickableURLForLocation(), subentries);
		entry.should_indent_after_first_subentry = true;
		
		items_needed_entries.listAppend(entry);
	}
	
	if (!__quest_state["Level 13"].state_boolean["past keys"])
	{
		//Key items:
		
		if ($item[skeleton key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["past keys"])
		{
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
			items_needed_entries.listAppend(ChecklistEntryMake("__item skeleton key", $location[the defiled nook].getClickableURLForLocation(), ChecklistSubentryMake("Skeleton key", "", line)));
		}
		
		if ($item[digital key].available_amount() == 0)
		{
			string [int] options;
            if ($item[digital key].creatable_amount() > 0)
            {
                options.listAppend("Have enough pixels, make it.");
            }
            else
            {
                options.listAppend("Fear man's level (jar)");
                if (__misc_state["fax equivalent accessible"] && in_hardcore()) //not suggesting this in SC
                    options.listAppend("Fax/copy a ghost");
                options.listAppend("8-bit realm (olfact blooper, slow)");
            }
            //FIXME URL?
			items_needed_entries.listAppend(ChecklistEntryMake("__item digital key", "", ChecklistSubentryMake("Digital key", "", options)));
		}
		string from_daily_dungeon_string = "From daily dungeon";
		if ($item[fat loot token].available_amount() > 0)
			from_daily_dungeon_string += "|" + pluralize($item[fat loot token]) + " available";
		if ($item[sneaky pete's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Sneaky Pete's key", "da.php", ChecklistSubentryMake("Sneaky Pete's key", "", options)));
		}
		if ($item[jarlsberg's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item jarlsberg's key", "da.php", ChecklistSubentryMake("Jarlsberg's key", "", options)));
		}
		if ($item[Boris's key].available_amount() == 0)
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Boris's key", "da.php", ChecklistSubentryMake("Boris's key", "", options)));
		}
	}
	
	if ($item[lord spookyraven's spectacles].available_amount() == 0 && __quest_state["Level 11 Manor"].state_boolean["Can use fast route"] && !__quest_state["Level 11 Manor"].finished)
		items_needed_entries.listAppend(ChecklistEntryMake("__item lord spookyraven's spectacles", $location[the haunted bedroom].getClickableURLForLocation(), ChecklistSubentryMake("lord spookyraven's spectacles", "", "Found in Haunted Bedroom")));
    
    if ($item[enchanted bean].available_amount() == 0 && !__quest_state["Level 10"].state_boolean["Beanstalk grown"])
    {
		items_needed_entries.listAppend(ChecklistEntryMake("__item enchanted bean", $location[The Beanbat Chamber].getClickableURLForLocation(), ChecklistSubentryMake("Enchanted bean", "", "Found in the beanbat chamber.")));
    }
    
    if (__quest_state["Level 13"].state_boolean["shadow will need to be defeated"])
    {
        //Let's see
        //5 gauze garters + filthy poultices
        //Or...
        //red pixel potion (not worth farming, but if they have it...)
        //red potion
        //extra-strength red potion (they might find it)
        
    }
    if (__quest_state["Level 11 Palindome"].state_boolean["Need instant camera"])
    {
        item camera = 7266.to_item();
        if (camera != $item[none])
        {
            items_needed_entries.listAppend(ChecklistEntryMake("__item " + camera, $location[the haunted bedroom].getClickableURLForLocation(), ChecklistSubentryMake("Disposable instant camera", "", "Found in the Haunted Bedroom.")));
        }
    }
    
    if (lookupItem("electric boning knife").available_amount() == 0 && __quest_state["Level 13"].state_boolean["wall of bones will need to be defeated"])
    {
        items_needed_entries.listAppend(ChecklistEntryMake("__item electric boning knife", $location[the castle in the clouds in the sky (ground floor)].getClickableURLForLocation(), ChecklistSubentryMake("Electric boning knife", "-combat", listMake("Found from an NC on the ground floor of the castle in the clouds in the sky.", "Or towerkill."))));
    }
    if (lookupItem("beehive").available_amount() == 0 && __quest_state["Level 13"].state_boolean["wall of skin will need to be defeated"])
    {
        string [int] description;
        
        description.listAppend("Found from an NC in the black forest.");
        
        if (get_property_int("blackForestProgress") >= 1)
            description.listAppend(listMake("Head toward the blackberry patch", "Head toward the buzzing sound", "Keep going", "Almost... there...").listJoinComponents(__html_right_arrow_character));
        else
            description.listAppend("Not available yet.");
        description.listAppend("Or towerkill.");
        
        items_needed_entries.listAppend(ChecklistEntryMake("__item beehive", $location[the black forest].getClickableURLForLocation(), ChecklistSubentryMake("Beehive", "-combat", description)));
    }
    
    if (!__quest_state["Level 13"].state_boolean["Init race completed"])
    {
        ChecklistSubentry subentry = ChecklistSubentryMake("Sources", "", "For the lair races.");
        string [int] sources;
        if (!__quest_state["Level 13"].state_boolean["Init race completed"])
        {
            subentry.modifiers.listAppend("+init");
            sources.listAppend("init");
            //subentries.listAppend(ChecklistSubentryMake("+init sources", "+init", "For the lair races."));
        }
        if (!__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"].length() > 0)
        {
            //
            subentry.modifiers.listAppend("+" + __quest_state["Level 13"].state_string["Stat race type"]);
            sources.listAppend(__quest_state["Level 13"].state_string["Stat race type"]);
        }
        if (!__quest_state["Level 13"].state_boolean["Elemental damage race completed"] && __quest_state["Level 13"].state_string["Elemental damage race type"].length() > 0)
        {
            //
            string type = __quest_state["Level 13"].state_string["Elemental damage race type"];
            string type_class = "r_element_" + type + "_desaturated";
            subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("+" + type + " damage", type_class));
            subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("+" + type + " spell damage", type_class));
            sources.listAppend(type);
        }
        subentry.header = sources.listJoinComponents(", ", "and").capitalizeFirstLetter() + " sources";
        if (subentry.modifiers.count() > 0)
            items_needed_entries.listAppend(ChecklistEntryMake("__item vial of patchouli oil", "", subentry));
    }
                               
    SetsGenerateMissingItems(items_needed_entries);
	
	checklists.listAppend(ChecklistMake("Required Items", items_needed_entries));
}