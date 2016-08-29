
void QOldLandfillInit()
{
	QuestState state;
	
	QuestStateParseMafiaQuestProperty(state, "questM19Hippy");
	
	state.quest_name = "Give a Hippy a Boat";
	state.image_name = "__item junk junk";
	
	state.startable = true;
	
	__quest_state["Old Landfill"] = state;
}


void QOldLandfillGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState base_quest_state = __quest_state["Old Landfill"];
	//if (!base_quest_state.in_progress) //this isn't actively tracked, so the best we can do is checking the last adventure location
		//return;
    if ($item[junk junk].available_amount() > 0) //FIXME returning to the hippy
        return;
    if (__last_adventure_location != $location[the old landfill] && !base_quest_state.in_progress)
        return;
    if (__misc_state["mysterious island available"])
        return;
		
	ChecklistSubentry subentry;
    subentry.entries.listAppend("Unlocks the Mysterious Island.");
    
    item [int] missing_boat_items = $items[old claw-foot bathtub,old clothesline pole,antique cigar sign].items_missing();
	
	subentry.header = base_quest_state.quest_name;
	
	string active_url = "place.php?whichplace=woods";
    
    if ($item[worse homes and gardens].available_amount() > 0 && missing_boat_items.count() == 0)
    {
        active_url = "shop.php?whichshop=junkmagazine";
        subentry.entries.listAppend("Use worse homes and gardens, craft a junk junk.");
    }
    else
    {
        string [int] nc_instructions = listMake("Go left", "Flush a bunch of toilets");
        
        if ($item[old claw-foot bathtub].available_amount() == 0)
        {
            nc_instructions = listMake("Go left", "Take the tub");
        }
        else if ($item[old clothesline pole].available_amount() == 0)
        {
            nc_instructions = listMake("Go center", "Take the antenna");
        }
        else if ($item[antique cigar sign].available_amount() == 0)
        {
            nc_instructions = listMake("Go right", "Take the sign");
        }
        
        
        if (missing_boat_items.count() > $item[funky junk key].available_amount() || $item[worse homes and gardens].available_amount() == 0)
        {
            subentry.modifiers.listAppend("+item");
            subentry.entries.listAppend("Adventure in the Old Landfill with +item.");
        }
        else
            subentry.entries.listAppend("Adventure in the Old Landfill.");
        
        subentry.entries.listAppend("At the choice adventure, choose:|*" + nc_instructions.listJoinComponents(__html_right_arrow_character) + ".");
    }
	
    
	optional_task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, active_url, subentry, $locations[the old landfill]));
}