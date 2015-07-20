//DELETE THIS FILE

Record SpelunkingStatusOld
{
    boolean [location] areas_unlocked;
    boolean noncombat_due_next_adventure;
    
    int turns_left;
    int gold;
    int bombs;
    int ropes;
    int keys;
    string buddy;
};

location SSpelunkingLookupLocationStatusName(string entry)
{
    if (entry == "Burial Ground")
        return lookupLocation("The Ancient Burial Ground");
    return ("The " + entry).to_location();
}
SpelunkingStatus SSpelunkingParseStatus()
{
    SpelunkingStatus spelunking_status;
    spelunking_status.areas_unlocked[lookupLocation("The Mines")] = true;
    
    boolean past_unlocks = false;
    string [int] status_split = get_property("spelunkyStatus").split_string(", ");
    
    foreach key, entry in status_split
    {
        if (past_unlocks)
        {
            location l = SSpelunkingLookupLocationStatusName(entry);
            if (l != $location[none])
                spelunking_status.areas_unlocked[l] = true;
        }
        if (entry == "Non-combat Due")
        {
            spelunking_status.noncombat_due_next_adventure = true;
            continue;
        }
        if (entry.stringHasPrefix("Unlocks:"))
        {
            past_unlocks = true;
        }
        
        if (entry.contains_text(": "))
        {
            string [int] split_entry = entry.split_string(": "); //hopefully, there isn't one that has a : inside of it... FIXME
            if (split_entry.count() < 2)
                continue;
            string header = split_entry[0];
            if (header == "Turns")
                spelunking_status.turns_left = split_entry[1].to_int_silent();
            else if (header == "Gold")
                spelunking_status.gold = split_entry[1].to_int_silent();
            else if (header == "Bombs")
                spelunking_status.bombs = split_entry[1].to_int_silent();
            else if (header == "Ropes")
                spelunking_status.ropes = split_entry[1].to_int_silent();
            else if (header == "Keys")
                spelunking_status.keys = split_entry[1].to_int_silent();
            else if (header == "Buddy")
                spelunking_status.buddy = split_entry[1];
            else
            {
                if (__setting_debug_mode)
                {
                    print_html("Unknown entry type \"" + entry + "\"");
                }
            }
        }
    }
    return spelunking_status;
}


void SSpelunkingGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (limit_mode() != "spelunky")
        return;
    
    
    SpelunkingStatus spelunking_status = SSpelunkingParseStatus();
    
    if (spelunking_status.noncombat_due_next_adventure)
    {
        string [int] temporary_description;
        temporary_description.listAppend("Next phase is " + get_property("spelunkyNextNoncombat") + ".");
        temporary_description.listAppend("Can choose NCs in " + spelunking_status.areas_unlocked.to_json());
        task_entries.listAppend(ChecklistEntryMake("__item ghost trap", "place.php?whichplace=spelunky", ChecklistSubentryMake("Non-combat next adventure", "", temporary_description)));
        
        //FIXME mention The Joke Book of the Dead and attacking the ghost
    }
    
    if (true)
    {
        string [int] temporary_description;
        foreach s in $strings[spelunkyNextNoncombat,spelunkySacrifices,spelunkyStatus,spelunkyUpgrades,spelunkyWinCount]
        {
            temporary_description.listAppend(s + " = \"" + get_property(s) + "\"");
        }
        temporary_description.listAppend("spelunking_status = " + spelunking_status.to_json());
        
        task_entries.listAppend(ChecklistEntryMake("__item heavy pickaxe", "place.php?whichplace=spelunky", ChecklistSubentryMake("Spelunk!", "", temporary_description)));
    }
}