import "relay/Guide/Support/Checklist.ash";
import "relay/Guide/QuestState.ash";
import "relay/Guide/Sets.ash";

void generateMissingItems(Checklist [int] checklists)
{
	ChecklistEntry [int] items_needed_entries;
	
	if (!__misc_state["in run"])
		return;
    if (my_path_id() == PATH_COMMUNITY_SERVICE)
        return;
	
    //thought about using getClickableURLForLocationIfAvailable for these, but our location detection is very poor, and there are corner cases regardless
	
	if (__misc_state["wand of nagamar needed"])
	{
		ChecklistSubentry [int] subentries;
		
		subentries.listAppend(ChecklistSubentryMake("Wand of Nagamar", "", ""));
		
        Record WandComponentSource
        {
            item component;
            int drop_rate;
            monster monster_dropped_from;
            location location_dropped_from;
        };
        void listAppend(WandComponentSource [int] list, WandComponentSource entry)
        {
            int position = list.count();
            while (list contains position)
                position += 1;
            list[position] = entry;
        }
        
        WandComponentSource [int] component_sources;
        
        if (__misc_state_int["ruby w needed"] > 0)
        {
            WandComponentSource source;
            source.component = $item[ruby w];
            source.drop_rate = 30;
            source.monster_dropped_from = $monster[w imp];
            if (__quest_state["Level 6"].finished)
                source.location_dropped_from = $location[Pandamonium Slums];
            else
                source.location_dropped_from = $location[the dark neck of the woods];
            component_sources.listAppend(source);
        }
        
		if (__misc_state_int["metallic a needed"] > 0)
        {
            WandComponentSource source;
            source.component = $item[metallic a];
            source.drop_rate = 30;
            source.monster_dropped_from = $monster[MagiMechTech MechaMech];
            source.location_dropped_from = $location[The Penultimate Fantasy Airship];
            component_sources.listAppend(source);
        }
        
        if (__misc_state_int["lowercase n needed"] > 0 && __misc_state_int["lowercase n available"] == 0)
        {
            WandComponentSource source;
            source.component = $item[lowercase n];
            source.drop_rate = 30;
            source.monster_dropped_from = $monster[XXX pr0n];
            source.location_dropped_from = $location[The Valley of Rof L'm Fao];
            component_sources.listAppend(source);
        }
        
		if (__misc_state_int["heavy d needed"] > 0)
        {
            WandComponentSource source;
            source.component = $item[heavy d];
            source.drop_rate = 40;
            source.monster_dropped_from = $monster[Alphabet Giant];
            source.location_dropped_from = $location[The Castle in the Clouds in the Sky (Basement)];
            component_sources.listAppend(source);
        }
        
        foreach key, source in component_sources
        {
            if (source.component.available_amount() > 0)
                continue;
            string modifier_text = "";
            if (!in_bad_moon())
                modifier_text = "Clover or ";
            if (source.drop_rate > 0 && source.drop_rate < 100)
            {
                int drop_rate_inverse = ceil(100.0 / source.drop_rate.to_float() * 100.0 - 100.0);
                modifier_text += "+" + drop_rate_inverse + "% item";
            }
            
            string [int] description;
            if (!in_bad_moon())
                description.listAppend("Clover the castle basement.");
            description.listAppend(source.monster_dropped_from + " - " + source.location_dropped_from + " - " + source.drop_rate + "% drop");
			subentries.listAppend(ChecklistSubentryMake(source.component, modifier_text, description));
        }
        
        if (subentries.count() == 1)
            subentries[0].entries.listAppend("Can create it.");
        else if (!__misc_state["can use clovers"])
            subentries[0].entries.listAppend("Either meatpaste together, or find after losing to the naughty sorceress. (" + (in_bad_moon() ? "probably faster" : "usually slower") + ")");
			
		ChecklistEntry entry = ChecklistEntryMake("__item wand of nagamar", $location[the castle in the clouds in the sky (basement)].getClickableURLForLocation(), subentries);
		entry.should_indent_after_first_subentry = true;
		
		items_needed_entries.listAppend(entry);
	}
	
	if (!__quest_state["Level 13"].state_boolean["past keys"])
	{
		//Key items:
		
		if ($item[skeleton key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["skeleton key used"])
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
		
		if ($item[digital key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["digital key used"])
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
                if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
                    options.listAppend("Wait for pixellated monsters");
                
                int total_white_pixels = $item[white pixel].available_amount() + $item[white pixel].creatable_amount();
                if (total_white_pixels > 0)
                    options.listAppend(total_white_pixels + "/30 white pixels found.");
            }
            //FIXME URL?
			items_needed_entries.listAppend(ChecklistEntryMake("__item digital key", "", ChecklistSubentryMake("Digital key", "", options)));
		}
		string from_daily_dungeon_string = "From daily dungeon";
		if ($item[fat loot token].available_amount() > 0)
			from_daily_dungeon_string += "|" + pluralise($item[fat loot token]) + " available";
		if ($item[sneaky pete's key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["Sneaky Pete's key used"])
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Sneaky Pete's key", "da.php", ChecklistSubentryMake("Sneaky Pete's key", "", options)));
		}
		if ($item[jarlsberg's key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["Jarlsberg's key used"])
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item jarlsberg's key", "da.php", ChecklistSubentryMake("Jarlsberg's key", "", options)));
		}
		if ($item[Boris's key].available_amount() == 0 && !__quest_state["Level 13"].state_boolean["Boris's key used"])
		{
			string [int] options;
			options.listAppend(from_daily_dungeon_string);
			if (__misc_state_int["pulls available"] > 0 && __misc_state["can eat just about anything"])
				options.listAppend("From key lime pie");
			items_needed_entries.listAppend(ChecklistEntryMake("__item Boris's key", "da.php", ChecklistSubentryMake("Boris's key", "", options)));
		}
	}
	
	if ($item[lord spookyraven's spectacles].available_amount() == 0 && __quest_state["Level 11 Manor"].state_boolean["Can use fast route"] && !__quest_state["Level 11 Manor"].finished)
		items_needed_entries.listAppend(ChecklistEntryMake("__item lord spookyraven's spectacles", $location[the haunted bedroom].getClickableURLForLocation(), ChecklistSubentryMake("Lord Spookyraven's spectacles", "", "Found in Haunted Bedroom")));
    
    if ($item[enchanted bean].available_amount() == 0 && !__quest_state["Level 10"].state_boolean["beanstalk grown"])
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
    
    if ($item[electric boning knife].available_amount() == 0 && __quest_state["Level 13"].state_boolean["wall of bones will need to be defeated"])
    {
        string [int] description;
        description.listAppend("Found from an NC on the ground floor of the castle in the clouds in the sky.");
        boolean can_towerkill = false;
        if ($skill[garbage nova].skill_is_usable())
        {
            description.listAppend("Ignore this, you can towerkill with Garbage Nova.");
            can_towerkill = true;
        }
        else if (!in_bad_moon())
            description.listAppend("Or towerkill.");
        if (!can_towerkill && !__quest_state["Level 13"].state_boolean["past tower level 2"] && $location[the castle in the clouds in the sky (top floor)].locationAvailable())
            description.listAppend("Chances of finding go up if you wait until you're at the wall of meat.");
        items_needed_entries.listAppend(ChecklistEntryMake("__item electric boning knife", $location[the castle in the clouds in the sky (ground floor)].getClickableURLForLocation(), ChecklistSubentryMake("Electric boning knife", "-combat", description)));
    }
    if ($item[beehive].available_amount() == 0 && __quest_state["Level 13"].state_boolean["wall of skin will need to be defeated"])
    {
        string [int] description;
        
        description.listAppend("Found from an NC in the black forest.");
        
        if (get_property_int("blackForestProgress") >= 1)
            description.listAppend(listMake("Head toward the blackberry patch", "Head toward the buzzing sound", "Keep going", "Almost... there...").listJoinComponents(__html_right_arrow_character));
        else
            description.listAppend("Not available yet.");
        if (!in_bad_moon())
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
        if (!__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"] != "")
        {
            //
            subentry.modifiers.listAppend("+" + __quest_state["Level 13"].state_string["Stat race type"]);
            sources.listAppend(__quest_state["Level 13"].state_string["Stat race type"]);
        }
        if (!__quest_state["Level 13"].state_boolean["Elemental damage race completed"] && __quest_state["Level 13"].state_string["Elemental damage race type"] != "")
        {
            //
            string type = __quest_state["Level 13"].state_string["Elemental damage race type"];
            string type_class = "r_element_" + type + "_desaturated";
            subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("+" + type + " damage", type_class));
            subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("+" + type + " spell damage", type_class));
            sources.listAppend(type);
        }
        subentry.header = sources.listJoinComponents(", ", "and").capitaliseFirstLetter() + " sources";
        if (subentry.modifiers.count() > 0)
            items_needed_entries.listAppend(ChecklistEntryMake("__item vial of patchouli oil", "", subentry));
    }
                               
    SetsGenerateMissingItems(items_needed_entries);
	
	checklists.listAppend(ChecklistMake("Required Items", items_needed_entries));
}