
RegisterTaskGenerationFunction("IOTMSpaceJellyfishGenerateTasks");
void IOTMSpaceJellyfishGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!$familiar[space jellyfish].familiar_is_usable())
        return;
    if (!get_property_boolean("_seaJellyHarvested") && my_level() >= 11 && !__misc_state["sea access blocked"])
    {
        string url = "place.php?whichplace=thesea&action=thesea_left2";
        string [int] description;
        if (!QuestState("questS01OldGuy").started)
        {
            url = "oldman.php";
            description.listAppend("Visit the old man first.");
        }
        else if (my_familiar() != $familiar[space jellyfish])
        {
            url = "familiar.php";
            description.listAppend("Bring along your space jellyfish first.");
        }
        description.listAppend("Once/day.");
        optional_task_entries.listAppend(ChecklistEntryMake("__familiar space jellyfish", url, ChecklistSubentryMake("Harvest sea jelly", "", description)));
    }
}


RegisterResourceGenerationFunction("IOTMSpaceJellyfishGenerateResource");
void IOTMSpaceJellyfishGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!$familiar[space jellyfish].familiar_is_usable())
        return;
    
    ChecklistEntry entry = ChecklistEntryMake();
	entry.url = "";
	entry.image_lookup_name = "__familiar space jellyfish";
    entry.importance_level = 5;
    
    //_spaceJellyfishDrops
    //_hotJellyUses
    if (my_familiar() != $familiar[space jellyfish])
    {
        entry.url = "familiar.php";
    }
    
    int [int] percent_chance_at_use = {
        0:100,
        1:50,
        2:33,
        3:25,
        4:20,
        5:5,
        6:5,
        7:5,
        8:5,
        9:5,
        10:5,
    	11:5,
        12:5,
        13:5,
        14:5,
    };
    //FIXME spade rest
    
    if (__misc_state["in run"] && spleen_limit() > 0)
    {
        /*
        hot - free run/banish
        spooky - YR with no cooldown
        stench - clara's bell, more or less
        
        The other two aren't too useful in-run.
        */
        if (get_property_int("_hotJellyUses") > 0)
        {
            resource_entries.listAppend(ChecklistEntryMake("__item hot jelly", "", ChecklistSubentryMake(pluralise(get_property_int("_hotJellyUses"), "breathe out", "breathe outs"), "", "Cast Breathe Out. Free run/banish.")).ChecklistEntryTag("free banish"));
        }
        
        string [item] jelly_descriptions;
        //jelly_descriptions[$item[hot jelly]] = "Free run/banish.";
        jelly_descriptions[$item[spooky jelly]] = "YR with no cooldown.";
        jelly_descriptions[$item[stench jelly]] = "Forces non-combat.";
        foreach it, desc in jelly_descriptions
        {
            if (it.available_amount() > 0 && in_ronin())
            {
                entry.subentries.listAppend(ChecklistSubentryMake(pluralise(it), "", desc));
            }
        }
        
        if ($item[hot jelly].available_amount() > 0 && in_ronin())
            resource_entries.listAppend(ChecklistEntryMake("__item hot jelly", "", ChecklistSubentryMake(pluralise($item[hot jelly]), "", "Chew for free run/banish.")).ChecklistEntryTag("free banish"));
        
        
        
        int extractions = get_property_int("_spaceJellyfishDrops");
        string [int] description;
        string line = "Extract jelly against elemental monsters.";
        if (percent_chance_at_use contains extractions)
            line += "|" + percent_chance_at_use[extractions] + "% chance of success.";
        
        //Should we list common areas to find these?
        //Spooky is defiled alcove. Hot is the level six quest. Stench is level twelve, i.e. level never before you need it.
        line += "|*" + HTMLGenerateSpanOfClass("Stench", "r_bold r_element_stench_desaturated") + " - forces non-combat";
        if (!__quest_state["Level 12"].finished)
            line += " (try hippies)";
        line += "|*" + HTMLGenerateSpanOfClass("Spooky", "r_bold r_element_spooky_desaturated") + " - YR with no cooldown";
        if (!__quest_state["Level 7"].finished)
            line += " (try cyrpt)";
        line += "|*" + HTMLGenerateSpanOfClass("Hot", "r_bold r_element_hot_desaturated") + " - free run/banish";
        if (!__quest_state["Level 12"].finished)
            line += " (try friars)";
        description.listAppend(line);
        if (availableDrunkenness() >= 0)
            entry.subentries.listAppend(ChecklistSubentryMake(pluralise(extractions, "jelly extraction", "jelly extractions"), "", description));
    }
    
    
    if (entry.subentries.count() > 0)
        resource_entries.listAppend(entry);
}
