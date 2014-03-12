
void SOldLevel9GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if ($location[The Valley of Rof L'm Fao].turnsAttemptedInLocation() == 0)
        return;
    if (__misc_state["In run"])
        return;
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questM15Lol", false); //don't issue a quest log load for this, no information gained
    if (!state.in_progress)
        return;
    
    string [int] description;
    
    if ($item[64735 scroll].available_amount() > 0)
    {
        description.listAppend("Use the 64735 scroll.");
    }
    else
    {
        description.listAppend("Make the 64735 scroll using the rampaging fax machine.");
        
        item [int] components_testing;
        if ($item[64067 scroll].available_amount() == 0)
        {
            components_testing.listAppend($item[30669 scroll]);
            components_testing.listAppend($item[33398 scroll]);
        }
        if ($item[668 scroll].available_amount() == 0)
        {
            components_testing.listAppend($item[334 scroll]);
            components_testing.listAppend($item[334 scroll]);
        }
        string [int] components_needed;
        int [item] amount_used;
        foreach key in components_testing
        {
            item it = components_testing[key];
            if (it.available_amount() - amount_used[it] <= 0)
            {
                components_needed.listAppend(it.to_string());
            }
            else
                amount_used[it] += 1;
        }
        if (components_needed.count() > 0)
            description.listAppend("Need " + components_needed.listJoinComponents(", ", "and") + ".");
        
        //suggest faxing?
        if (__misc_state["fax accessible"])
            description.listAppend("Possibly fax the rampaging adding machine (with all scroll components) for one-turn quest.");
        description.listAppend("Find rampaging adding machine, feed it 334 + 334, 30669 + 33398, 64067 + 668.");
        description.listAppend("31337 scroll is 30669 + 668. (334 + 334)");
    }
    ChecklistSubentry [int] subentries;
    subentries.listAppend(ChecklistSubentryMake("A Quest, LOL", "", description));
    optional_task_entries.listAppend(ChecklistEntryMake("__item 64735 scroll", "mountains.php", subentries, 10, $locations[the valley of rof l'm fao]));
}