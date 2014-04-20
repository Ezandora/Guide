void generateImageTest(Checklist [int] checklists)
{
	ChecklistEntry [int] image_test_entries;
	KOLImagesInit();
	foreach i in __kol_images
	{
		KOLImage image = __kol_images[i];
		image_test_entries.listAppend(ChecklistEntryMake(i, "", ChecklistSubentryMake(i)));
		
	}
	checklists.listAppend(ChecklistMake("All images", image_test_entries));
}

void generateStateTest(Checklist [int] checklists)
{
	ChecklistEntry [int] misc_state_entries;
	ChecklistEntry [int] quest_state_entries;
    
	
    string [int] state_description;
    string [int] string_description;
    string [int] int_description;
	foreach key in __misc_state
	{
        state_description.listAppend(key + " = " + __misc_state[key]);
	}
	foreach key in __misc_state_string
	{
        string_description.listAppend(key + " = \"" + __misc_state_string[key] + "\"");
	}
	foreach key in __misc_state_int
	{
        int_description.listAppend(key + " = " + __misc_state_int[key]);
	}
	
    misc_state_entries.listAppend(ChecklistEntryMake("__item milky potion", "", ChecklistSubentryMake("Boolean", "", state_description.listJoinComponents("|"))));
    misc_state_entries.listAppend(ChecklistEntryMake("__item ghost thread", "", ChecklistSubentryMake("String", "", string_description.listJoinComponents("|"))));
    misc_state_entries.listAppend(ChecklistEntryMake("__item handful of numbers", "", ChecklistSubentryMake("Int", "", int_description.listJoinComponents("|"))));
	
	boolean [string] names_already_seen;
	
	foreach key in __quest_state
	{
		if (names_already_seen[key])
			continue;
		names_already_seen[key] = true;
		
		QuestState quest_state = __quest_state[key];
		
		string [int] full_name_list;
		full_name_list.listAppend(key);
		
		//Look for others:
		foreach key2 in __quest_state
		{
			if (key == key2)
				continue;
			QuestState quest_state_2 = __quest_state[key2];
			
			if (QuestStateEquals(quest_state, quest_state_2))
			{
				full_name_list.listAppend(key2);
				names_already_seen[key2] = true;
			}
		}
		
		ChecklistSubentry subentry;
		
		subentry.header = listJoinComponents(full_name_list, " / " );
		if (quest_state.quest_name != "")
			subentry.entries.listAppend("Internal name: " + quest_state.quest_name);
		
		subentry.entries.listAppend("Startable: " + quest_state.startable);
		subentry.entries.listAppend("Started: " + quest_state.started);
		subentry.entries.listAppend("In progress: " + quest_state.in_progress);
		subentry.entries.listAppend("Finished: " + quest_state.finished);
		subentry.entries.listAppend("Mafia's internal step: " + quest_state.mafia_internal_step);
		
		foreach key2 in quest_state.state_boolean
		{
			subentry.entries.listAppend(key2 + ": " + quest_state.state_boolean[key2]);
		}
		foreach key2 in quest_state.state_string
		{
			subentry.entries.listAppend(key2 + ": \"" + quest_state.state_string[key2] + "\"");
		}
		foreach key2 in quest_state.state_int
		{
			subentry.entries.listAppend(key2 + ": " + quest_state.state_int[key2]);
		}
		
		quest_state_entries.listAppend(ChecklistEntryMake(quest_state.image_name, "", subentry));
	}
	
	
	checklists.listAppend(ChecklistMake("Misc. States", misc_state_entries));
	checklists.listAppend(ChecklistMake("Quest States", quest_state_entries));
}

void generateCounterTest(Checklist [int] checklists)
{
	ChecklistEntry [int] checklist_entries;
    
    ChecklistEntry main_entry;
    main_entry.image_lookup_name = "__item sinister ancient tablet";
    
    string [int] counter_names = CounterGetAllNames();
    
    if (counter_names.count() == 0)
        return;
    
    foreach key in counter_names
    {
        string counter_name = counter_names[key];
        Counter c = CounterLookup(counter_name);
        
        string [int] description;
        description.listAppend(c.CounterDescription());
        
        main_entry.subentries.listAppend(ChecklistSubentryMake(c.name, "", description));
    }
    
    checklist_entries.listAppend(main_entry);
    
    
	checklists.listAppend(ChecklistMake("Counters", checklist_entries));
}

buffer generateMajorMinorText(string [string][int] entries)
{
    buffer description;
    foreach zone in entries
    {
        if (description.length() > 0)
            description.append("|");
        description.append(zone);
        description.append(":|*");
        description.append(entries[zone].listJoinComponents("|*"));
    }
    return description;
}

void generateSelfDataTest(Checklist [int] checklists)
{
	ChecklistEntry [int] checklist_entries;
    //Show missing locations in locationAvailable and missing locations from clickables.
    
    string [string][int] missing_available_locations;
    string [string][int] missing_location_links_description;
    
    foreach l in $locations[]
    {
        Error unable_to_find_location;
        l.locationAvailable(unable_to_find_location);
        
        if (unable_to_find_location.was_error)
        {
            if (!(missing_available_locations contains l.zone))
                missing_available_locations[l.zone] = listMakeBlankString();
            missing_available_locations[l.zone].listAppend(l.to_string());
        }
        
        Error unable_to_find_clickable;
        l.getClickableURLForLocation(unable_to_find_clickable);
        if (unable_to_find_clickable.was_error)
        {
            if (!(missing_location_links_description contains l.zone))
                missing_location_links_description[l.zone] = listMakeBlankString();
            missing_location_links_description[l.zone].listAppend("case $location[" + l.to_string() + "]:");
        }
    }
    if (missing_available_locations.count() > 0)
    {
        buffer description = generateMajorMinorText(missing_available_locations);
        checklist_entries.listAppend(ChecklistEntryMake("__item cobb's knob map", "", ChecklistSubentryMake("Missing locationAvailable() locations", "", description)));
    }
    
    
    if (missing_location_links_description.count() > 0)
    {
        buffer description = generateMajorMinorText(missing_location_links_description);
        checklist_entries.listAppend(ChecklistEntryMake("__item reflection of a map", "", ChecklistSubentryMake("Missing getClickableURLForLocation() locations", "", description)));
    }
	checklists.listAppend(ChecklistMake("Self data tests", checklist_entries));
}