void QMartyInit()
{
	//questM03Bugbear
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM18Swamp");
	
	state.quest_name = "Marty's Quest";
	state.image_name = "__item maple leaf";
	
	state.startable = knoll_available();
	
	__quest_state["Marty"] = state;
}

void QMartyGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Marty"];
	if (!base_quest_state.in_progress)
		return;
    if (!canadia_available())
        return;
    if (__misc_state["in run"] && $location[the bugbear pen].turnsAttemptedInLocation() == 0)
        return;
        
	string url = "place.php?whichplace=marais";
		
	ChecklistSubentry subentry;
	
	subentry.header = base_quest_state.quest_name;
    
    //FIXME use locationAvailable(), as mafia has tracking for area unlocks:
    
    int fork_ncs_seen = 0;
    foreach key, NC in $location[the edge of the swamp].locationSeenNoncombats()
    {
        if (NC == "Stick a Fork In It")
            fork_ncs_seen += 1;
    }
    boolean minus_combat_relevant = false;
    
    if (fork_ncs_seen < 2)
    {
        subentry.entries.listAppend("Adventure in the edge of the swamp, unlock both the left and right paths in the fork.");
        minus_combat_relevant = true;
    }
    else
    {
        int sophies_seen = 0;
        foreach key, NC in $location[the Dark and Spooky Swamp].locationSeenNoncombats()
        {
            if (NC == "Sophie's Choice")
                sophies_seen += 1;
        }
        if (sophies_seen < 2)
        {
            subentry.entries.listAppend("Adventure in the Dark and Spooky Swamp, unlock both paths from Sophie's Choice.");
            minus_combat_relevant = true;
        }
        else
        {
            //corpse bog, ruined wizard tower
            if ($item[Phil Bunion's axe].available_amount() == 0)
            {
                //corpse bog
                subentry.entries.listAppend("Adventure in the Corpse Bog to defeat the ghost of Phil Bunion.");
            }
            if (!$location[the ruined wizard tower].noncombat_queue.contains_text("How to Get a Head in Navigating"))
            {
                subentry.entries.listAppend("Adventure in the Ruined Wizard Tower to find a shrunken navigator head.");
                minus_combat_relevant = true;
            }
        }
        int bad_to_worses_seen = 0;
        foreach key, NC in $location[the Wildlife Sanctuarrrrrgh].locationSeenNoncombats()
        {
            if (NC == "From Bad to Worst")
                bad_to_worses_seen += 1;
        }
        if (bad_to_worses_seen < 2)
        {
            subentry.entries.listAppend("Adventure in the Wildlife Sanctuarrrrrgh, unlock both paths from From Bad to Worst.");
            minus_combat_relevant = true;
        }
        else
        {
            //swamp beaver territory, weird swamp village
            if ($item[bouquet of swamp roses].available_amount() == 0)
            {
                subentry.entries.listAppend("Adventure in the Weird Swamp Village to defeat a swamp skunk.");
                subentry.modifiers.listAppend("+item?");
            }
            if ($item[shrunken navigator head].available_amount() > 0 && $item[branch from the Great Tree].available_amount() == 0)
            {
                minus_combat_relevant = true;
                subentry.entries.listAppend("Adventure in the Swamp Beaver Territory, follow the shrunken navigator head's directions, and defeat a conservationist hippy.");
            }
        }
    }
    if (minus_combat_relevant) //....?
        subentry.modifiers.listAppend("-combat?");
        
    if ($items[Phil Bunion's axe,bouquet of swamp roses,branch from the Great Tree].items_missing().count() == 0)
    {
        subentry.entries.listAppend("Go talk to Marty to finish the quest.");
        url = "place.php?whichplace=canadia";
    }
	
    boolean [location] relevant_locations;
    relevant_locations[$location[the edge of the swamp]] = true;
    relevant_locations[$location[The Dark and Spooky Swamp]] = true;
    relevant_locations[$location[The Corpse Bog]] = true;
    relevant_locations[$location[The Ruined Wizard Tower]] = true;
    relevant_locations[$location[The Wildlife Sanctuarrrrrgh]] = true;
    relevant_locations[$location[Swamp Beaver Territory]] = true;
    relevant_locations[$location[The Weird Swamp Village]] = true;
	
	optional_task_entries.listAppend(ChecklistEntryMake(81, base_quest_state.image_name, url, subentry, relevant_locations));
    
    
}
